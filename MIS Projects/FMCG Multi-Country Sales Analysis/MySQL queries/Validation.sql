
#1. We are trying to find out uniqueness of each record from considering a set of fields
---# If both 'total_rows' count and 'distinct_date_store_sku' count matches, then its unique
---# If doesn't match, then try another combination (like date_store_sku_channel) until we find uniqueness

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT CONCAT(
        sales_date, '|',
        store_id, '|',
        sku_id
    )) AS distinct_date_store_sku
FROM sales_record;					# From my servey, this combination matched perfectly
									---# So we can say this dataset can be uniquely defined by the least amount of fields: sales_date + store_id + sku_id



#2. As we got our primary key setup (date+store+sku), now we will make a new table 
---# that will contain the entire records from 'sales_record', but with unique identifiers

CREATE TABLE sales_analysis AS 
SELECT * FROM sales_record WHERE 1=0; 	# 1=0 is a FALSE statement, so it only creates the skeleton of the table with data types, zero records

ALTER TABLE sales_analysis 
ADD COLUMN sales_row_id INT AUTO_INCREMENT FIRST, 
ADD PRIMARY KEY (sales_row_id);

INSERT INTO sales_analysis SELECT NULL, s.* FROM sales_record s;
Select * from sales_analysis limit 20;



#3. Now a secondary table is created (sales_analysis), we will perform all analysis on this table
---# Now we need to create indexs for fields which will be going to be used a lot - for quick filtering, grouping

CREATE INDEX idx_sales_date ON sales_analysis(sales_date);
CREATE INDEX idx_sales_sku ON sales_analysis(sku_id(50));
CREATE INDEX idx_sales_store ON sales_analysis(store_id(50));
CREATE INDEX idx_sales_country ON sales_analysis(country(50));
CREATE INDEX idx_sales_category ON sales_analysis(category(50));
CREATE INDEX idx_sales_channel ON sales_analysis(channel(50));
CREATE INDEX idx_sales_promo ON sales_analysis(promo_flag);



