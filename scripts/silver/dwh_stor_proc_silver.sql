/*
======================================================================================================================
Script: Stored Procedure - Load Data into Silver Layer
======================================================================================================================
Objective: This script creates a stored procedure to load data into the 'silver' schema tables from Bronze layer. The 
Silver layer represents the cleaned and transformed data that is ready for further processing into the Gold layer.

This script performs the following actions:
1. Uses INSERT to load data into silver schema tables.
2. Truncates target tables before loading to ensure idempotency.
3. To ensure data quality and consistency, data transformation is performed.
   i.e. Data Enrichment, Data Integration, Derived Columns, Data Normalization & Standardization
   and Data Cleaning.
4. Data standardization is performed to ensure data quality and consistency.
5. Uses TRY/CATCH for runtime error reporting.
6. Prints row counts, null checks, and time duration information.

Parameters: None 
This procedure does not accept any parameters or return any result sets. 
It performs data loading operations and prints status messages.

Execution: EXEC silver.load_silver;
======================================================================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
     BEGIN TRY
          DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME, @row_count INT, @null_count INT;

          SET @batch_start_time = GETDATE();
          PRINT '=======================================================';
          PRINT 'Inserting Data Into Silver Layer...';
          PRINT '=======================================================';

          PRINT '-------------------------------------------------------';
          PRINT 'Inserting CRM Tables Data...';
          PRINT '-------------------------------------------------------';

          SET @start_time = GETDATE();
          Print '>>> Truncating Table: silver.crm_cust_info';
          TRUNCATE TABLE silver.crm_cust_info;

          PRINT '>>> Inserting Data Into Table: silver.crm_cust_info';
          INSERT INTO silver.crm_cust_info (
          cst_id,
          cst_key,
          cst_firstname,
          cst_lastname,
          cst_marital_status,
          cst_gndr,
          cst_create_date
          )
          SELECT
          cst_id,
          cst_key,
          TRIM(cst_firstname) cst_firstname,
          TRIM(cst_lastname) cst_lastname,
          CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'SINGLE'
               WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'MARRIED' 
               ELSE 'N/A' END cst_marital_status,
          CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'FEMALE'
               WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'MALE' 
               ELSE 'N/A' END cst_gndr,
          cst_create_date
          FROM (
          SELECT
          *,
          ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date) dup_latest
          FROM bronze.crm_cust_info
          WHERE cst_id IS NOT NULL
          )t
          WHERE dup_latest = 1;
          SET @end_time = GETDATE();
          SET @row_count = (SELECT COUNT(*) FROM silver.crm_cust_info);
          SET @null_count = (SELECT COUNT(*) FROM silver.crm_cust_info WHERE cst_id IS NULL);

          PRINT '@@@ Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS VARCHAR) + ' ms';
          PRINT '@@@ Rows Inserted: ' + CAST(@row_count AS VARCHAR);
          PRINT '@@@ Null Check (cst_id): ' + CAST(@null_count AS VARCHAR) + ' nulls found';
          IF @row_count = 0
               PRINT '!!!WARNING!!! No Data Inserted Into silver.crm_cust_info';

          SET @start_time = GETDATE();
          PRINT '>>> Truncating Table: silver.crm_prd_info';
          TRUNCATE TABLE silver.crm_prd_info;

          PRINT '>>> Inserting Data Into Table: silver.crm_prd_info';
          INSERT INTO silver.crm_prd_info (
          prd_id,
          prd_cat_id,
          prd_key,
          prd_nm,
          prd_cost,
          prd_line,
          prd_start_dt,
          prd_end_dt
          )
          SELECT
          prd_id,
          REPLACE(LEFT(prd_key, 5), '-', '_') prd_cat_id,
          SUBSTRING(prd_key, 7, LEN(prd_key)) prd_key,
          prd_nm,
          ISNULL(ABS(prd_cost), 0) prd_cost,
          CASE WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'MARSH'
               WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'REEF'
               WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'SEA'
               WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'TRENCH'
               ELSE 'N/A' END prd_line,
          prd_start_dt,
          DATEADD(DAY, -1, LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)) prd_end_dt
          FROM bronze.crm_prd_info;
          SET @end_time = GETDATE();
          SET @row_count = (SELECT COUNT(*) FROM silver.crm_prd_info);
          SET @null_count = (SELECT COUNT(*) FROM silver.crm_prd_info WHERE prd_id IS NULL);

          PRINT '@@@ Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS VARCHAR) + ' ms';
          PRINT '@@@ Rows Inserted: ' + CAST(@row_count AS VARCHAR);
          PRINT '@@@ Null Check (prd_id): ' + CAST(@null_count AS VARCHAR) + ' nulls found';
          IF @row_count = 0
               PRINT '!!!WARNING!!! No Data Inserted Into silver.crm_prd_info';

          SET @start_time = GETDATE();
          PRINT '>>> Truncating Table: silver.crm_sales_details';
          TRUNCATE TABLE silver.crm_sales_details;

          PRINT '>>> Inserting Data Into Table: silver.crm_sales_details';
          INSERT INTO silver.crm_sales_details (
          sls_ord_num,
          sls_prd_key,
          sls_cust_id,
          sls_order_dt,
          sls_ship_dt,
          sls_due_dt,
          sls_sales,
          sls_quantity,
          sls_price
          )
          SELECT
          sls_ord_num,
          sls_prd_key,
          sls_cust_id,
          CASE WHEN LEN(sls_order_dt) = 8 OR LEN(sls_order_dt) = 6 THEN CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
               ELSE NULL END sls_order_dt,
          sls_ship_dt,
          sls_due_dt,
          CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales <> ABS(sls_quantity) * ABS(sls_price) THEN ABS(sls_quantity) * ABS(sls_price)
               ELSE sls_sales END sls_sales,
          CASE WHEN sls_quantity IS NULL OR sls_quantity <= 0 THEN ABS(sls_sales) / NULLIF(ABS(sls_price), 0)
               ELSE sls_quantity END sls_quantity,
          CASE WHEN sls_price IS NULL OR sls_price <= 0 THEN ABS(sls_sales) / NULLIF(ABS(sls_quantity), 0)
               ELSE sls_price END sls_sales
          FROM bronze.crm_sales_details;
          SET @end_time = GETDATE();
          SET @row_count = (SELECT COUNT(*) FROM silver.crm_sales_details);
          SET @null_count = (SELECT COUNT(*) FROM silver.crm_sales_details WHERE sls_ord_num IS NULL);

          PRINT '@@@ Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS VARCHAR) + ' ms';
          PRINT '@@@ Rows Inserted: ' + CAST(@row_count AS VARCHAR);
          PRINT '@@@ Null Check (sls_ord_num): ' + CAST(@null_count AS VARCHAR) + ' nulls found';
          IF @row_count = 0
               PRINT '!!!WARNING!!! No Data Inserted Into silver.crm_sales_details';

          PRINT '-------------------------------------------------------';
          PRINT 'Inserting ERP Tables Data...';
          PRINT '-------------------------------------------------------';

          SET @start_time = GETDATE();
          PRINT '>>> Truncating Table: silver.erp_cust_az12';
          TRUNCATE TABLE silver.erp_cust_az12;

          PRINT '>>> Inserting Data Into Table: silver.erp_cust_az12';
          INSERT INTO silver.erp_cust_az12 (
          cid,
          bdate,
          gen
          )
          SELECT
          CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
               ELSE cid END cid,
          CASE WHEN bdate > GETDATE() THEN NULL
               ELSE bdate END bdate,
          CASE WHEN UPPER(TRIM(REPLACE(gen,0X0D, ''))) = 'MALE' THEN 'MALE'
               WHEN UPPER(TRIM(REPLACE(gen,0X0D, ''))) = 'FEMALE' THEN 'FEMALE'
               ELSE 'N/A' END gen
          FROM bronze.erp_cust_az12;
          SET @end_time = GETDATE();
          SET @row_count = (SELECT COUNT(*) FROM silver.erp_cust_az12);
          SET @null_count = (SELECT COUNT(*) FROM silver.erp_cust_az12 WHERE cid IS NULL);

          PRINT '@@@ Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS VARCHAR) + ' ms';
          PRINT '@@@ Rows Inserted: ' + CAST(@row_count AS VARCHAR);
          PRINT '@@@ Null Check (cid): ' + CAST(@null_count AS VARCHAR) + ' nulls found';
          IF @row_count = 0
               PRINT '!!!WARNING!!! No Data Inserted Into silver.erp_cust_az12';

          SET @start_time = GETDATE();
          PRINT '>>> Truncating Table: silver.erp_loc_a101';
          TRUNCATE TABLE silver.erp_loc_a101;

          PRINT '>>> Inserting Data Into Table: silver.erp_loc_a101';
          INSERT INTO silver.erp_loc_a101 (
          cid,
          cntry
          )
          SELECT
          REPLACE(cid, '-', '') cid,
          CASE WHEN cntry IN ('US', 'USA') THEN 'UNITED STATES'
               WHEN cntry = 'DE' THEN 'GERMANY'
               WHEN cntry = 'FR' THEN 'FRANCE'
               WHEN cntry  = 'AUS' THEN 'AUSTRALIA'
               WHEN cntry = 'CAN' THEN 'CANADA'
               WHEN cntry = '' THEN 'N/A'
               ELSE cntry END cntry
          FROM (
               SELECT
               cid,
               UPPER(TRIM(REPLACE(cntry, char(13), ''))) cntry
               FROM bronze.erp_loc_a101
               )t;
          SET @end_time = GETDATE();
          SET @row_count = (SELECT COUNT(*) FROM silver.erp_loc_a101);
          SET @null_count = (SELECT COUNT(*) FROM silver.erp_loc_a101 WHERE cid IS NULL);

          PRINT '@@@ Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS VARCHAR) + ' ms';
          PRINT '@@@ Rows Inserted: ' + CAST(@row_count AS VARCHAR);
          PRINT '@@@ Null Check (cid): ' + CAST(@null_count AS VARCHAR) + ' nulls found';
          IF @row_count = 0
               PRINT '!!!WARNING!!! No Data Inserted Into silver.erp_loc_a101';

          SET @start_time = GETDATE();
          PRINT '>>> Truncating Table: silver.erp_px_cat_g1v2';
          TRUNCATE TABLE silver.erp_px_cat_g1v2;

          PRINT '>>> Inserting Data Into Table: silver.erp_px_cat_g1v2';
          INSERT INTO silver.erp_px_cat_g1v2 (
          id,
          cat,
          subcat,
          maintenance
          )
          SELECT
          id,
          cat,
          subcat,
          CASE WHEN UPPER(TRIM(REPLACE(maintenance, char(13), ''))) = 'YES' THEN 'YES'
               WHEN UPPER(TRIM(REPLACE(maintenance, char(13), ''))) = 'NO' THEN 'NO'
               ELSE 'N/A' END maintenance
          FROM bronze.erp_px_cat_g1v2;
          SET @end_time = GETDATE();
          SET @row_count = (SELECT COUNT(*) FROM silver.erp_px_cat_g1v2);
          SET @null_count = (SELECT COUNT(*) FROM silver.erp_px_cat_g1v2 WHERE id IS NULL);

          PRINT '@@@ Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS VARCHAR) + ' ms';
          PRINT '@@@ Rows Inserted: ' + CAST(@row_count AS VARCHAR);
          PRINT '@@@ Null Check (id): ' + CAST(@null_count AS VARCHAR) + ' nulls found';
          IF @row_count = 0
               PRINT '!!!WARNING!!! No Data Inserted Into silver.erp_px_cat_g1v2';

          SET @batch_end_time = GETDATE();
          PRINT '*******************************************************';
          PRINT 'DATA INSERTION INTO SILVER LAYER COMPLETED';
          PRINT 'TOTAL INSERT DURATION: ' + CAST(DATEDIFF(MILLISECOND, @batch_start_time, @batch_end_time) AS VARCHAR) + ' ms';
          PRINT '*******************************************************';

     END TRY
     BEGIN CATCH
          PRINT '=======================================================';
          PRINT 'AN ERROR OCCURRED WHILE INSERTING DATA INTO SILVER TABLES';
          PRINT 'Error Message: ' + ERROR_MESSAGE();
          PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
          PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
          PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR);
          PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
          PRINT '=======================================================';
     END CATCH;
END
GO
