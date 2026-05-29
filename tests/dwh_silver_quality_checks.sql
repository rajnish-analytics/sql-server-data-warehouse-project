/*
====================================================================================================
Script: Silver Layer Data Quality Checks
====================================================================================================
Objective: Validate Silver layer data to ensure all required transformations, standardization, and 
data quality checks have been applied correctly.

The checks include:
1. duplicates
2. null values
3. invalid dates
4. invalid numeric values
5. whitespace issues
6. hidden control characters
7. cardinality anomalies

Notes:
1. Used DATALENGTH() instead of LEN() for whitespace checks because LEN() ignores trailing spaces.
2. sp_help 'silver.crm_cust_info' can be used to inspect the table structure and column data types.
====================================================================================================
*/

--------------------------------------------------------------------------------------------
--->>> silver.crm_cust_info
--------------------------------------------------------------------------------------------
---Check for leading or trailing spaces in cst_firstname
---Expectation: No records should be returned
SELECT
cst_key,
cst_firstname,
cst_lastname,
cst_marital_status,
cst_gndr
FROM silver.crm_cust_info
WHERE DATALENGTH(cst_lastname) <> DATALENGTH(TRIM(cst_lastname));

---Check for Cardinality of the column
SELECT DISTINCT
cst_marital_status,
cst_gndr
FROM silver.crm_cust_info;

---Check for duplicates in cst_id & null values
---Expectation: No records should be returned
SELECT
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) <> 1 OR cst_id IS NULL;

---To check our data after transformation and loading into silver layer
SELECT * FROM silver.crm_cust_info;

--------------------------------------------------------------------------------------------
--->>> silver.crm_prd_info
--------------------------------------------------------------------------------------------
---Check for leading or trailing spaces in prd_line
---Expectation: No records should be returned
SELECT
prd_key,
prd_nm,
prd_line
FROM silver.crm_prd_info
WHERE DATALENGTH(prd_line) <> DATALENGTH(TRIM(prd_line));

---Check for Cardinality of the column
SELECT DISTINCT
prd_line
FROM silver.crm_prd_info;

---Check for null or negative values in prd_cost
---Expectation: No records should be returned
SELECT
prd_cost
FROM silver.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost < 0;

---Check for prd_start_dt should be less than prd_end_dt
---Expectation: No records should be returned
SELECT
prd_key,
prd_start_dt,
prd_end_dt
FROM silver.crm_prd_info
WHERE prd_start_dt >= prd_end_dt;

---To check our data after transformation and loading into silver layer
SELECT * FROM silver.crm_prd_info;

---------------------------------------------------------------------------------------------
--->>> silver.crm_sales_details
---------------------------------------------------------------------------------------------
---Check for null or negative values in sls_sales, sls_quantity, sls_price
---Check for sls_sales should be equal to ABS(sls_quantity) * ABS(sls_price)
---Expectation: No records should be returned
SELECT
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_sales <= 0 OR sls_quantity IS NULL OR sls_sales <> ABS(sls_quantity) * ABS(sls_price)
    OR sls_quantity <= 0 OR sls_sales IS NULL
    OR sls_price <= 0 OR sls_price IS NULL
ORDER BY sls_sales, sls_quantity, sls_price;

---To check our data after transformation and loading into silver layer
SELECT * FROM silver.crm_sales_details;

---------------------------------------------------------------------------------------------
--->>> silver.erp_cust_az12
---------------------------------------------------------------------------------------------
---Check for leading or trailing spaces
---Expectation: No records should be returned
SELECT
cid,
gen
FROM silver.erp_cust_az12
WHERE DATALENGTH(gen) <> DATALENGTH(TRIM(gen));

---Check for Cardinality of the column
SELECT DISTINCT
gen
FROM silver.erp_cust_az12;

---Check for bdate should be less than or equal to current date and not a null value
---Expectation: No records should be returned
SELECT
cid,
bdate,
gen
FROM silver.erp_cust_az12
WHERE bdate > GETDATE();

---Check for cid start with 'NAS'
---Expectation: No records should be returned
SELECT
*
FROM silver.erp_cust_az12
WHERE cid LIKE 'NAS%';

---To check our data after transformation and loading into silver layer
SELECT * FROM silver.erp_cust_az12;

---------------------------------------------------------------------------------------------
--->>> silver.erp_loc_a101
---------------------------------------------------------------------------------------------
---Check for leading or trailing spaces
---Expectation: No records should be returned
SELECT
cid,
cntry
FROM silver.erp_loc_a101
WHERE DATALENGTH(cntry) <> DATALENGTH(TRIM(cntry));

---Check for Cardinality of the cntry column
SELECT DISTINCT
cntry
FROM silver.erp_loc_a101;

---To check our data after transformation and loading into silver layer
SELECT * FROM silver.erp_loc_a101;

----------------------------------------------------------------------------------------------
--->>> silver.erp_px_cat_g1v2
----------------------------------------------------------------------------------------------
---Check for cardinality of the maintenance column
SELECT DISTINCT
maintenance
FROM silver.erp_px_cat_g1v2;

---To check our data after transformation and loading into silver layer
SELECT * FROM silver.erp_px_cat_g1v2;
