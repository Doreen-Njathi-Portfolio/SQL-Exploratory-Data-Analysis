/* 
SQL EXPLORATORY DATA ANALYSIS (EDA) PROJECT

An SQL project where I explore, clean, and analyze data, to understand the data and gain insights into this business
using basic SQL skills:
	1.	Basic queries
	2.	Data profiling
	3.	Simple aggregations
	4.	Subquery

The database used is provided in a separate script. 

The project is carried out in 6 main phases: 
   1. Database exploration
   2. Dimension exploration
   3. Date exploration
   4. Measures exploration
   5. Magnitude analysis
   6. Ranking analysis: Top N - Bottom N

----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------

1.	DATABASE EXPLORATION


-- Explore objects in the database */

SELECT * FROM INFORMATION_SCHEMA.TABLES

-- Explore columns in the database

SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name ='dim_customers'

------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------

-- 2. DIMENSION EXPLORATION 


-- Explore all countries our customers come from 

SELECT DISTINCT country FROM dim_customers

-- Explore all product categories, the major divisions

SELECT DISTINCT category, subcategory, product_name FROM dim_products
ORDER BY 1,2,3

-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------

-- 3. DATE EXPLORATION

-- Find the date of the 1st and last order
-- How many years of the sales are available

SELECT 
MIN (order_date) AS first_order_date,
MAX (order_date) AS last_order_date,
DATEDIFF (YEAR, MIN (order_date), MAX (order_date)) AS order_range_years
FROM fact_sales

-- Find the youngest and the oldest customer

SELECT 
MIN (birthdate) AS oldest,
DATEDIFF (YEAR, MIN (birthdate), GETDATE ()) AS oldest_age,
max (birthdate) AS youngest,
DATEDIFF (YEAR, MAX (birthdate), GETDATE ()) AS youngest_age
FROM dim_customers

---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------

-- 4. MEASURES EXPLORATION

-- Find the total sales

SELECT
SUM(sales_amount) AS total_sales
FROM fact_sales

-- Find how many items were sold

SELECT
SUM(quantity) AS total_quantity
FROM fact_sales

-- Find the average selling price

SELECT
AVG (price) AS average_price
FROM fact_sales

-- Find the total No. orders

SELECT
COUNT (order_number) AS total_orders
FROM fact_sales

--> use the same count query but use distinct so as to eliminate counting duplicates. 

SELECT
COUNT (DISTINCT order_number) AS total_orders
FROM fact_sales
 
-- Find the total No. products

SELECT
COUNT (DISTINCT product_id) AS total_products
FROM dim_products
** --> you can also use product_key or even product_name.

-- Find the total No. customers

SELECT
COUNT (customer_id) AS No_customers
FROM dim_customers

-- Find the total No. customers that placed an order

SELECT
COUNT (DISTINCT customer_key) AS No_customers_who_ordered
FROM fact_sales

-- Generate report that shows all key metrics of the business

SELECT 'TOTAL SALES' AS measure_name, SUM(sales_amount) AS measure_value FROM fact_sales
UNION ALL
SELECT 'TOTAL QUANTITY' AS measure_name, SUM(quantity) AS measure_value FROM fact_sales
UNION ALL
SELECT 'AVERAGE PRICE' AS measure_name, AVG (price) AS measure_value FROM fact_sales
UNION ALL
SELECT 'TOTAL ORDERS' AS measure_name, COUNT (DISTINCT order_number) AS measure_value FROM fact_sales
UNION ALL
SELECT 'TOTAL PRODUCTS' AS measure_name, COUNT (DISTINCT product_id) AS measure_value FROM dim_products
UNION ALL
SELECT 'NO. CUSTOMERS' AS measure_name, COUNT (customer_id) AS measure_value FROM dim_customers
UNION ALL
SELECT 'NO. CUSTOMERS THAT ORDERED' AS measure_name, COUNT (DISTINCT customer_key) AS measure_value FROM fact_sales

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 5. MAGNITUDE ANALYSIS

