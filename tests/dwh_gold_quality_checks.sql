/*
===================================================================================================================
Script: Gold Layer Data Quality Checks
===================================================================================================================
Objective: This script performs data quality and validation checks for the Gold layer tables in the data warehouse.

The checks include:
1. Validation of data consistency and relationships in Gold layer tables.
2. Verification of primary key uniqueness.
3. Foreign key integrity checks between fact and dimension tables.
4. Validation of transformed and standardized values.
5. Identification of missing, unmatched, or orphan records.
6. Summary checks for overall data consistency.

Usage: This script is used to validate the accuracy, consistency, and integrity of the Gold layer before reporting
and analytics.
===================================================================================================================
*/

------------------------------------------------------------------------------------------
--->>> gold.dim_customer_info
------------------------------------------------------------------------------------------
---To check if all customer keys are present in silver.erp_cust_az12 and vice versa
SELECT
cst_key
FROM silver.crm_cust_info
WHERE cst_key NOT IN (SELECT * FROM silver.erp_cust_az12);

SELECT
cid
FROM silver.erp_cust_az12
WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info);

---To check if all customer keys are present in silver.erp_loc_a101 and vice versa
SELECT
cst_key
FROM silver.crm_cust_info
WHERE cst_key NOT IN (SELECT cid FROM silver.erp_loc_a101);

SELECT
cid
FROM silver.erp_loc_a101
WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info);

---To check and fix data quality issues in gender column
---Expectation: Return all unique possible combinations with new transformed column
SELECT
cc.cst_gndr,
ec.gen,
CASE WHEN cst_gndr <> 'N/A' THEN cst_gndr
     ELSE gen END
FROM silver.crm_cust_info cc
LEFT JOIN silver.erp_cust_az12 ec
ON cc.cst_key = ec.cid
LEFT JOIN silver.erp_loc_a101 el
ON cc.cst_key = el.cid
GROUP BY cc.cst_gndr, ec.gen;  --gives all unique possible combinations

---To check if all customer ids are unique in gold.dim_customer_info
---Expectation: No records should be returned
SELECT
customer_id
FROM gold.dim_customer_info
GROUP BY customer_id
HAVING COUNT(*) > 1;
--> Will use this as primary key in dim_customer_info to join silver.crm_sales_details

------------------------------------------------------------------------------------------
--->>> gold.dim_product_info
------------------------------------------------------------------------------------------
---To check if all product categories are present in silver.erp_px_cat_g1v2 and vice versa
SELECT
prd_cat_id
FROM silver.crm_prd_info
WHERE prd_cat_id NOT IN (SELECT id FROM silver.erp_px_cat_g1v2)
GROUP BY prd_cat_id;

SELECT
id
FROM
silver.erp_px_cat_g1v2
WHERE id NOT IN (SELECT prd_cat_id FROM silver.crm_prd_info);

---To handle all null values in silver.erp_px_cat_g1v2
---Expectation: Result should have no null values
SELECT
CASE WHEN pc.cat IS NULL THEN 'N/A'
     ELSE pc.cat END AS pc_cat,
CASE WHEN pc.subcat IS NULL THEN 'N/A'
     ELSE pc.subcat END pc_subcat,
CASE WHEN pc.maintenance IS NULL THEN 'N/A'
     ELSE pc.maintenance END pc_maintenance
FROM silver.crm_prd_info pp
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pp.prd_cat_id = pc.id
WHERE pc.id IS NULL;

---To check if all product ids are unique in gold.dim_product_info
---Expectation: No records should be returned
SELECT
product_number
FROM gold.dim_product_info
GROUP BY product_number
HAVING COUNT(*) > 1;
--> Will use this as primary key in dim_product_info to join silver.crm_sales_details

/*
==========================================================================================================
>>> One order can contain multiple products for the same customer.
>>> Hence, we can have multiple records with the same customer_key and order_id but different product_key.
>>> A customer can also purchase the same product in different orders over time.
>>> Therefore, customer_key and product_key can repeat across different orders.
>>> The unique combination in the fact table is: (order_id, customer_key, product_key)
==========================================================================================================
*/
------------------------------------------------------------------------------------------
--->>> gold.fact_sales_info
------------------------------------------------------------------------------------------
---To check if all customer ids are present in silver.crm_sales_details and vice versa
SELECT
customer_id
FROM gold.dim_customer_info
WHERE customer_id NOT IN (SELECT sls_cust_id FROM silver.crm_sales_details);

SELECT
sls_cust_id
FROM silver.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT customer_id FROM gold.dim_customer_info);

---To check if all product numbers are present in silver.crm_sales_details and vice versa
SELECT
product_number
FROM gold.dim_product_info
WHERE product_number NOT IN (SELECT sls_prd_key FROM silver.crm_sales_details);

SELECT
sls_prd_key
FROM silver.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT product_number FROM gold.dim_product_info);

---To check gold.fact_sales_info
SELECT
*
FROM gold.fact_sales_info
ORDER BY COUNT(*) OVER(PARTITION BY CUSTOMER_KEY) DESC, order_id ASC;

---To check the integrity of foreign keys (Dimension tables)
---Expectation: No records should be returned
SELECT
*
FROM gold.fact_sales_info s
WHERE NOT EXISTS (SELECT 1 FROM gold.dim_customer_info c WHERE s.customer_key = c.customer_key); --used NOT EXISTS for optimization

SELECT
*
FROM gold.fact_sales_info s
WHERE NOT EXISTS (SELECT 1 FROM gold.dim_product_info p WHERE s.product_key = p.product_key); --used NOT EXISTS for optimization

---Alternate way to check the integrity of foreign keys
---Expectation: No records should be returned
SELECT
*
FROM gold.fact_sales_info s
LEFT JOIN gold.dim_customer_info c
ON s.customer_key = c.customer_key
LEFT JOIN gold.dim_product_info p
ON s.product_key = p.product_key
WHERE c.customer_key IS NULL OR p.product_key IS NULL;

------------------------------------------------------------------------------------------
--->>>Checks for Business Insights
------------------------------------------------------------------------------------------
--->>>Total number of customers
SELECT
COUNT(*) total_customers
FROM gold.dim_customer_info

--->>>Total number of products
SELECT
COUNT(*) total_products
FROM gold.dim_product_info

--->>>Total number of sales
SELECT
COUNT(*) total_sales
FROM gold.fact_sales_info

--->>>Number of customers who have placed orders
SELECT
COUNT(customer_key) total_customers_in_sales
FROM gold.fact_sales_info

--->>>Number of products that have been ordered
SELECT
COUNT(product_key) total_products_in_sales
FROM gold.fact_sales_info

--->>>Number of distinct customers who have placed orders
SELECT
COUNT(DISTINCT customer_key) total_distinct_customers_in_sales
FROM gold.fact_sales_info

--->>>Number of distinct products that have been ordered
SELECT
COUNT(DISTINCT product_key) total_distinct_products_in_sales
FROM gold.fact_sales_info

--->>>To check customers who have not placed any orders
SELECT DISTINCT
*
FROM gold.dim_customer_info c
WHERE NOT EXISTS (SELECT 1 FROM gold.fact_sales_info s WHERE s.customer_key = c.customer_key); --used NOT EXISTS for optimization

--->>>To check products that have not been ordered
SELECT DISTINCT
*
FROM gold.dim_product_info p
WHERE NOT EXISTS (SELECT 1 FROM gold.fact_sales_info s WHERE s.product_key = p.product_key); --used NOT EXISTS for optimization
