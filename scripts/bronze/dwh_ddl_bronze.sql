/*
=========================================================================================
Script: Create Objects/Tables for Bronze Layer
=========================================================================================
Objective: This DDL script creates the necessary tables for the Bronze layer of the data 
warehouse in the 'bronze' schema.

Tables:
    - bronze.crm_cust_info
    - bronze.crm_prd_info
    - bronze.crm_sales_details
    - bronze.erp_cust_az12
    - bronze.erp_loc_a101
    - bronze.erp_px_cat_g1v2

The script performs the following tasks:
1. Checks if each table already exists in the 'bronze' schema and drops it if it does.
2. Creates new tables with the specified schema for each of the above-mentioned tables.
3. This script is intended to be run once to set up the Bronze layer tables before 
   loading data into them.
=========================================================================================
*/

IF OBJECT_ID ('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info
(
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATETIME
);
GO

IF OBJECT_ID ('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info
(
    prd_id INT,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt DATETIME
);
GO

IF OBJECT_ID ('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details
(
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt DATETIME,
    sls_due_dt DATETIME,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);
GO

IF OBJECT_ID ('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12
(
    cid NVARCHAR(50),
    bdate DATETIME,
    gen NVARCHAR(50)
);
GO

IF OBJECT_ID ('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;
CREATE TABLE bronze.erp_loc_a101
(
    cid NVARCHAR(50),
    cntry NVARCHAR(50)
);
GO

IF OBJECT_ID ('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;
CREATE TABLE bronze.erp_px_cat_g1v2
(
    id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(50)
);
GO
