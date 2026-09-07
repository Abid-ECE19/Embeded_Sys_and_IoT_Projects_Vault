create database FMCG_recordbook;
use fmcg_recordbook;
set global local_infile=1;


# Load the heavy dataset (Cleaned_FMCG_Sales.csv)
LOAD DATA LOCAL INFILE 'F:/MIS MTO Projects/FMCG Sales Analytics/2_Cleaned Data/Cleaned_FMCG_Sales.csv' 
INTO TABLE sales_record
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 LINES;

truncate table fmcg_recordbook.sales_record;

# Count records & columns of the dataset
select count(*) from sales_record;
SELECT COUNT(*) AS column_count
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'fmcg_recordbook'
AND TABLE_NAME = 'sales_record';

# See first 10 rows of the dataset & check data types
SELECT * FROM sales_record LIMIT 10;
describe sales_record;

# Fix the 'date' field data type (it should be as DATE type, not TEXT type)
ALTER TABLE sales_record
CHANGE COLUMN `date` sales_date DATE;

# One final checking of nulls before moving to analysis
SELECT
    SUM(sales_date IS NULL) AS null_date,
    SUM(store_id IS NULL) AS null_store,
    SUM(sku_id IS NULL) AS null_sku,
    SUM(units_sold IS NULL) AS null_units,
    SUM(net_sales IS NULL) AS null_net_sales,
    SUM(stock_on_hand IS NULL) AS null_stock,
    SUM(purchase_cost IS NULL) AS null_purchase_cost
FROM sales_record;

# Checking the sale_date range
SELECT
    MIN(sales_date) AS first_date,
    MAX(sales_date) AS last_date
FROM sales_record;

SELECT year, COUNT(*) AS rows
FROM sales_record
GROUP BY year
ORDER BY year;





