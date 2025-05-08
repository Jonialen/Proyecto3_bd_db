-- 0. Limpieza (opcional, solo para pruebas)
TRUNCATE BOOKING_CANCELLATION_LOG, BOOKING_PROMOTIONS, BOOKING_DETAILS, INVOICES, BOOKINGS, SCHEDULES, COURTS, COURT_TYPES, USER_PHONES, USERS, PROMOTIONS, ROLES RESTART IDENTITY CASCADE;

-- 1. ROLES
INSERT INTO ROLES (role_name) VALUES
('admin'),
('client');

-- 2. USERS (1 admin, 99 clientes)
INSERT INTO USERS (name, last_name, email, password, id_role) VALUES
('Admin', 'Principal', 'admin@example.com', 'adminpass', 1);

DO $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..99 LOOP
        INSERT INTO USERS (name, last_name, email, password, id_role)
        VALUES (
            'Cliente' || i,
            'Apellido' || i,
            'cliente' || i || '@example.com',
            'pass' || i,
            2
        );
    END LOOP;
END $$;

-- 3. USER_PHONES (cada usuario tiene 1 teléfono)
DO $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO USER_PHONES (id_user, phone_number)
        VALUES (i, '555-' || LPAD(i::text, 4, '0'));
    END LOOP;
END $$;

-- 4. COURT_TYPES
INSERT INTO COURT_TYPES (type_name) VALUES
('Tenis'),
('Fútbol 5'),
('Básquetbol');

-- 5. COURTS (4 canchas)
INSERT INTO COURTS (id_type, description, price_per_hour) VALUES
(1, 'Cancha de tenis cubierta', 200.00),
(1, 'Cancha de tenis al aire libre', 150.00),
(2, 'Cancha de fútbol 5 sintética', 300.00),
(3, 'Cancha de básquetbol', 180.00);

-- 6. SCHEDULES (100 horarios únicos, rotando entre las 4 canchas)
DO $$
DECLARE
    i INT;
    court_id INT;
    sched_date DATE;
    start_time TIME;
    end_time TIME;
BEGIN
    FOR i IN 1..100 LOOP
        court_id := ((i - 1) % 4) + 1;
        sched_date := '2025-05-10'::date + ((i - 1) / 8); -- Cambia de día cada 8 horarios
        start_time := (TIME '08:00') + ((i - 1) % 8) * INTERVAL '1 hour';
        end_time := start_time + INTERVAL '1 hour';
        INSERT INTO SCHEDULES (id_court, schedule_date, start_time, end_time)
        VALUES (court_id, sched_date, start_time, end_time);
    END LOOP;
END $$;

-- 7. PROMOTIONS
INSERT INTO PROMOTIONS (name, description, discount_percentage, start_date, end_date) VALUES
('Promo Tenis', 'Descuento para canchas de tenis', 10.00, '2025-05-01', '2025-05-31'),
('Promo Fútbol', 'Descuento para fútbol 5', 15.00, '2025-05-01', '2025-05-31'),
('Promo Básquet', 'Descuento para básquetbol', 20.00, '2025-05-01', '2025-05-31');

-- 8. BOOKINGS (cada cliente hace 1 reserva, admin no)
DO $$
DECLARE
    i INT;
    status_arr TEXT[] := ARRAY['pending', 'confirmed', 'cancelled'];
BEGIN
    FOR i IN 2..100 LOOP
        INSERT INTO BOOKINGS (id_user, booking_date, status)
        VALUES (
            i,
            '2025-05-10'::date + ((i - 2) / 8), -- mismo patrón de fechas que los horarios
            status_arr[((i - 2) % 3) + 1]
        );
    END LOOP;
END $$;

-- 9. BOOKING_DETAILS (cada reserva se asocia a un horario único)
DO $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..99 LOOP
        INSERT INTO BOOKING_DETAILS (id_booking, id_schedule)
        VALUES (i, i);
    END LOOP;
END $$;

-- 10. BOOKING_PROMOTIONS (asigna promociones a algunas reservas)
DO $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..99 LOOP
        IF i % 10 = 0 THEN
            INSERT INTO BOOKING_PROMOTIONS (id_booking, id_promotion)
            VALUES (i, ((i - 1) % 3) + 1);
        END IF;
    END LOOP;
END $$;

-- 11. Cancela algunas reservas para poblar el log de cancelaciones
UPDATE BOOKINGS SET status = 'cancelled' WHERE id_booking IN (5, 15, 25, 35, 45, 55, 65, 75, 85, 95);

-- 12. Consultas de verificación
SELECT COUNT(*) AS total_usuarios FROM USERS;
SELECT COUNT(*) AS total_reservas FROM BOOKINGS;
SELECT COUNT(*) AS total_detalles FROM BOOKING_DETAILS;
SELECT COUNT(*) AS total_telefonos FROM USER_PHONES;
SELECT COUNT(*) AS total_logs_cancelacion FROM BOOKING_CANCELLATION_LOG;
SELECT * FROM USERS LIMIT 5;
SELECT * FROM BOOKINGS LIMIT 5;
SELECT * FROM BOOKING_CANCELLATION_LOG LIMIT 5;

