/*
===========================================================================================================
Script: Create Gold Layer Views for Data Warehouse
===========================================================================================================
Purpose: This script creates dimension and fact views for the 'gold' layer of the data warehouse.
The gold layer represents the final, business-ready data that is used for reporting and analytics.
The script includes:
1. Creation of dimension views for customers and products.
2. Creation of a fact view for sales information.
3. Each view performs necessary transformations and joins to ensure data quality and consistency.
4. 'Star Schema' design is followed, with surrogate keys and relevant attributes for dimensions and facts.

Usage: These views can be queried directly for analytics and reporting purposes.
===========================================================================================================
*/

---===========================================================
---CREATING DIMENSION AND FACT VIEWS FOR GOLD LAYER
---===========================================================

--->>> Creating Dimension View : gold.dim_customer_info
IF OBJECT_ID ('gold.dim_customer_info', 'V') IS NOT NULL
    drop view gold.dim_customer_info;
GO

CREATE VIEW gold.dim_customer_info AS
    SELECT
        ROW_NUMBER() OVER(ORDER BY cc.cst_id) AS customer_key,
        cc.cst_id AS customer_id,
        cc.cst_key AS customer_number,
        cc.cst_firstname AS first_name,
        cc.cst_lastname AS last_name,
        el.cntry AS country,
        CASE WHEN cc.cst_gndr <> 'N/A' THEN cc.cst_gndr
            ELSE COALESCE(ec.gen, 'N/A') END AS gender,
        cc.cst_marital_status AS marital_status,
        ec.bdate AS birthdate,
        cc.cst_create_date AS create_date
    FROM silver.crm_cust_info cc
    LEFT JOIN silver.erp_cust_az12 ec
    ON cc.cst_key = ec.cid
    LEFT JOIN silver.erp_loc_a101 el
    ON cc.cst_key = el.cid;
GO

--->>> Creating Dimension View : gold.dim_product_info
IF OBJECT_ID ('gold.dim_product_info', 'V') IS NOT NULL
    DROP VIEW gold.dim_product_info;
GO

CREATE VIEW gold.dim_product_info AS
    SELECT
        ROW_NUMBER() OVER(ORDER BY cp.prd_start_dt, cp.prd_id) AS product_key,
        cp.prd_id AS product_id,
        cp.prd_key AS product_number,
        cp.prd_nm AS product_name,
        cp.prd_cat_id AS category_id,
        ec.cat AS category,
        ec.subcat AS subcategory,
        cp.prd_cost AS cost,
        ec.maintenance AS maintenance,
        cp.prd_line AS product_line,
        cp.prd_start_dt AS start_date
    FROM silver.crm_prd_info cp
    LEFT JOIN silver.erp_px_cat_g1v2 ec
    ON cp.prd_cat_id = ec.id
    WHERE cp.prd_end_dt IS NULL; --As we are considering only current products, we are filtering out historical data
GO

--->>> Creating Fact View : gold.fact_sales_info
IF OBJECT_ID ('gold.fact_sales_info', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales_info;
GO

CREATE VIEW gold.fact_sales_info AS
    SELECT
        cs.sls_ord_num AS order_id,
        dp.product_key,
        dc.customer_key,
        cs.sls_order_dt AS order_date,
        cs.sls_ship_dt AS shipping_date,
        cs.sls_due_dt AS due_date,
        cs.sls_sales AS sales_amount,
        cs.sls_quantity AS quantity,
        cs.sls_price AS unit_price
    FROM silver.crm_sales_details cs
    LEFT JOIN gold.dim_customer_info dc
    ON cs.sls_cust_id = dc.customer_id
    LEFT JOIN gold.dim_product_info dp
    ON cs.sls_prd_key = dp.product_number;
GO
