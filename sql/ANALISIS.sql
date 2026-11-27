-- Análisis 

CREATE OR REPLACE VIEW vw_booking_analysis AS
SELECT
    b.id AS booking_id,
    b.customer_id,
    c.country,
    c.full_name,
    b.tour_id,
    t.name AS tour_name,
    t.destination,
    t.duration_days,
    t.price AS tour_price,
    b.booking_date,
    b.payment_status,
    b.total_amount,
    b.booking_source
FROM bookings b
LEFT JOIN customers c
    ON b.customer_id = c.id
LEFT JOIN tours t
    ON b.tour_id = t.id;
    
    -- Comprobar
    SELECT *
FROM vw_booking_analysis
LIMIT 20;

-- Comprobar que no hemos multiplicado reservas:
SELECT COUNT(*) AS registros
FROM vw_booking_analysis;

-- ANÁLISIS SOBRE COMPORTAMIENTO DE COMPRA
-- Consulta 1: ¿Cuántos clientes han realizado una o varias reservas?
SELECT
    CASE
        WHEN total_reservations = 1 THEN 'One-time customer'
        ELSE 'Repeat customer'
    END AS customer_type,
    COUNT(*) AS customers
FROM (
    SELECT
        customer_id,
        COUNT(*) AS total_reservations
    FROM bookings
    GROUP BY customer_id
) AS customer_bookings
GROUP BY customer_type;

-- Consulta 2: ¿Qué clientes acumulan mayor importe en reservas?
SELECT
    c.id AS customer_id,
    c.full_name,
    c.country,
    COUNT(b.id) AS total_reservations,
    ROUND(SUM(b.total_amount), 2) AS total_spent,
    ROUND(AVG(b.total_amount), 2) AS average_booking
FROM customers c
JOIN bookings b
    ON c.id = b.customer_id
WHERE b.payment_status = 'completed'
GROUP BY
    c.id,
    c.full_name,
    c.country
ORDER BY total_spent DESC
LIMIT 10;

-- Consulta 3: ¿De qué países proceden los clientes con más reservas?
SELECT
    c.country,
    COUNT(b.id) AS total_reservations,
    COUNT(DISTINCT c.id) AS total_customers,
    ROUND(AVG(b.total_amount), 2) AS average_booking_amount
FROM customers c
JOIN bookings b
    ON c.id = b.customer_id
WHERE c.country IS NOT NULL
GROUP BY c.country
ORDER BY total_reservations DESC;

-- Consulta 4: ¿Cuántas reservas realiza cada cliente de media?
SELECT
    ROUND(AVG(reservation_count), 2) AS average_reservations_per_customer,
    MAX(reservation_count) AS maximum_reservations,
    MIN(reservation_count) AS minimum_reservations,
    STDDEV_POP(reservation_count) AS reservation_std_deviation
FROM (
    SELECT
        customer_id,
        COUNT(*) AS reservation_count
    FROM bookings
    GROUP BY customer_id
) AS customer_frequency;

-- ANÁLISIS DESTINOS Y CARACTERÍSTICAS DE LOS VIAJES
-- consulta 5: ¿Cuáles son los destinos más reservados?
SELECT
    t.destination,
    COUNT(b.id) AS total_reservations,
    COUNT(DISTINCT b.customer_id) AS unique_customers,
    ROUND(AVG(t.price), 2) AS average_tour_price,
    ROUND(AVG(t.duration_days), 2) AS average_duration
FROM tours t
JOIN bookings b
    ON t.id = b.tour_id
WHERE b.payment_status = 'completed'
GROUP BY t.destination
ORDER BY total_reservations DESC;

-- Consulta 6: ¿Los destinos más populares son también los más caros?
SELECT
    t.destination,
    COUNT(b.id) AS total_reservations,
    ROUND(AVG(t.price), 2) AS average_price,
    ROUND(MIN(t.price), 2) AS minimum_price,
    ROUND(MAX(t.price), 2) AS maximum_price
FROM tours t
LEFT JOIN bookings b
    ON t.id = b.tour_id
GROUP BY t.destination
ORDER BY total_reservations DESC, average_price DESC;

-- Consulta 7: ¿Qué relación existe entre duración y precio?
SELECT
    duration_days,
    COUNT(*) AS number_of_tours,
    ROUND(AVG(price), 2) AS average_price,
    ROUND(AVG(price / duration_days), 2) AS average_price_per_day,
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price
FROM tours
WHERE duration_days > 0
GROUP BY duration_days
ORDER BY duration_days;

-- Consulta 8: ¿Qué destinos ofrecen mayor variedad de tours?
SELECT
    destination,
    COUNT(*) AS available_tours,
    ROUND(AVG(price), 2) AS average_price,
    ROUND(AVG(duration_days), 2) AS average_duration
FROM tours
GROUP BY destination
ORDER BY available_tours DESC, average_price ASC;

