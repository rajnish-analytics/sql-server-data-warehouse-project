/*
====================================================================================================
Script: Bronze Layer Data Quality Checks
====================================================================================================
Objective: Validate raw Bronze-layer data before Silver-layer transformations.

The checks include:
1. duplicates
2. null values
3. invalid dates
4. invalid numeric values
5. whitespace issues
6. hidden control characters
7. cardinality anomalies

Notes:
1. Hidden \r or \n characters may appear when BULK INSERT ROWTERMINATOR does not match the source 
   file newline format.
2. Used DATALENGTH() instead of LEN() for whitespace checks because LEN() ignores trailing spaces.
3. INT date columns must first be converted to VARCHAR before DATE conversion.
4. sp_help 'bronze.crm_cust_info' can be used to inspect the table structure and column data types.
====================================================================================================
*/

----------------------------------------------------------------------------------------------------
--->>> bronze.crm_cust_info
----------------------------------------------------------------------------------------------------
---Check for leading or trailing spaces in cst_firstname
---Expectation: No records should be returned
SELECT
cst_key,
cst_firstname,
cst_lastname,
cst_marital_status,
cst_gndr
FROM bronze.crm_cust_info
WHERE DATALENGTH(cst_gndr) <> DATALENGTH(TRIM(cst_gndr));

---Check for Cardinality of the marital status & gender columns
SELECT DISTINCT
cst_marital_status,
cst_gndr
FROM bronze.crm_cust_info;

---Check for duplicates in cst_id & null values
---Expectation: No records should be returned
SELECT
cst_id,
COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) <> 1 OR cst_id IS NULL;

---Check for duplicates in cst_id with the latest cst_create_date
---Expectation: Only one record should be returned with the latest cst_create_date for cst_id
SELECT
*
FROM (
SELECT
cst_id,
ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) dup_latest,
cst_create_date
FROM bronze.crm_cust_info
)t
WHERE cst_id = 29449;

----------------------------------------------------------------------------------------------------
--->>> bronze.crm_prd_info
----------------------------------------------------------------------------------------------------
---Check for leading or trailing spaces in prd_line
---Expectation: No records should be returned
SELECT
prd_key,
prd_nm,
prd_line
FROM bronze.crm_prd_info
WHERE DATALENGTH(prd_line) <> DATALENGTH(TRIM(prd_line));

---Check for Cardinality of the prd_line column
SELECT DISTINCT
prd_line
FROM bronze.crm_prd_info;

---Check for duplicates in prd_id & null values
---Expectation: No records should be returned
SELECT
prd_id,
COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) <> 1 OR prd_id IS NULL;

---Check for null or negative values in prd_cost
---Expectation: No records should be returned
SELECT
prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost < 0;

---Check for prd_start_dt should be less than prd_end_dt
---Expectation: No records should be returned
SELECT
prd_key,
prd_start_dt,
prd_end_dt
FROM bronze.crm_prd_info
WHERE prd_start_dt >= prd_end_dt;

----------------------------------------------------------------------------------------------------
--->>> bronze.crm_sales_details
----------------------------------------------------------------------------------------------------
---Check for leading or trailing spaces in sls_ord_num
---Expectation: No records should be returned
SELECT
sls_ord_num,
sls_prd_key
FROM bronze.crm_sales_details
WHERE DATALENGTH(sls_prd_key) <> DATALENGTH(TRIM(sls_prd_key));

---Check for duplicates in sls_ord_num & null values
---Expectation: No records should be returned
SELECT
sls_ord_num,
COUNT(*)
FROM bronze.crm_sales_details
GROUP BY sls_ord_num
HAVING COUNT(*) <> 1 OR sls_ord_num IS NULL;

---To understand the distribution of records for sls_ord_num
SELECT
sls_ord_num,
sls_prd_key,
sls_cust_id,
COUNT(*) OVER(PARTITION BY sls_ord_num)
FROM bronze.crm_sales_details
--WHERE sls_ord_num = 'SO71559'
ORDER BY COUNT(*) OVER(PARTITION BY sls_ord_num) DESC, sls_ord_num;

