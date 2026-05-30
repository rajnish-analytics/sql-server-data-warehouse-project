# SQL Server BULK INSERT & Parser Behavior Notes

## Overview

During Bronze-layer ingestion and Silver-layer cleansing, several SQL Server parsing and datatype behaviors were explored while working with:

- BULK INSERT
- FIELDTERMINATOR
- ROWTERMINATOR
- Hidden control characters
- Malformed rows
- EOF handling
- Implicit datatype conversion
- LEN() vs DATALENGTH()
- VARCHAR vs NVARCHAR

These observations improved understanding of how SQL Server processes raw file data during ETL operations.

---

## 1. Files Are Internally Stored as Byte Streams

CSV/text files are stored as continuous byte streams.

### Example:
