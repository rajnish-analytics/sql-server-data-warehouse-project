# 🚀 SQL Server Data Warehouse Project

> End-to-end SQL Server Data Warehousing project implementing layered architecture, ETL processing, dimensional modeling, and business-ready analytical data structures using T-SQL.

---

# 📌 Project Overview

**SQL Server Data Warehouse Project** is focused on designing and building a modern analytical warehouse through structured ETL processing, dimensional modeling, and business-ready data transformation using T-SQL.

The project simulates a real-world enterprise data warehousing workflow where raw ERP and CRM datasets are:

* extracted from multiple source systems,
* ingested into structured warehouse layers,
* cleansed and standardized,
* transformed into analytical models,
* and loaded into business-ready fact and dimension tables.

The project demonstrates practical implementation of:

* 🏗️ Data Warehousing
* 🔄 ETL Pipeline Development
* 🧱 Dimensional Modeling
* 📊 Analytical Data Transformation
* 📈 Business-Ready Data Structuring

---

# 🏗️ Data Warehouse Architecture

The warehouse follows a modern layered Medallion Architecture:

```text
Source Systems → Bronze Layer → Silver Layer → Gold Layer
```

---

# 🔹 Layer Breakdown

| Layer           | Description                                                        |
| --------------- | ------------------------------------------------------------------ |
| 🥉 Bronze Layer | Raw ingestion of ERP & CRM source datasets                         |
| 🥈 Silver Layer | Data cleansing, normalization, standardization, and transformation |
| 🥇 Gold Layer   | Business-ready analytical fact and dimension tables                |

---

# 🛠️ Tech Stack

| Technology                          | Purpose                               |
| ----------------------------------- | ------------------------------------- |
| SQL Server                          | Database engine                       |
| T-SQL                               | ETL development & data transformation |
| SQL Server Management Studio (SSMS) | Development environment               |
| Stored Procedures                   | ETL automation                        |
| Window Functions                    | Analytical calculations               |
| Common Table Expressions (CTEs)     | Modular query development             |
| Dimensional Modeling                | Warehouse schema design               |
| Git & GitHub                        | Version control & project management  |

---

# 📂 Repository Structure

```text
sql-server-data-warehouse-project/
│
├── datasets/
│   │
│   ├── crm/
│   │   ├── cust_info.csv
│   │   ├── prd_info.csv
│   │   └── sales_details.csv
│   │
│   └── erp/
│       ├── CUST_AZ12.csv
│       ├── LOC_A101.csv
│       └── PX_CAT_G1V2.csv
│
├── docs/
│   ├── dwh-medallion-architecture.pdf
│   ├── dwh-architecture-flow.pdf
│   ├── dwh-ERD.pdf
│   ├── dwh-sales-dimensional-model.pdf
│   ├── dwh-naming-conventions.md
│   ├── dwh-data-catalog-gold-layer.md
│   └── sql-server-bulk-insert-and-parser-notes.md
│
├── scripts/
│   │
│   ├── bronze/
│   │   ├── dwh_ddl_bronze.sql
│   │   └── dwh_stor_proc_bronze.sql
│   │
│   ├── silver/
│   │   ├── dwh_ddl_silver.sql
│   │   └── dwh_stor_proc_silver.sql
│   │
│   ├── gold/
│   │   └── dwh_ddl_gold.sql
│   │
│   └── dwh_initialization.sql
│
├── tests/
│   ├── dwh_bronze_quality_checks.sql
│   ├── dwh_silver_quality_checks.sql
│   └── dwh_gold_quality_checks.sql
│
├── LICENSE
└── README.md
```

---

# 🔄 ETL Overview

The project implements a structured ETL (Extract, Transform, Load) pipeline for building a business-ready analytical warehouse.

---

# 📥 Extraction Layer

## Extraction Method

* Pull Extraction

## Extract Type

* Full Extraction

## Extraction Technique

* File Parsing

### Source Systems

* CRM datasets
* ERP datasets
* CSV-based structured source files

---

# 🔄 Transformation Layer

The transformation layer standardizes, cleanses, integrates, and enriches raw source data before loading into analytical structures.

---

## 📌 Transformation Techniques

### Data Cleansing

* Remove duplicates
* Data filtering
* Handling missing data
* Handling invalid values
* Handling unwanted spaces
* Data type casting
* Outlier detection

---

### Data Standardization & Processing

* Data normalization
* Derived columns
* Business rules & logic
* Data aggregation

---

### Data Integration

* CRM & ERP data integration
* Cross-source entity mapping
* Business-ready transformation

---

### Data Enrichment

* Surrogate key generation
* Analytical attribute enhancement
* Dimensional business structuring

---

# 📤 Load Layer

## Processing Type

* Batch Processing

## Load Method

* Full Load (Truncate & Insert)

## Slowly Changing Dimension (SCD)

* SCD Type 1 (Overwrite Strategy)

---

# 🧱 Data Modeling Approach

The project follows a **Dimensional Modeling** approach optimized for analytical querying and reporting.

The warehouse is designed using:

* Fact Tables
* Dimension Tables
* Surrogate Keys
* Business-Oriented Relationships
* Analytical Data Structures

---

# 📌 Gold Layer Tables

The Gold Layer contains business-ready analytical structures.

---

## 📌 Dimension Tables

### `gold.dim_customers`

Stores customer demographic and business information including:

* Customer identifiers
* Customer demographics
* Country information
* Gender & marital status
* Customer lifecycle details

---

### `gold.dim_products`

Stores product-related business attributes including:

* Product hierarchy
* Product categories
* Product subcategories
* Product cost
* Product line information
* Maintenance attributes

---

## 📌 Fact Table

### `gold.fact_sales`

Stores transactional sales data including:

* Orders
* Revenue
* Quantity sold
* Customer references
* Product references
* Order dates
* Shipping information

---

# 📑 Data Quality Validation

The project includes dedicated SQL-based quality validation scripts for:

* Null validation
* Duplicate detection
* Referential integrity checks
* Data consistency validation
* Standardization verification

---

# 📚 Documentation Included

The project includes supporting technical documentation such as:

* Entity Relationship Diagram (ERD)
* Data Architecture Flow
* Medallion Architecture
* Sales Dimensional Model
* Naming Conventions
* Gold Layer Data Catalog
* SQL Server Bulk Insert & Parser Notes

---

# 🧠 SQL Concepts Demonstrated

This project demonstrates practical implementation of:

* Stored Procedures
* ETL Design
* Batch Processing
* Window Functions
* Common Table Expressions (CTEs)
* Data Cleansing Techniques
* Surrogate Key Generation
* Joins & Transformations
* Dimensional Modeling
* Business-Oriented SQL Logic

---

# 🎯 Learning Outcomes

Through this project, the following concepts were strengthened:

* Data Warehousing Fundamentals
* ETL Pipeline Development
* Advanced T-SQL
* Dimensional Modeling
* Data Cleansing & Transformation
* SQL-Based Analytical Architecture
* Structured Project Development
* Business-Oriented Data Engineering

---

# 👨‍💻 Author

## Rajnish

Chemical Engineering graduate from **NIT Jalandhar** transitioning into **Data Analytics & Data Engineering** with strong interest in:

* 📊 Data Analytics
* 🏗️ Data Engineering
* 📈 Business Intelligence
* 🧠 Analytical Problem Solving
* 🛢️ Advanced SQL

<div align="center">

### ◈ ◈ ◈

</div>