---Check for null, zero, or negative values in sls_sales, sls_quantity, and sls_price
---Check for sls_sales = ABS(sls_quantity) * ABS(sls_price)
---Expectation: No records should be returned
SELECT
sls_sales,
sls_quantity,
sls_price
FROM bronze.crm_sales_details
WHERE sls_sales <= 0 OR sls_quantity IS NULL OR sls_sales <> ABS(sls_quantity) * ABS(sls_price)
    OR sls_quantity <= 0 OR sls_sales IS NULL
    OR sls_price <= 0 OR sls_price IS NULL
ORDER BY sls_sales, sls_quantity, sls_price;

---Check for data type issues in sls_order_dt by trying to convert into date format
---Expectation: No records should be returned
SELECT
LEN(sls_order_dt)
FROM bronze.crm_sales_details
WHERE LEN(sls_order_dt) <> 8 AND LEN(sls_order_dt) <> 6;
/* Note:
1. LEN() is used for validating date values stored in INT format, which are expected 
to contain 8 or 6 characters in YYYYMMDD or YYMMDD format before conversion to DATE.
2. SUBSTRING() works only with string data types. */


---Check if sls_order_dt <= sls_ship_dt <= sls_due_dt
---Expectation: No records should be returned
SELECT
CASE WHEN LEN(sls_order_dt) = 8 AND LEN(sls_order_dt) = 6 THEN CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
     ELSE NULL END sls_order_dt,
sls_ship_dt,
sls_due_dt
FROM bronze.crm_sales_details
WHERE CASE WHEN LEN(sls_order_dt) = 8 THEN CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
      ELSE NULL END >= sls_ship_dt OR sls_ship_dt >= sls_due_dt;

----------------------------------------------------------------------------------------------------
--->>> bronze.erp_cust_az12
----------------------------------------------------------------------------------------------------
---Check for leading or trailing spaces
---Expectation: No records should be returned
SELECT
cid,
gen,
TRIM(gen),
LEN(gen),
LEN(TRIM(gen)),
DATALENGTH(gen),
DATALENGTH(TRIM(gen))
FROM bronze.erp_cust_az12
WHERE DATALENGTH(gen) <> DATALENGTH(TRIM(gen));

---Check for Cardinality of the gen column
SELECT DISTINCT
gen
FROM bronze.erp_cust_az12;

---Check for duplicates in cid & null values
---Expectation: No records should be returned
SELECT
cid,
COUNT(*)
FROM bronze.erp_cust_az12
GROUP BY cid
HAVING COUNT(*) <> 1 OR cid IS NULL;

---Check for bdate should be less than or equal to current date
---Expectation: No records should be returned
SELECT
cid,
bdate,
gen
FROM bronze.erp_cust_az12
WHERE bdate > GETDATE() OR YEAR(bdate) < 1926;

---Check for cid which don't start with 'NAS'
---Expectation: No records should be returned
SELECT
*
FROM bronze.erp_cust_az12
WHERE cid NOT LIKE 'NAS%';

----------------------------------------------------------------------------------------------------
--->>>bronze.erp_loc_a101
----------------------------------------------------------------------------------------------------
---Check for leading or trailing spaces
---Expectation: No records should be returned
SELECT
cid,
cntry
FROM bronze.erp_loc_a101
WHERE DATALENGTH(cntry) <> DATALENGTH(TRIM(cntry));

---Check for duplicates in cid & null values
---Expectation: No records should be returned
SELECT
cid,
COUNT(*)
FROM bronze.erp_loc_a101
GROUP BY cid
HAVING COUNT(*) <> 1 OR cid IS NULL;

---Check for cardinality of cntry column
SELECT DISTINCT
TRIM(cntry)
FROM bronze.erp_loc_a101;

----------------------------------------------------------------------------------------------------
--->>>bronze.erp_px_cat_g1v2
----------------------------------------------------------------------------------------------------
---Check for leading or trailing spaces in maintenance column
---Expectation: No records should be returned
SELECT
id,
cat,
subcat,
maintenance
FROM bronze.erp_px_cat_g1v2
WHERE DATALENGTH(maintenance) <> DATALENGTH(TRIM(maintenance));

---Check for cardinality of maintenance column
SELECT DISTINCT
maintenance
FROM bronze.erp_px_cat_g1v2;

---Check for duplicates in id & null values
---Expectation: No records should be returned
SELECT
id,
COUNT(*)
FROM bronze.erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) <> 1 OR id IS NULL;
