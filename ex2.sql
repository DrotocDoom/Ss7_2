CREATE TABLE customer (
                          customer_id SERIAL PRIMARY KEY,
                          full_name VARCHAR(100),
                          email VARCHAR(100),
                          phone VARCHAR(15)
);

CREATE TABLE orders (
                        order_id SERIAL PRIMARY KEY,
                        customer_id INT REFERENCES customer(customer_id),
                        total_amount DECIMAL(10,2),
                        order_date DATE
);

INSERT INTO customer(full_name, email, phone)
SELECT
    'Customer ' || g,
    'customer' || g || '@gmail.com',
    '09' || LPAD((g % 100000000)::text, 8, '0')
FROM generate_series(1, 500000) g;

INSERT INTO orders(customer_id, total_amount, order_date)
SELECT
    (random() * 499999 + 1)::INT,
    ROUND((random() * 10000000)::numeric, 2),
    CURRENT_DATE - ((random() * 365)::INT)
FROM generate_series(1, 500000);

SELECT * FROM customer;

SELECT * FROM orders;

CREATE VIEW customer_orders AS
SELECT
    c.full_name,
    o.total_amount,
    o.order_date FROM customer c
INNER JOIN orders o
    ON c.customer_id = o.customer_id;

SELECT * FROM customer_orders;

CREATE VIEW v_large_orders AS
SELECT
    order_id,
    customer_id,
    total_amount,
    order_date
FROM orders
WHERE total_amount >= 1000000;

SELECT * FROM v_large_orders;
UPDATE v_large_orders SET total_amount = total_amount * 0.9
WHERE order_id = 1;

CREATE VIEW v_monthly_sales AS
    SELECT
        EXTRACT(YEAR FROM order_date) as year,
        EXTRACT(MONTH FROM order_date) as month,
        SUM(total_amount) AS total_sales
    FROM orders
    GROUP BY year, month;

SELECT * FROM v_monthly_sales
ORDER BY year, month;

DROP VIEW v_monthly_sales;
DROP VIEW v_large_orders;
DROP VIEW customer_orders;
