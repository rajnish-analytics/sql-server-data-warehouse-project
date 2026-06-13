# 📘 Data Catalog — Gold Layer

## Overview

The **Gold Layer** represents the business-ready analytical layer of the warehouse.
It contains curated **fact** and **dimension** tables optimized for reporting, business analytics, and SQL-based analysis.

The layer is designed using a **Dimensional Modeling** approach to support:

* analytical querying
* KPI reporting
* trend analysis
* customer insights
* product performance evaluation

---

# 🧑‍💼 1. `gold.dim_customer_info`

## Purpose

Stores customer-related demographic and profile information used for customer analytics, segmentation, and reporting.

---

## Columns

| Column Name       | Data Type    | Description                                                                     |
| ----------------- | ------------ | ------------------------------------------------------------------------------- |
| `customer_key`    | BIGINT       | Surrogate key uniquely identifying each customer record in the dimension table. |
| `customer_id`     | INT          | Unique identifier assigned to each customer from the source system.             |
| `customer_number` | NVARCHAR(50) | Alphanumeric customer reference number used for business tracking.              |
| `first_name`      | NVARCHAR(50) | Customer's first name.                                                          |
| `last_name`       | NVARCHAR(50) | Customer's last name or surname.                                                |
| `country`         | NVARCHAR(50) | Customer's country of residence.                                                |
| `gender`          | NVARCHAR(50) | Gender of the customer.                                                         |
| `marital_status`  | NVARCHAR(50) | Marital status of the customer.                                                 |
| `birthdate`       | DATE         | Customer date of birth.                                                         |
| `create_date`     | DATE         | Date when the customer record was created in the source system.                 |

---

# 📦 2. `gold.dim_product_info`

## Purpose

Stores product-related attributes and hierarchical product information used for product analytics and reporting.

---

## Columns

| Column Name      | Data Type     | Description                                                                    |
| ---------------- | ------------- | ------------------------------------------------------------------------------ |
| `product_key`    | BIGINT        | Surrogate key uniquely identifying each product record in the dimension table. |
| `product_id`     | INT           | Unique identifier assigned to the product from the source system.              |
| `product_number` | NVARCHAR(50)  | Alphanumeric product reference number used for inventory and tracking.         |
| `product_name`   | NVARCHAR(50)  | Descriptive name of the product.                                               |
| `category_id`    | NVARCHAR(50)  | Identifier representing the product category.                                  |
| `category`       | NVARCHAR(50)  | High-level product classification.                                             |
| `subcategory`    | NVARCHAR(50)  | Detailed product classification within the category.                           |
| `cost`           | INT           | Base product cost or manufacturing cost.                                       |
| `maintenance`    | NVARCHAR(50)  | Indicates whether maintenance is required for the product.                     |
| `product_line`   | NVARCHAR(50)  | Product series or business product line classification.                        |
| `start_date`     | DATE          | Date when the product became available.                                        |

---

# 🧾 3. `gold.fact_sales_info`

## Purpose

Stores transactional sales data at the order-line level for analytical and reporting purposes.

This table acts as the central fact table connecting customer and product dimensions.

---

## Columns

| Column Name     | Data Type    | Description                                                 |
| --------------- | ------------ | ----------------------------------------------------------- |
| `order_id`      | NVARCHAR(50) | Unique identifier for each sales order.                     |
| `product_key`   | BIGINT       | Foreign key referencing the product dimension table.        |
| `customer_key`  | BIGINT       | Foreign key referencing the customer dimension table.       |
| `order_date`    | DATE         | Date when the order was placed.                             |
| `shipping_date` | DATE         | Date when the order was shipped.                            |
| `due_date`      | DATE         | Due date associated with the order transaction.             |
| `sales_amount`  | INT          | Total sales amount generated for the transaction line item. |
| `quantity`      | INT          | Quantity of products ordered.                               |
| `unit_price`    | INT          | Price per individual product unit.                          |

---

# 🔗 Relationship Overview

| Relationship                                                    | Description                                          |
| --------------------------------------------------------------- | ---------------------------------------------------- |
| `fact_sales_info.customer_key → dim_customer_info.customer_key` | Connects sales transactions to customer information. |
| `fact_sales_info.product_key → dim_product_info.product_key`    | Connects sales transactions to product information.  |

---

# 📊 Analytical Usage

The Gold Layer supports:

* Customer Analytics
* Product Performance Analysis
* Revenue Analysis
* Time-Series Analysis
* KPI Reporting
* Segmentation Analysis
* Business Problem Solving
* Reporting Views
* Exploratory Data Analysis (EDA)

<div align="center">

### ◈ ◈ ◈

</div>