-- Find total customers by countries

SELECT 
country,
COUNT (customer_id) AS total_customers
FROM dim_customers
GROUP BY country
ORDER BY total_customers DESC

-- Find total customers by gender

SELECT
gender,
COUNT (customer_key) AS total_customers
FROM dim_customers
GROUP BY gender
ORDER BY total_customers DESC

-- Find total products by category

SELECT
category,
COUNT (product_key) AS total_products
FROM dim_products
GROUP BY category
ORDER BY total_products DESC

-- What is the average costs in each category?

SELECT
category,
AVG (cost) AS average_cost
FROM dim_products
GROUP BY category
ORDER BY average_cost DESC

-- What total revenue generated for each category?

SELECT 
d.category,
SUM (f.sales_amount) AS total_revenue
FROM fact_sales f
left join dim_products d
ON f.product_key = d.product_key
GROUP BY category
ORDER BY total_revenue DESC

-- Find the total revenue generated by each customer

SELECT 
c.customer_key,
c.first_name,
c.last_name,
SUM (s.sales_amount) AS total_revenue
FROM fact_sales s
left join dim_customers c
ON s.customer_key = c.customer_key
GROUP BY 
c.customer_key,
c.first_name,
c.last_name
ORDER BY total_revenue DESC

-- What is the distribution of sold items (total quantity) across countries?

SELECT 
c.country,
SUM (s.quantity) AS total_quantity
FROM fact_sales s
left join dim_customers c
ON s.customer_key = c.customer_key
GROUP BY c.country
ORDER BY total_quantity DESC

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 6. RANKING ANALYSIS

-- Which 5 products generate the highest revenue?

SELECT TOP 5
d.product_name,
SUM (f.sales_amount) AS total_revenue
FROM fact_sales f
left join dim_products d
ON f.product_key = d.product_key
GROUP BY d.product_name
ORDER BY total_revenue DESC

** --> Alternatively, using windows function

SELECT * 
FROM (
	SELECT 
	d.product_name,
	SUM (f.sales_amount) AS total_revenue,
	ROW_NUMBER () OVER (ORDER BY SUM (f.sales_amount) DESC) AS rank_products
	FROM fact_sales f
	left join dim_products d
	ON f.product_key = d.product_key
	GROUP BY d.product_name )t
WHERE rank_products <= 5

-- What are the 5 worst performing products in terms of sales?

SELECT TOP 5
d.product_name,
SUM (f.sales_amount) AS total_revenue
FROM fact_sales f
left join dim_products d
ON f.product_key = d.product_key
GROUP BY d.product_name
ORDER BY total_revenue 

** --> Alternatively, using windows function

SELECT * 
FROM (
	SELECT 
	d.product_name,
	SUM (f.sales_amount) AS total_revenue,
	ROW_NUMBER () OVER (ORDER BY SUM (f.sales_amount)) AS rank_products
	FROM fact_sales f
	left join dim_products d
	ON f.product_key = d.product_key
	GROUP BY d.product_name )t
WHERE rank_products <= 5

-- Find the top 10 customers who have generated the highest revenue 

SELECT TOP 10
c.customer_key,
c.first_name,
c.last_name,
SUM (s.sales_amount) AS total_revenue
FROM fact_sales s
left join dim_customers c
ON s.customer_key = c.customer_key
GROUP BY 
c.customer_key,
c.first_name,
c.last_name
ORDER BY total_revenue DESC

-- 3 customers with the fewest orders placed.

SELECT TOP 3
c.customer_key,
c.first_name,
c.last_name,
COUNT (DISTINCT order_number) AS total_orders
from fact_sales s
left join dim_customers c
ON s.customer_key = c.customer_key
GROUP BY 
c.customer_key,
c.first_name,
c.last_name
ORDER BY total_orders