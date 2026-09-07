---# Q13. How does category/brand performance differ by channels?
-------------------------------------------------------------------
SELECT
    channel,
    category,
    SUM(units_sold) AS total_units_sold,
    SUM(net_sales) AS total_net_sales
FROM sales_analysis
GROUP BY
    channel,
    category
ORDER BY
    channel,
    total_net_sales DESC;		# This shows us channel performance based on categories
    
    
---# Q14. How does promotional and non-promotional sales compare?
-----------------------------------------------------------------
SELECT
    promo_flag,
    COUNT(*) AS record_count,
    SUM(units_sold) AS total_units_sold,
    SUM(gross_sales) AS total_gross_sales,
    SUM(net_sales) AS total_net_sales,
    AVG(discount_pct) AS average_discount_pct
FROM sales_analysis
GROUP BY promo_flag;


---# Q15. Does higher discount refers to higher sales?
------------------------------------------------------
SELECT
    CASE
        WHEN discount_pct = 0 THEN '0%'
        WHEN discount_pct <= 5 THEN '1-5%'
        WHEN discount_pct <= 10 THEN '6-10%'
        WHEN discount_pct <= 20 THEN '11-20%'
        ELSE '20%+'
    END AS discount_band,
    COUNT(*) AS record_count,
    SUM(units_sold) AS total_units_sold,
    AVG(units_sold) AS average_units_sold,
    SUM(net_sales) AS total_net_sales,
    AVG(margin_pct) AS average_margin_pct
FROM sales_analysis
GROUP BY
    CASE
        WHEN discount_pct = 0 THEN '0%'
        WHEN discount_pct <= 5 THEN '1-5%'
        WHEN discount_pct <= 10 THEN '6-10%'
        WHEN discount_pct <= 20 THEN '11-20%'
        ELSE '20%+'
    END
ORDER BY
    discount_band;
    
    
---# Q16. Which Products/Channels are most dependent on promotional activities?
-------------------------------------------------------------------------------
SELECT
    sku_id,
    sku_name,
    SUM(units_sold) AS total_units,
    SUM(
        CASE
            WHEN promo_flag = 1 THEN units_sold
            ELSE 0
        END
    ) AS promotional_units,
    ROUND(
        SUM(
            CASE
                WHEN promo_flag = 1 THEN units_sold
                ELSE 0
            END
        ) / SUM(units_sold) * 100,
        2
    ) AS promotional_units_pct
FROM sales_analysis
GROUP BY
    sku_id,
    sku_name
HAVING SUM(units_sold) > 0
ORDER BY promotional_units_pct DESC
LIMIT 20;		# Returns top 20 products in units (%) sold as promotional sales compared to lifetime sales


---# Q17. Which products generate highest margins?
--------------------------------------------------
SELECT
    sku_id,
    sku_name,
    category,
    SUM(net_sales) AS total_net_sales,
    SUM(units_sold) AS total_units_sold,
    AVG(margin_pct) AS average_margin_pct
FROM sales_analysis
GROUP BY
    sku_id,
    sku_name,
    category
ORDER BY average_margin_pct DESC
LIMIT 20;


---# Q18. Which products have high revenue but weak margin (less than 38%)?
-----------------------------------------------------------
SELECT
    sku_id,
    sku_name,
    category,
    SUM(net_sales) AS total_net_sales,
    AVG(margin_pct) AS average_margin_pct
FROM sales_analysis
GROUP BY
    sku_id,
    sku_name,
    category
HAVING AVG(margin_pct) < 0.38	
ORDER BY total_net_sales DESC
LIMIT 20;		# Returns list of products which have avg_margin < 38% but with high sales


---# Q19. Which products face the highest stockout exposure?
------------------------------------------------------------
SELECT
    sku_id,
    sku_name,
    SUM(stock_out_flag) AS stockout_records,
    COUNT(*) AS total_records,
    ROUND(
        SUM(stock_out_flag) / COUNT(*) * 100,
        2
    ) AS stockout_rate_pct
FROM sales_analysis
GROUP BY
    sku_id,
    sku_name
ORDER BY stockout_rate_pct DESC
LIMIT 20;


---# Q20. Is Stockout exposue concentrated among particular cities, stores?
------------------------------------------------------------------------------------------------
SELECT
    city, store_id,
    SUM(stock_out_flag) AS stockout_records,
    COUNT(*) AS total_records,
    ROUND(
        SUM(stock_out_flag) / COUNT(*) * 100,
        2
    ) AS stockout_rate_pct
FROM sales_analysis
GROUP BY city,store_id
ORDER BY stockout_rate_pct DESC;


---# Q21. Which products combine high demand with high volatility?
-------------------------------------------------------------------------
SELECT
    sku_id,
    sku_name,
    AVG(units_sold) AS average_units_sold,
    SUM(units_sold) AS total_units_sold,
    STDDEV(units_sold) AS demand_stddev
FROM sales_analysis
GROUP BY
    sku_id,
    sku_name
ORDER BY demand_stddev DESC
LIMIT 20;		# Gives us demand statistics

SELECT
    sku_id,
    sku_name,
    AVG(units_sold) AS average_units_sold,
    STDDEV(units_sold) AS demand_stddev,
    STDDEV(units_sold) / AVG(units_sold) AS coefficient_of_variation
FROM sales_analysis
GROUP BY
    sku_id,
    sku_name
HAVING AVG(units_sold) > 0
ORDER BY coefficient_of_variation DESC
LIMIT 20;		# Gives us high volatility products


---# Q22. How ABC and XYZ classifications compare?
--------------------------------------------------
SELECT
    sku_id,
    sku_name,
    SUM(net_sales) AS total_net_sales
FROM sales_analysis
GROUP BY
    sku_id,
    sku_name
ORDER BY total_net_sales DESC;		# Export this full result, then calculate Cumulative Revenue (CR) where. A = 80% of CR, B = 15% of CR and C= 5% of CR

SELECT
    sku_id,
    sku_name,
    AVG(units_sold) AS average_units_sold,
    STDDEV(units_sold) AS demand_stddev,
    STDDEV(units_sold) / AVG(units_sold) AS CV
FROM sales_analysis
GROUP BY
    sku_id,
    sku_name
HAVING AVG(units_sold) > 0
ORDER BY CV;		# Export this result and then categorized CV based on X = low variability, Y = medium and Z = high variability


---# Q23. Where are the largest commercial growth opportunities?
----------------------------------------------------------------
# Opportunity 1: High revenue products
SELECT
    country,
    sku_id,
    sku_name,
    category,
    SUM(net_sales) AS total_net_sales,
    AVG(margin_pct) AS average_margin_pct
FROM sales_analysis
GROUP BY
    country,
    sku_id,
    sku_name,
    category
ORDER BY total_net_sales DESC
LIMIT 20;

# Opportunity 2: High demand products with stockouts
SELECT
    country,
    sku_id,
    sku_name,
    SUM(units_sold) AS total_units_sold,
    SUM(stock_out_flag) AS stockout_records,
    ROUND(
        SUM(stock_out_flag) / COUNT(*) * 100,
        2
    ) AS stockout_rate_pct
FROM sales_analysis
GROUP BY
   country,
   sku_id,
	sku_name
HAVING SUM(units_sold) > 0
ORDER BY
    total_units_sold DESC,
    stockout_rate_pct DESC
LIMIT 20;