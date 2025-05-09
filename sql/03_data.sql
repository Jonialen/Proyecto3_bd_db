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
('Básquetbol'),
('Pádel'), 
('Vóley');

-- 5. COURTS
INSERT INTO COURTS (id_type, description, price_per_hour) VALUES
(1, 'Cancha de tenis cubierta', 200.00),
(1, 'Cancha de tenis al aire libre', 150.00),
(2, 'Cancha de fútbol 5 sintética', 300.00),
(2, 'Cancha de fútbol 5 techada', 320.00),
(2, 'Cancha de fútbol 5 con gradas', 310.00),
(3, 'Cancha de básquetbol profesional', 250.00),
(3, 'Cancha de básquetbol 3x3 al aire libre', 200.00),
(4, 'Cancha de pádel panorámica', 240.00),
(4, 'Cancha de pádel indoor', 260.00),
(4, 'Cancha de pádel con césped artificial', 250.00),
(5, 'Cancha de vóley playa', 190.00),
(5, 'Cancha de vóley techada', 210.00),
(5, 'Cancha de vóley con suelo de goma', 200.00);

-- 6. SCHEDULES
DO $$
DECLARE
    i INT;
    court_count INT;
    court_id INT;
    sched_date DATE;
    start_time TIME;
    end_time TIME;
BEGIN
    -- Obtener el número total de canchas
    SELECT COUNT(*) INTO court_count FROM COURTS;

    FOR i IN 1..100 LOOP
        -- Rota entre las canchas disponibles
        SELECT id_court INTO court_id
        FROM COURTS
        ORDER BY id_court
        OFFSET ((i - 1) % court_count) LIMIT 1;

        -- Cambia de día cada 8 horarios
        sched_date := '2025-05-10'::date + ((i - 1) / 8);

        -- Horario desde las 8:00, incrementando cada hora
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
    i INT;              -- id_user
    j INT;              -- número de reserva por usuario
    num_reservas INT;   -- cantidad aleatoria de reservas por usuario
    status_arr TEXT[] := ARRAY['pending', 'confirmed', 'cancelled'];
BEGIN
    FOR i IN 2..100 LOOP  -- Asume que el usuario 1 es admin y no reserva
        -- Generar entre 1 y 3 reservas por usuario
        num_reservas := FLOOR(RANDOM() * 3 + 1)::INT;

        FOR j IN 1..num_reservas LOOP
            INSERT INTO BOOKINGS (id_user, booking_date, status)
            VALUES (
                i,
                '2025-05-10'::date + ((i + j - 2) / 8),  -- Varía la fecha ligeramente
                status_arr[((i + j - 2) % 3) + 1]
            );
        END LOOP;
    END LOOP;
END $$;


-- 9. BOOKING_DETAILS
DO $$
DECLARE
    booking_id INT;
    schedule_ids INT[];
    i INT;
    j INT;
    num_schedules INT;
BEGIN
    -- Obtener todos los ids de SCHEDULES en una lista
    SELECT ARRAY(SELECT id_schedule FROM SCHEDULES ORDER BY RANDOM()) INTO schedule_ids;

    i := 1;

    FOR booking_id IN SELECT id_booking FROM BOOKINGS LOOP
        -- Cantidad aleatoria de horarios por reserva (entre 1 y 3)
        num_schedules := FLOOR(RANDOM() * 3 + 1)::INT;

        FOR j IN 1..num_schedules LOOP
            -- Evitar overflow de índice
            IF i > array_length(schedule_ids, 1) THEN
                i := 1;
            END IF;

            -- Insertar la relación entre reserva y horario
            INSERT INTO BOOKING_DETAILS (id_booking, id_schedule)
            VALUES (booking_id, schedule_ids[i]);

            i := i + 1;
        END LOOP;
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

INSERT INTO INVOICES (id_booking, issue_date, total_amount)
SELECT 
    b.id_booking,
    CURRENT_DATE,
    SUM(c.price_per_hour) AS total_amount
FROM BOOKINGS b
JOIN BOOKING_DETAILS bd ON b.id_booking = bd.id_booking
JOIN SCHEDULES s ON bd.id_schedule = s.id_schedule
JOIN COURTS c ON s.id_court = c.id_court
GROUP BY b.id_booking;

-- 12. Consultas de verificación
SELECT COUNT(*) AS total_usuarios FROM USERS;
SELECT COUNT(*) AS total_reservas FROM BOOKINGS;
SELECT COUNT(*) AS total_detalles FROM BOOKING_DETAILS;
SELECT COUNT(*) AS total_telefonos FROM USER_PHONES;
SELECT COUNT(*) AS total_logs_cancelacion FROM BOOKING_CANCELLATION_LOG;
SELECT * FROM USERS LIMIT 5;
SELECT * FROM BOOKINGS LIMIT 5;
SELECT * FROM BOOKING_CANCELLATION_LOG LIMIT 5;