-- Consulta 9: ¿En qué meses se realizan más reservas?
SELECT
    YEAR(booking_date) AS booking_year,
    MONTH(booking_date) AS booking_month,
    MONTHNAME(booking_date) AS month_name,
    COUNT(*) AS total_reservations
FROM bookings
WHERE booking_date IS NOT NULL
GROUP BY
    YEAR(booking_date),
    MONTH(booking_date),
    MONTHNAME(booking_date)
ORDER BY booking_year, booking_month;

-- ANÁLISIS VENTAS Y COMPORTAMIENTO ECONÓMICO
-- Consulta 10: ¿Qué canal de contratación genera mayor importe?
SELECT
    booking_source,
    COUNT(*) AS total_reservations,
    ROUND(SUM(total_amount), 2) AS total_booking_amount,
    ROUND(AVG(total_amount), 2) AS average_booking_amount,
    MIN(total_amount) AS minimum_amount,
    MAX(total_amount) AS maximum_amount,
    STDDEV_POP(total_amount) AS amount_std_deviation
FROM bookings
WHERE payment_status = 'completed'
GROUP BY booking_source
ORDER BY total_booking_amount DESC;

-- Consulta 11: ¿Cuál es el importe total registrado según el estado del pago?
SELECT
    payment_status,
    COUNT(*) AS total_bookings,
    ROUND(SUM(total_amount), 2) AS total_amount,
    ROUND(AVG(total_amount), 2) AS average_amount,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM bookings),
        2
    ) AS percentage_of_bookings
FROM bookings
GROUP BY payment_status
ORDER BY total_bookings DESC;

-- Consulta 12: ¿Qué porcentaje de reservas figura como reembolsado?
SELECT
    COUNT(*) AS total_bookings,
    SUM(payment_status = 'refunded') AS refunded_bookings,
    ROUND(
        SUM(payment_status = 'refunded') * 100.0 /
        COUNT(*),
        2
    ) AS refunded_percentage,
    ROUND(
        SUM(
            CASE
                WHEN payment_status = 'refunded'
                THEN total_amount
                ELSE 0
            END
        ),
        2
    ) AS refunded_recorded_amount
FROM bookings;

-- Consulta 13: ¿Qué tours generan mayor importe de reservas completadas?
SELECT
    t.id AS tour_id,
    t.name AS tour_name,
    t.destination,
    COUNT(b.id) AS completed_reservations,
    ROUND(SUM(b.total_amount), 2) AS total_booking_amount,
    ROUND(AVG(b.total_amount), 2) AS average_booking_amount
FROM tours t
JOIN bookings b
    ON t.id = b.tour_id
WHERE b.payment_status = 'completed'
GROUP BY
    t.id,
    t.name,
    t.destination
ORDER BY total_booking_amount DESC
LIMIT 10;

