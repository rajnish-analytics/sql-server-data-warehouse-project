# 📚 Data Warehouse Naming Conventions

This document defines the naming standards used throughout the DataWarehouse project to ensure consistency, maintainability, and ease of understanding across all layers.

---

## 📋 Table of Contents

* [General Principles](#-general-principles)
* [Table Naming Conventions](#-table-naming-conventions)
  - [Bronze Layer](#bronze-layer)
  - [Silver Layer](#silver-layer)
  - [Gold Layer](#gold-layer)
* [Column Naming Conventions](#-column-naming-conventions)
  - [Surrogate Keys](#surrogate-keys)
  - [Technical Columns](#technical-columns)
* [Stored Procedure Naming Conventions](#-stored-procedure-naming-conventions)
* [Design Principles](#-design-principles)

---

# 🔹 General Principles

The following standards apply to all database objects:

* Use **snake_case** naming convention.
* Use **lowercase letters** and underscores (`_`) only.
* Use **English** for all object names.
* Avoid SQL reserved keywords.
* Use clear and descriptive names.
* Maintain consistency across all warehouse layers.

---

# 🏗️ Table Naming Conventions

-- Bronze Layer

Bronze tables store raw data loaded directly from source systems.

### Pattern

```text
<source_system>_<entity>
```

### Examples

```text
crm_cust_info
crm_prd_info
erp_cust_az12
erp_loc_a101
```

### Guidelines

* Preserve original source-system naming wherever possible.
* Avoid business-level renaming in the Bronze layer.
* Maintain traceability to source systems.

---

-- Silver Layer

Silver tables contain cleansed, standardized, and transformed data.

### Pattern

```text
<source_system>_<entity>
```

### Examples

```text
crm_cust_info
crm_prd_info
erp_cust_az12
erp_loc_a101
```

### Guidelines

* Retain source-system naming consistency.
* Apply data quality improvements and standardization.
* Keep naming aligned with Bronze for easier lineage tracking.

---

## Gold Layer

Gold tables contain business-ready data optimized for analytics and reporting.

### Pattern

```text
<category>_<entity>
```

### Examples

```text
dim_customer
dim_product
fact_sales
```

### Category Reference

| Prefix    | Description                     |
| --------- | ------------------------------- |
| `dim_`    | Dimension tables                |
| `fact_`   | Fact tables                     |
| `report_` | Reporting and aggregated tables |

### Guidelines

* Use business-friendly names.
* Follow dimensional modeling standards.
* Design tables for reporting and analytical consumption.

---

# 🔑 Column Naming Conventions

## Surrogate Keys

All surrogate keys must use the `_key` suffix.

### Pattern

```text
<entity>_key
```

### Examples

```text
customer_key
product_key
order_key
```

### Purpose

Provides stable and efficient identifiers for dimensional modeling and table relationships.

---

## Technical Columns

Technical and metadata columns must use the `dwh_` prefix.

### Pattern

```text
dwh_<column_name>
```

### Examples

```text
dwh_load_date
dwh_insert_date
dwh_update_date
```

### Purpose

Separates system-generated metadata from business attributes.

---

# ⚙️ Stored Procedure Naming Conventions

Stored procedures responsible for loading warehouse layers must follow the naming pattern below.

### Pattern

```text
load_<layer>
```

### Examples

```
load_bronze
load_silver
load_gold
```

### Purpose

Provides a consistent and predictable naming standard for ETL processes.

---

# 🎯 Design Principles

The warehouse follows a Medallion Architecture consisting of three logical layers:

| Layer  | Purpose                           |
| ------ | --------------------------------- |
| Bronze | Raw source-system data            |
| Silver | Cleansed and standardized data    |
| Gold   | Business-ready dimensional models |

### Key Objectives

* Maintain data lineage from source to reporting.
* Improve data quality through standardization and validation.
* Support scalable reporting and analytical workloads.
* Ensure consistent naming and modeling practices throughout the warehouse.

---

**Project:** SQL Server DataWarehouse Project
