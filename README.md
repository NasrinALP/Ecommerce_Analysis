# E-commerce KPI Analysis

This project implements a SQL database for e-commerce analytics, focusing on customer, product, order, and payment data to calculate key business metrics. Moreover, some of these metrics are visualized in Power BI.

## Database Structure
•	customers: customer_id, name, gender, age group, region
•	products: product_id, category, sub-category, name, cost & unit price
•	orders: order_id, customer_id, order & ship dates, ship mode, region
•	order_items: order details including quantity, discount, profit
•	payments: payment details including method, amount, and status

## Key Metrics & KPIs
•	Total Revenue and Average Order Value (AOV)
•	Sales by Region and Monthly Revenue Trend
•	Top 5 Product Categories (by number sold and revenue)
•	Customer Retention & Lifetime Orders
•	Returning vs. New Customers

## Analysis Approach
•	Data aggregated using WITH CTE queries
•	Joined tables to calculate revenue, sales trends, and retention rates
•	Focused on paid orders to ensure accurate KPIs

## Tech Stack
•	MySQL / MariaDB
•	SQL queries for data aggregation, joins, and KPI calculations
•	Power BI for visualization
Author: Nasrin Alipour | MSc in Biomedical Informatics Engineering – Amirkabir University of Technology