-- ANÁLISIS CANALES Y SEGUROS
-- Consulta 14: ¿Qué porcentaje de reservas tiene un seguro contratado?
SELECT
    COUNT(*) AS total_bookings,
    SUM(
        CASE
            WHEN i.booking_id IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS bookings_with_insurance,
    ROUND(
        SUM(
            CASE
                WHEN i.booking_id IS NOT NULL THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS insurance_attachment_rate
FROM bookings b
LEFT JOIN (
    SELECT DISTINCT booking_id
    FROM insurance
) i
    ON b.id = i.booking_id;
    
    -- Consulta 15: ¿Qué cobertura media tienen los seguros contratados?
    SELECT
    policy_status,
    COUNT(*) AS total_policies,
    ROUND(AVG(coverage_amount), 2) AS average_coverage,
    ROUND(MIN(coverage_amount), 2) AS minimum_coverage,
    ROUND(MAX(coverage_amount), 2) AS maximum_coverage,
    ROUND(STDDEV_POP(coverage_amount), 2) AS coverage_std_deviation
FROM insurance
WHERE coverage_amount IS NOT NULL
GROUP BY policy_status;

-- Consulta 16: ¿Los clientes que realizan reservas de mayor importe contratan más seguros?
WITH booking_segments AS (
    SELECT
        id AS booking_id,
        total_amount,
        NTILE(4) OVER (
            ORDER BY total_amount
        ) AS amount_quartile
    FROM bookings
)
SELECT
    bs.amount_quartile,
    COUNT(*) AS total_bookings,
    ROUND(AVG(bs.total_amount), 2) AS average_booking_amount,
    SUM(
        CASE
            WHEN i.booking_id IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS bookings_with_insurance,
    ROUND(
        SUM(
            CASE
                WHEN i.booking_id IS NOT NULL THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS insurance_rate
FROM booking_segments bs
LEFT JOIN (
    SELECT DISTINCT booking_id
    FROM insurance
) i
    ON bs.booking_id = i.booking_id
GROUP BY bs.amount_quartile
ORDER BY bs.amount_quartile;

-- ANÁLISIS VUELOS
-- Consulta 17: ¿Qué rutas aéreas aparecen más veces en las reservas?
SELECT
    departure_airport,
    arrival_airport,
    COUNT(*) AS total_flights
FROM flights
GROUP BY
    departure_airport,
    arrival_airport
ORDER BY total_flights DESC
LIMIT 10;

-- Consulta 18: ¿Cuántos vuelos tiene asociada cada reserva?
SELECT
    b.id AS booking_id,
    t.destination,
    COUNT(f.id) AS number_of_flights,
    b.total_amount,
    b.payment_status
FROM bookings b
JOIN tours t
    ON b.tour_id = t.id
LEFT JOIN flights f
    ON b.id = f.booking_id
GROUP BY
    b.id,
    t.destination,
    b.total_amount,
    b.payment_status
ORDER BY number_of_flights DESC;

-- VIAJE RECOMENDADO:
WITH tour_metrics AS (
    SELECT
        t.id AS tour_id,
        t.name AS tour_name,
        t.destination,
        t.duration_days,
        t.price,
        COUNT(b.id) AS total_reservations,

        SUM(
            CASE
                WHEN b.payment_status = 'completed'
                THEN 1 ELSE 0
            END
        ) AS completed_reservations,

        ROUND(AVG(b.total_amount), 2) AS average_booking_amount,

        ROUND(
            SUM(
                CASE
                    WHEN b.payment_status = 'completed'
                    THEN 1 ELSE 0
                END
            ) * 100.0 / NULLIF(COUNT(b.id), 0),
            2
        ) AS completion_rate,

        ROUND(
            AVG(
                CASE
                    WHEN i.booking_id IS NOT NULL
                    THEN 1.0 ELSE 0.0
                END
            ) * 100,
            2
        ) AS insurance_rate

    FROM tours t
    LEFT JOIN bookings b
        ON t.id = b.tour_id
    LEFT JOIN (
        SELECT DISTINCT booking_id
        FROM insurance
    ) i
        ON b.id = i.booking_id
    GROUP BY
        t.id,
        t.name,
        t.destination,
        t.duration_days,
        t.price
)
SELECT *
FROM tour_metrics
ORDER BY completed_reservations DESC;

WITH tour_metrics AS (
    SELECT
        t.id AS tour_id,
        t.name AS tour_name,
        t.destination,
        t.duration_days,
        t.price,
        COUNT(b.id) AS total_reservations,

        SUM(
            CASE
                WHEN b.payment_status = 'completed'
                THEN 1 ELSE 0
            END
        ) AS completed_reservations,

        ROUND(
            AVG(
                CASE
                    WHEN b.payment_status = 'completed'
                    THEN 1.0 ELSE 0.0
                END
            ) * 100,
            2
        ) AS completion_rate,

        ROUND(
            AVG(
                CASE
                    WHEN i.booking_id IS NOT NULL
                    THEN 1.0 ELSE 0.0
                END
            ) * 100,
            2
        ) AS insurance_rate

    FROM tours t
    LEFT JOIN bookings b
        ON t.id = b.tour_id
    LEFT JOIN (
        SELECT DISTINCT booking_id
        FROM insurance
    ) i
        ON b.id = i.booking_id
    GROUP BY
        t.id,
        t.name,
        t.destination,
        t.duration_days,
        t.price
),
normalized AS (
    SELECT
        *,
        CASE
            WHEN MAX(completed_reservations) OVER () =
                 MIN(completed_reservations) OVER ()
            THEN 0
            ELSE
                (completed_reservations -
                 MIN(completed_reservations) OVER ()) * 100.0 /
                NULLIF(
                    MAX(completed_reservations) OVER () -
                    MIN(completed_reservations) OVER (),
                    0
                )
        END AS popularity_score,

        CASE
            WHEN MAX(price) OVER () = MIN(price) OVER ()
            THEN 0
            ELSE
                (MAX(price) OVER () - price) * 100.0 /
                NULLIF(
                    MAX(price) OVER () - MIN(price) OVER (),
                    0
                )
        END AS price_score,

        completion_rate AS completion_score,
        insurance_rate AS insurance_score

    FROM tour_metrics
)
SELECT
    tour_id,
    tour_name,
    destination,
    duration_days,
    price,
    total_reservations,
    completed_reservations,
    ROUND(popularity_score, 2) AS popularity_score,
    ROUND(price_score, 2) AS price_score,
    ROUND(completion_score, 2) AS completion_score,
    ROUND(insurance_score, 2) AS insurance_score,

    ROUND(
        popularity_score * 0.40 +
        price_score * 0.25 +
        completion_score * 0.20 +
        insurance_score * 0.15,
        2
    ) AS recommendation_score

FROM normalized
ORDER BY recommendation_score DESC
LIMIT 10;

