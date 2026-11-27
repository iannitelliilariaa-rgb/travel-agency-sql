USE travel_agency_management_database;

SHOW TABLES;

SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM bookings;
SELECT COUNT(*) FROM tours;
SELECT COUNT(*) FROM flights;
SELECT COUNT(*) FROM insurance;

SELECT * FROM customers LIMIT 10;
SELECT * FROM bookings LIMIT 10;
SELECT * FROM tours LIMIT 10;
SELECT * FROM flights LIMIT 10;
SELECT * FROM insurance LIMIT 10;

-- Reservas sin cliente válido
SELECT b.*
FROM bookings b
LEFT JOIN customers c
    ON b.customer_id = c.id
WHERE c.id IS NULL;

-- Reservas sin tour válido
SELECT b.*
FROM bookings b
LEFT JOIN tours t
    ON b.tour_id = t.id
WHERE t.id IS NULL;

-- Vuelos sin reserva válida
SELECT f.*
FROM flights f
LEFT JOIN bookings b
    ON f.booking_id = b.id
WHERE b.id IS NULL;

-- Seguros sin reserva válida
SELECT i.*
FROM insurance i
LEFT JOIN bookings b
    ON i.booking_id = b.id
WHERE b.id IS NULL;

SELECT
    COUNT(*) AS total_registros,
    SUM(phone IS NULL) AS telefonos_nulos,
    SUM(country IS NULL) AS paises_nulos
FROM customers;

SELECT
    COUNT(*) AS total_registros,
    SUM(booking_date IS NULL) AS fechas_nulas
FROM bookings;

SELECT
    COUNT(*) AS total_registros,
    SUM(coverage_amount IS NULL) AS coberturas_nulas,
    SUM(policy_number IS NULL) AS polizas_nulas
FROM insurance;

-- Duplicados 
SELECT id, COUNT(*) AS repeticiones
FROM customers
GROUP BY id
HAVING COUNT(*) > 1;

SELECT email, COUNT(*) AS repeticiones
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;

-- Valores fuera de rango
SELECT *
FROM tours
WHERE duration_days <= 0
   OR price <= 0;
   
   SELECT *
FROM bookings
WHERE total_amount <= 0;

SELECT *
FROM insurance
WHERE coverage_amount < 0;

-- Categorias disponibles

SELECT DISTINCT payment_status
FROM bookings;

SELECT DISTINCT booking_source
FROM bookings;

SELECT DISTINCT policy_status
FROM insurance;
