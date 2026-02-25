-- Olist E-Commerce Data Analytics
-- SQL Analysis Queries
-- Author: Nitesh Sharma


CREATE DATABASE olist_ecommerce;
USE olist_ecommerce;


-- TABLE CREATION


CREATE TABLE orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(20),
    order_purchase_timestamp VARCHAR(50),
    order_approved_at VARCHAR(50),
    order_delivered_carrier_date VARCHAR(50),
    order_delivered_customer_date VARCHAR(50),
    order_estimated_delivery_date VARCHAR(50)
);

CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date VARCHAR(50),
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2)
);

CREATE TABLE customers (
    customer_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix VARCHAR(10),
    customer_city VARCHAR(50),
    customer_state VARCHAR(5)
);

CREATE TABLE payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(20),
    payment_installments INT,
    payment_value DECIMAL(10,2)
);

CREATE TABLE products (
    product_id VARCHAR(50),
    product_category_name VARCHAR(100),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);


-- DATA VALIDATION

SELECT 'orders' as table_name, COUNT(*) as total FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'payments', COUNT(*) FROM payments
UNION ALL
SELECT 'products', COUNT(*) FROM products;



-- ANALYSIS QUERIES

-- 1. Total Revenue
SELECT 
    ROUND(SUM(price + freight_value), 2) AS total_revenue
FROM order_items;


-- 2.Top 10 Product Categories by Revenue
SELECT 
    p.product_category_name,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS revenue,
    COUNT(oi.order_id) AS total_orders
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY revenue DESC
LIMIT 10;


-- 3. Month Wise Orders Trend
SELECT 
    YEAR(STR_TO_DATE(order_purchase_timestamp, '%d-%m-%Y %H:%i')) AS year,
    MONTH(STR_TO_DATE(order_purchase_timestamp, '%d-%m-%Y %H:%i')) AS month,
    COUNT(*) AS total_orders
FROM orders
WHERE order_status = 'delivered'
GROUP BY year, month
ORDER BY year, month;


-- 4. Average Order Value
SELECT 
    ROUND(AVG(order_total), 2) AS avg_order_value
FROM (
    SELECT 
        order_id,
        SUM(price + freight_value) AS order_total
    FROM order_items
    GROUP BY order_id
) AS order_summary;


-- 5. Top 10 States by Customers
SELECT 
    customer_state,
    COUNT(*) AS total_customers
FROM customers
GROUP BY customer_state
ORDER BY total_customers DESC
LIMIT 10;


-- 6. Average Delivery Time
SELECT 
    ROUND(AVG(DATEDIFF(
        STR_TO_DATE(order_delivered_customer_date, '%d-%m-%Y %H:%i'),
        STR_TO_DATE(order_purchase_timestamp, '%d-%m-%Y %H:%i')
    )), 1) AS avg_delivery_days
FROM orders
WHERE order_status = 'delivered'
AND order_delivered_customer_date != '';


-- 7. Popular Payment Methods
SELECT 
    payment_type,
    COUNT(*) AS total_transactions,
    ROUND(SUM(payment_value), 2) AS total_value
FROM payments
GROUP BY payment_type
ORDER BY total_transactions DESC;


-- 8. Late Deliveries
SELECT 
    COUNT(*) AS late_deliveries,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders WHERE order_status = 'delivered'), 2) AS late_percentage
FROM orders
WHERE order_status = 'delivered'
AND STR_TO_DATE(order_delivered_customer_date, '%d-%m-%Y %H:%i') > 
    STR_TO_DATE(order_estimated_delivery_date, '%d-%m-%Y %H:%i');
    

-- 9. Monthly Revenue Trend
SELECT 
    YEAR(STR_TO_DATE(order_purchase_timestamp, '%d-%m-%Y %H:%i')) AS year,
    MONTH(STR_TO_DATE(order_purchase_timestamp, '%d-%m-%Y %H:%i')) AS month,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS monthly_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY year, month
ORDER BY year, month;


-- 10. Order Status Breakdown
SELECT 
    order_status,
    COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS percentage
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;