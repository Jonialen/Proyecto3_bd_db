-- Drop tables if they already exist 
DROP TABLE IF EXISTS ROLES, INVOICES, BOOKING_PROMOTIONS, PROMOTIONS, BOOKING_DETAILS, BOOKINGS, SCHEDULES, COURTS, COURT_TYPES, USER_PHONES, USERS CASCADE;

CREATE TABLE ROLES (
	id_role SERIAL PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE USERS (
    id_user SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password TEXT NOT NULL,
	id_role INT NOT NULL DEFAULT 2,
	FOREIGN KEY (id_role) REFERENCES ROLES(id_role)
);

--(Multivalued attribute)
CREATE TABLE USER_PHONES (
    id_user_phone SERIAL PRIMARY KEY,
    id_user INT NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    FOREIGN KEY (id_user) REFERENCES USERS(id_user)
);

CREATE TABLE COURT_TYPES (
    id_type SERIAL PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE COURTS (
    id_court SERIAL PRIMARY KEY,
    id_type INT NOT NULL,
    description TEXT NOT NULL ,
    price_per_hour NUMERIC(8,2) NOT NULL CHECK (price_per_hour >= 0),
    FOREIGN KEY (id_type) REFERENCES COURT_TYPES(id_type)
);

CREATE TABLE SCHEDULES (
    id_schedule SERIAL PRIMARY KEY,
    id_court INT NOT NULL,
    schedule_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL CHECK (end_time > start_time),
    FOREIGN KEY (id_court) REFERENCES COURTS(id_court)
);

CREATE TABLE BOOKINGS (
    id_booking SERIAL PRIMARY KEY,
    id_user INT NOT NULL,
    booking_date DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'confirmed', 'cancelled')),
    FOREIGN KEY (id_user) REFERENCES USERS(id_user)
);


CREATE TABLE BOOKING_DETAILS (
    id_booking INT NOT NULL,
    id_schedule INT NOT NULL,
    PRIMARY KEY (id_booking, id_schedule),
    FOREIGN KEY (id_booking) REFERENCES BOOKINGS(id_booking),
    FOREIGN KEY (id_schedule) REFERENCES SCHEDULES(id_schedule)
);

CREATE TABLE PROMOTIONS (
    id_promotion SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT NOT NULL,
    discount_percentage NUMERIC(5,2) NOT NULL CHECK (discount_percentage BETWEEN 0 AND 100),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL CHECK (end_date >= start_date)
);

--Cross table
CREATE TABLE BOOKING_PROMOTIONS (
    id_booking INT NOT NULL,
    id_promotion INT NOT NULL,
    PRIMARY KEY (id_booking, id_promotion),
    FOREIGN KEY (id_booking) REFERENCES BOOKINGS(id_booking),
    FOREIGN KEY (id_promotion) REFERENCES PROMOTIONS(id_promotion)
);

CREATE TABLE INVOICES (
    id_invoice SERIAL PRIMARY KEY,
    id_booking INT NOT NULL UNIQUE,
    issue_date DATE NOT NULL DEFAULT CURRENT_DATE,
    total_amount NUMERIC(10,2) NOT NULL CHECK (total_amount >= 0),
    FOREIGN KEY (id_booking) REFERENCES BOOKINGS(id_booking)
);
