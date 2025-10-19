CREATE DATABASE ecommerce_kpi;
USE ecommerce_kpi;

CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100),
    gender VARCHAR(10),
    age_group VARCHAR(20),
    region VARCHAR(50)
);

CREATE TABLE products (
    product_id VARCHAR(20) PRIMARY KEY,
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(150),
    cost_price DECIMAL(10,2),
    unit_price DECIMAL(10,2)
);

CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(30),
    region VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(20),
    product_id VARCHAR(20),
    quantity INT,
    discount DECIMAL(5,2),
    profit DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(20),
    payment_method VARCHAR(30),
    payment_amount DECIMAL(10,2),
    payment_status VARCHAR(30),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

SELECT * FROM customers;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM payments;
SELECT * FROM products;



-- KPI Calculation

-- Total Revenue
WITH cte_rev as
(SELECT sum(payment_amount), payment_status
FROM payments
GROUP BY payment_status
)
SELECT * FROM cte_rev
WHERE payment_status = 'Paid';



-- Average Order Value (AOV)
WITH cte_aov as
(SELECT AVG(payment_amount), payment_status
FROM payments
GROUP BY payment_status
)
SELECT * FROM cte_aov
WHERE payment_status = 'Paid';



-- Sales by Region
WITH cte_sbr AS
(SELECT orders.order_id, orders.customer_id, orders.region, payments.payment_amount, payments.payment_status
FROM orders
LEFT JOIN payments ON payments.order_id = orders.order_id
)
SELECT region, SUM(payment_amount) AS total_sales
FROM cte_sbr
WHERE payment_status='Paid'
GROUP BY orders.region;


-- Top 5 Product Categories (by number)
WITH cte_cat AS
(SELECT order_items.product_id, quantity, category
FROM order_items
LEFT JOIN products ON order_items.product_id = products.product_id
)
SELECT DISTINCT category, SUM(quantity) over(partition by category) AS sold_num
FROM cte_cat
ORDER BY sales DESC;


-- Top 5 Product Categories (by revenue)
WITH cte_cat AS
(SELECT order_items.product_id, quantity, discount, category, unit_price
FROM order_items
LEFT JOIN products ON order_items.product_id = products.product_id
)
SELECT  category, SUM(quantity* (unit_price*(1- discount))) AS sales
FROM cte_cat
GROUP BY category
ORDER BY sales DESC;


-- Monthly Revenue Trend
WITH cte_mon AS
(SELECT orders.order_id, order_date, payment_amount, payment_status
FROM payments
LEFT JOIN orders ON orders.order_id = payments.order_id
)
SELECT substring(order_date, 1, 7) AS month_num, sum(payment_amount)
FROM cte_mon
WHERE payment_status= 'Paid'
GROUP BY  month_num;

-- Returning vs. New Customers
WITH cte_ret AS
(SELECT customer_id,
 CASE 
	WHEN count(customer_id)=1 THEN 'new_customer'
    WHEN count(customer_id)>1 THEN 'returning_customer'
END AS Retention_status
FROM orders
GROUP BY customer_id
)
SELECT Retention_status, COUNT(Retention_status) AS customers_number
FROM cte_ret
GROUP BY Retention_status;



-- Average Customer Lifetime Orders
WITH cte_avg AS
(SELECT COUNT(order_id) as num
FROM orders
GROUP BY customer_id
)
SELECT AVG(num) FROM cte_avg;



-- Customer Retention Rate (Month-over-Month)
-- measures how many customers who made a purchase in a month also made another purchase in the following month.
WITH monthly_orders AS (
SELECT substring(order_date,6,2)+1 AS order_month, COUNT(order_id) as count_month
FROM orders
GROUP BY order_month
ORDER BY order_month
),

retention AS
(with report AS 
(WITH rep AS
(SELECT order_id, customer_id, substring(order_date,6,2)+0 AS order_month, row_number()over(partition by customer_id) AS order_rank
FROM orders
ORDER BY customer_id
)

SELECT DISTINCT r1.customer_id, r1.order_month FROM rep as r1
JOIN rep as r2 ON r1.customer_id = r2.customer_id and r1.order_month= r2.order_month+1
)
SELECT order_month, COUNT(order_month) as count_order
FROM report
GROUP BY order_month
)
SELECT retention.order_month AS `(x-1) -> x month`, (retention.count_order /monthly_orders.count_month)*100 AS Retention_percentage
FROM monthly_orders
LEFT JOIN retention ON retention.order_month= monthly_orders.order_month
WHERE not isnull(retention.order_month);





