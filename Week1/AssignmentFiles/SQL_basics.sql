USE coffeeshop_db;

-- =========================================================
-- BASICS PRACTICE
-- Instructions: Answer each prompt by writing a SELECT query
-- directly below it. Keep your work; you'll submit this file.
-- =========================================================

-- Q1) List all products (show product name and price), sorted by price descending.

SELECT name,
price
FROM products
ORDER BY price DESC;

-- Q2) Show all customers who live in the city of 'Lihue'.

SELECT *
FROM customers
WHERE city = 'Lihue';

-- Q3) Return the first 5 orders by earliest order_datetime (order_id, order_datetime).
SELECT order_id,
date_format(order_datetime, '%m/%d/%Y') as order_date -- love this
FROM orders
ORDER BY order_datetime ASC

LIMIT 5;

-- Q4) Find all products with the word 'Latte' in the name.

SELECT *
FROM products
WHERE lower(name) LIKE '%Latte%'; -- just in case we have a 'latte' somewhere

-- Q5) Show distinct payment methods used in the dataset.

SELECT DISTINCT payment_method
FROM orders;

-- Q6) For each store, list its name and city/state (one row per store).

SELECT name,
city,
state
FROM stores;

-- Q7) From orders, show order_id, status, and a computed column total_items
--     that counts how many items are in each order.

SELECT o.order_id,
o.status,
SUM(i.quantity) AS total_items
FROM orders o
LEFT JOIN order_items i
ON i.order_id = o.order_id
GROUP BY o.order_id,
o.status;

-- Q8) Show orders placed on '2025-09-04' (any time that day).

SELECT *
FROM orders
WHERE order_datetime BETWEEN '2025-09-04 00:00:00' AND '2025-09-04 23:59:59'; -- Not proud of this haha but it works?

-- Q9) Return the top 3 most expensive products (price, name).

SELECT name,
price
FROM products
ORDER BY price DESC

LIMIT 3;

-- Q10) Show customer full names as a single column 'customer_name'
--      in the format "Last, First".

SELECT employee_id,
store_id,
concat(last_name, ', ',first_name) as customer_name,
title,
hire_date
FROM employees;

