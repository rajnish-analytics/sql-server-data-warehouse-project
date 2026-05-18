/*
=====================================================================================================
Script: Stored Procedure - Load Bronze Layer Data
=====================================================================================================
Purpose: Stored procedure to load source CSV files into the bronze schema tables using BULK INSERT.
Notes:
  - Truncates target tables before loading to ensure idempotency.
  - Uses BULK INSERT to load source CSV files into bronze schema tables.
  - Uses TRY/CATCH for runtime error reporting.
  - Prints row counts, null checks, and timing information.

Parameters: None 
This procedure does not accept any parameters or return any result sets. 
It performs data loading operations and prints status messages.

Execution: EXEC bronze.load_bronze;
=====================================================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    DECLARE @row_count INT, @null_count INT;
    
    BEGIN TRY
        SET @batch_start_time = GETDATE();
            PRINT '================================================================';
            PRINT 'Loading Data Into Bronze Layer...';
            PRINT '================================================================';

            PRINT '----------------------------------------------------------------';
            PRINT 'Loading CRM Tables Data...';
            PRINT '----------------------------------------------------------------';

            SET @start_time = GETDATE();
            PRINT '>>> Truncating Table: bronze.crm_cust_info';
            TRUNCATE TABLE bronze.crm_cust_info;

            PRINT '>>> Bulk Inserting Data Into Table: bronze.crm_cust_info';
            BULK INSERT bronze.crm_cust_info
            FROM '/var/opt/mssql/shared/datasets/source_crm/cust_info.csv'
            WITH (
                FIRSTROW = 2,
                FIELDTERMINATOR = ',',
                ROWTERMINATOR = '\n',
                TABLOCK
            );
            SET @end_time = GETDATE();
            SET @row_count = (SELECT COUNT(*) FROM bronze.crm_cust_info);
            SET @null_count = (SELECT COUNT(*) FROM bronze.crm_cust_info WHERE cst_id IS NULL);
            
            PRINT '@@@ Duration: ' + CAST(DATEDIFF(millisecond, @start_time, @end_time) AS NVARCHAR) + ' millisecond';
            PRINT '@@@ Row Count: ' + CAST(@row_count AS NVARCHAR);
            PRINT '@@@ Null Check (cst_id): ' + CAST(@null_count AS NVARCHAR) + ' nulls found';
            IF @row_count = 0
                PRINT '!!! WARNING: No data loaded into bronze.crm_cust_info';
            PRINT '*********************************';

            SET @start_time = GETDATE();
            PRINT '>>> Truncating Table: bronze.crm_prd_info';
            TRUNCATE TABLE bronze.crm_prd_info;

            PRINT '>>> Bulk Inserting Data Into Table: bronze.crm_prd_info';
            BULK INSERT bronze.crm_prd_info
            FROM '/var/opt/mssql/shared/datasets/source_crm/prd_info.csv'
            WITH (
                FIRSTROW = 2,
                FIELDTERMINATOR = ',',
                ROWTERMINATOR = '\n',
                TABLOCK
            );
            SET @end_time = GETDATE();
            SET @row_count = (SELECT COUNT(*) FROM bronze.crm_prd_info);
            SET @null_count = (SELECT COUNT(*) FROM bronze.crm_prd_info WHERE prd_id IS NULL);
            
            PRINT '@@@ Duration: ' + CAST(DATEDIFF(millisecond, @start_time, @end_time) AS NVARCHAR) + ' millisecond';
            PRINT '@@@ Row Count: ' + CAST(@row_count AS NVARCHAR);
            PRINT '@@@ Null Check (prd_id): ' + CAST(@null_count AS NVARCHAR) + ' nulls found';
            IF @row_count = 0
                PRINT '!!! WARNING: No data loaded into bronze.crm_prd_info';
            PRINT '*********************************';

            SET @start_time = GETDATE();
            PRINT '>>> Truncating Table: bronze.crm_sales_details';
            TRUNCATE TABLE bronze.crm_sales_details;
            
            PRINT '>>> Bulk Inserting Data Into Table: bronze.crm_sales_details';
            BULK INSERT bronze.crm_sales_details
            FROM '/var/opt/mssql/shared/datasets/source_crm/sales_details.csv'
            WITH (
                FIRSTROW = 2,
                FIELDTERMINATOR = ',',
                ROWTERMINATOR = '\n',
                TABLOCK
            );
            SET @end_time = GETDATE();
            SET @row_count = (SELECT COUNT(*) FROM bronze.crm_sales_details);
            SET @null_count = (SELECT COUNT(*) FROM bronze.crm_sales_details WHERE sls_ord_num IS NULL);
            
            PRINT '@@@ Duration: ' + CAST(DATEDIFF(millisecond, @start_time, @end_time) AS NVARCHAR) + ' millisecond';
            PRINT '@@@ Row Count: ' + CAST(@row_count AS NVARCHAR);
            PRINT '@@@ Null Check (sls_ord_num): ' + CAST(@null_count AS NVARCHAR) + ' nulls found';
            IF @row_count = 0
                PRINT '!!! WARNING: No data loaded into bronze.crm_sales_details';
            PRINT '*********************************';
            
            PRINT '----------------------------------------------------------------';
            PRINT 'Loading ERP Tables Data...';
            PRINT '----------------------------------------------------------------';

            SET @start_time = GETDATE();
            PRINT '>>> Truncating Table: bronze.erp_cust_az12';
            TRUNCATE TABLE bronze.erp_cust_az12;
            
            PRINT '>>> Bulk Inserting Data Into Table: bronze.erp_cust_az12';
            BULK INSERT bronze.erp_cust_az12
            FROM '/var/opt/mssql/shared/datasets/source_erp/CUST_AZ12.csv'
            WITH (
                FIRSTROW = 2,
                FIELDTERMINATOR = ',',
                ROWTERMINATOR = '\n',
                TABLOCK
            );
            SET @end_time = GETDATE();
            SET @row_count = (SELECT COUNT(*) FROM bronze.erp_cust_az12);
            SET @null_count = (SELECT COUNT(*) FROM bronze.erp_cust_az12 WHERE cid IS NULL);
            
            PRINT '@@@ Duration: ' + CAST(DATEDIFF(millisecond, @start_time, @end_time) AS NVARCHAR) + ' millisecond';
            PRINT '@@@ Row Count: ' + CAST(@row_count AS NVARCHAR);
            PRINT '@@@ Null Check (cid): ' + CAST(@null_count AS NVARCHAR) + ' nulls found';
            IF @row_count = 0
                PRINT '!!! WARNING: No data loaded into bronze.erp_cust_az12';
            PRINT '*********************************';
            
            SET @start_time = GETDATE();
            PRINT '>>> Truncating Table: bronze.erp_loc_a101';
            TRUNCATE TABLE bronze.erp_loc_a101;
            
            PRINT '>>> Bulk Inserting Data Into Table: bronze.erp_loc_a101';
            BULK INSERT bronze.erp_loc_a101
            FROM '/var/opt/mssql/shared/datasets/source_erp/LOC_A101.csv'
            WITH (
                FIRSTROW = 2,
                FIELDTERMINATOR = ',',
                ROWTERMINATOR = '\n',
                TABLOCK
            );
            SET @end_time = GETDATE();
            SET @row_count = (SELECT COUNT(*) FROM bronze.erp_loc_a101);
            SET @null_count = (SELECT COUNT(*) FROM bronze.erp_loc_a101 WHERE cid IS NULL);
            
            PRINT '@@@ Duration: ' + CAST(DATEDIFF(millisecond, @start_time, @end_time) AS NVARCHAR) + ' millisecond';
            PRINT '@@@ Row Count: ' + CAST(@row_count AS NVARCHAR);
            PRINT '@@@ Null Check (cid): ' + CAST(@null_count AS NVARCHAR) + ' nulls found';
            IF @row_count = 0
                PRINT '!!! WARNING: No data loaded into bronze.erp_loc_a101';
            PRINT '*********************************';
            
            SET @start_time = GETDATE();
            PRINT '>>> Truncating Table: bronze.erp_px_cat_g1v2';
            TRUNCATE TABLE bronze.erp_px_cat_g1v2;
            
            PRINT '>>> Bulk Inserting Data Into Table: bronze.erp_px_cat_g1v2';
            BULK INSERT bronze.erp_px_cat_g1v2
            FROM '/var/opt/mssql/shared/datasets/source_erp/PX_CAT_G1V2.csv'
            WITH (
                FIRSTROW = 2,
                FIELDTERMINATOR = ',',
                ROWTERMINATOR = '\n',
                TABLOCK
            );
            SET @end_time = GETDATE();
            SET @row_count = (SELECT COUNT(*) FROM bronze.erp_px_cat_g1v2);
            SET @null_count = (SELECT COUNT(*) FROM bronze.erp_px_cat_g1v2 WHERE id IS NULL);
            
            PRINT '@@@ Duration: ' + CAST(DATEDIFF(millisecond, @start_time, @end_time) AS NVARCHAR) + ' millisecond';
            PRINT '@@@ Row Count: ' + CAST(@row_count AS NVARCHAR);
            PRINT '@@@ Null Check (id): ' + CAST(@null_count AS NVARCHAR) + ' nulls found';
            IF @row_count = 0
                PRINT '!!! WARNING: No data loaded into bronze.erp_px_cat_g1v2';
            PRINT '*********************************';

        SET @batch_end_time = GETDATE();
        PRINT '****************************************************************';
        PRINT 'DATA LOADING INTO BRONZE LAYER COMPLETED.';
        PRINT 'TOTAL LOAD DURATION: ' + CAST(DATEDIFF(millisecond, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' milliseconds';
        PRINT '****************************************************************';

    END TRY
    BEGIN CATCH
        PRINT '=================================================================';
        PRINT 'An error occurred while loading data into the Bronze Layer.';
        PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
        PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'ERROR SEVERITY: ' + CAST(ERROR_SEVERITY() AS NVARCHAR(10));
        PRINT 'ERROR STATE: ' + CAST(ERROR_STATE() AS NVARCHAR(10));
        PRINT 'ERROR LINE: ' + CAST(ERROR_LINE() AS NVARCHAR(10));
        PRINT '=================================================================';
    END CATCH
END
GO
