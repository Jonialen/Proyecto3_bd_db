-- 1. Trigger: No permitir reservas en horarios ya ocupados
CREATE OR REPLACE FUNCTION prevent_double_booking()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM BOOKING_DETAILS bd
        JOIN SCHEDULES s ON bd.id_schedule = s.id_schedule
        WHERE s.id_court = (SELECT id_court FROM SCHEDULES WHERE id_schedule = NEW.id_schedule)
          AND s.schedule_date = (SELECT schedule_date FROM SCHEDULES WHERE id_schedule = NEW.id_schedule)
          AND (
                (s.start_time, s.end_time) OVERLAPS
                ((SELECT start_time FROM SCHEDULES WHERE id_schedule = NEW.id_schedule),
                 (SELECT end_time FROM SCHEDULES WHERE id_schedule = NEW.id_schedule))
              )
    ) THEN
        RAISE EXCEPTION 'La cancha ya está reservada para ese horario.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_double_booking
BEFORE INSERT ON BOOKING_DETAILS
FOR EACH ROW
EXECUTE FUNCTION prevent_double_booking();

-- 2. Trigger: No permitir eliminar usuarios con reservas activas
CREATE OR REPLACE FUNCTION prevent_delete_user_with_bookings()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM BOOKINGS
        WHERE id_user = OLD.id_user AND status IN ('pending', 'confirmed')
    ) THEN
        RAISE EXCEPTION 'No se puede eliminar un usuario con reservas activas.';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_delete_user_with_bookings
BEFORE DELETE ON USERS
FOR EACH ROW
EXECUTE FUNCTION prevent_delete_user_with_bookings();

-- 3. Trigger: Registrar en un log cada vez que una reserva es cancelada
CREATE TABLE IF NOT EXISTS BOOKING_CANCELLATION_LOG (
    id_log SERIAL PRIMARY KEY,
    id_booking INT NOT NULL,
    cancelled_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_booking) REFERENCES BOOKINGS(id_booking)
);

CREATE OR REPLACE FUNCTION log_booking_cancellation()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'cancelled' AND OLD.status <> 'cancelled' THEN
        INSERT INTO BOOKING_CANCELLATION_LOG (id_booking)
        VALUES (NEW.id_booking);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_booking_cancellation
AFTER UPDATE OF status ON BOOKINGS
FOR EACH ROW
WHEN (NEW.status = 'cancelled' AND OLD.status <> 'cancelled')
EXECUTE FUNCTION log_booking_cancellation();


--4. Trigger para Actualización de Estado de Reservas
CREATE OR REPLACE FUNCTION update_booking_status()
RETURNS TRIGGER AS $$
BEGIN
    -- Actualiza estado de reservas vencidas
    UPDATE bookings
    SET status = 'cancelled'
    WHERE id_booking IN (
        SELECT b.id_booking
        FROM bookings b
        JOIN booking_details bd ON b.id_booking = bd.id_booking
        JOIN schedules s ON bd.id_schedule = s.id_schedule
        WHERE b.status = 'pending'
        AND s.schedule_date < CURRENT_DATE
    );
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_expired_bookings
AFTER INSERT OR UPDATE ON bookings
EXECUTE PROCEDURE update_booking_status();