---# Q1. What are the overall sales volume & estimated gross revenue of the entire business timeline?
-----------------------------------------------------------------------------------------------------
SELECT
    SUM(units_sold) AS total_units_sold,
    SUM(gross_sales) AS total_gross_sales,
    SUM(net_sales) AS total_net_sales,
    AVG(net_sales) AS average_row_net_sales
FROM sales_analysis;		# Gives us overall sales volume

SELECT
    SUM(units_sold * purchase_cost) AS total_product_cost
FROM sales_analysis;		# Gives us total cost

SELECT
    SUM(net_sales - (units_sold * purchase_cost)) AS estimated_gross_profit
FROM sales_analysis;		# Gives us total gross revenue


---# Q2. How does revenue & sales volume change over time?
----------------------------------------------------------
SELECT
    YEAR(sales_date) AS year,
    MONTH(sales_date) AS month,
    SUM(units_sold) AS units_sold,
    SUM(net_sales) AS net_sales,
	SUM(net_sales - (units_sold * purchase_cost)) AS gross_profit
FROM sales_analysis
GROUP BY
    YEAR(sales_date),
    MONTH(sales_date)
ORDER BY
    year,
    month;		# Returns total units sold, net sales and gross revenue of 12*3 = 36 months
    
    
---# Q3. What is the month over month revenue growth?
-----------------------------------------------------
SELECT
    YEAR(sales_date) AS year,
    MONTH(sales_date) AS month,
    SUM(net_sales) AS net_sales
FROM sales_analysis
GROUP BY
    YEAR(sales_date),
    MONTH(sales_date)
ORDER BY
    year,
    month;		# This gives us sales record of each month, now calculate the result further in Excel to get MoM sales
    

---# Q4. What is the year over year sales growth?
-------------------------------------------------
SELECT
    YEAR(sales_date) AS year,
    SUM(net_sales) AS net_sales
FROM sales_analysis
GROUP BY
    YEAR(sales_date)
ORDER BY
    year;		# This gives us sales record of each year, now calculate the result further in Excel to get YoY sales
    
    
---# Q5. What are the top 20 SKUs/Products by revenue?
------------------------------------------------------
SELECT
    sku_id,
    sku_name,
    category,
    brand,
    SUM(net_sales) AS total_net_sales
FROM sales_analysis
GROUP BY
    sku_id,
    sku_name,
    category,
    brand
ORDER BY total_net_sales DESC
LIMIT 20;


---# Q6. Which top 20 product has the highest sales volume?
----------------------------------------------------
SELECT
    sku_id,
    sku_name,
    category,
    SUM(units_sold) AS total_units_sold
FROM sales_record
GROUP BY
    sku_id,
    sku_name,
    category
ORDER BY total_units_sold DESC
LIMIT 20;


---# Q7. Which Categories & Brands generate the most revenue?
-------------------------------------------------------------
SELECT
    category,
    SUM(units_sold) AS total_units_sold,
    SUM(net_sales) AS total_net_sales,
    AVG(margin_pct) AS average_margin_pct
FROM sales_analysis
GROUP BY category
ORDER BY total_net_sales DESC;		# Gives us categories

SELECT
    brand,
    SUM(units_sold) AS total_units_sold,
    SUM(net_sales) AS total_net_sales,
    AVG(margin_pct) AS average_margin_pct
FROM sales_analysis
GROUP BY brand
ORDER BY total_net_sales DESC;		# Gives us brands


---# Q8. Which Products & Categories are underperforming?
---------------------------------------------------------
SELECT
    sku_id,
    sku_name,
    category,
    SUM(units_sold) AS total_units_sold,
    SUM(net_sales) AS total_net_sales,
    AVG(margin_pct) AS average_margin_pct
FROM sales_analysis
GROUP BY
    sku_id,
    sku_name,
    category
ORDER BY total_net_sales ASC
LIMIT 10;		# Gives us 10 least performing Products

SELECT
    category,
    SUM(units_sold) AS total_units_sold,
    SUM(net_sales) AS total_net_sales,
    AVG(margin_pct) AS average_margin_pct
FROM sales_analysis
GROUP BY category
ORDER BY total_net_sales ASC;		# Gives us categories garded from low to high


---# Q9. Which country generates highest revenue?
-------------------------------------------------
SELECT
    country,
    SUM(units_sold) AS total_units_sold,
    SUM(net_sales) AS total_net_sales
FROM sales_analysis
GROUP BY country
ORDER BY total_net_sales DESC;


---# Q10. Which cities and stores are the top & least performers?
-----------------------------------------------------------------
SELECT
    country,
    city,
    SUM(units_sold) AS total_units_sold,
    SUM(net_sales) AS total_net_sales
FROM sales_analysis
GROUP BY
    country,
    city
ORDER BY total_net_sales DESC;		# Gives us top performing cities

SELECT
    store_id,
    country,
    city,
    SUM(units_sold) AS total_units_sold,
    SUM(net_sales) AS total_net_sales
FROM sales_analysis
GROUP BY
    store_id,
    country,
    city
ORDER BY total_net_sales DESC
LIMIT 20;		# Gives us top 20 performing stores

SELECT
    store_id,
    country,
    city,
    SUM(units_sold) AS total_units_sold,
    SUM(net_sales) AS total_net_sales
FROM sales_analysis
GROUP BY
    store_id,
    country,
    city
ORDER BY total_net_sales ASC
LIMIT 20;		# Gives us 20 least performing stores 


---# Q11. Which markets have high revenue but weak growth?
----------------------------------------------------------
SELECT
    country,
    YEAR(sales_date) AS year,
    SUM(net_sales) AS net_sales
FROM sales_analysis
GROUP BY
    country,
    YEAR(sales_date)
ORDER BY
    country,
    year;		# This gives us country-wise list of low to high sales record
    
    
---# Q12. Which sales channels generate the highest revenue and sales volume?
-----------------------------------------------------------------------------
SELECT
    channel,
    SUM(units_sold) AS total_units_sold,
    SUM(net_sales) AS total_net_sales
FROM sales_analysis
GROUP BY channel
ORDER BY total_net_sales DESC;
    