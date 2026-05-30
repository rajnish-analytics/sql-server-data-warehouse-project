# SQL Server BULK INSERT & Parser Behavior Notes

## Overview

During Bronze-layer ingestion and Silver-layer cleansing, multiple SQL Server parsing and datatype behaviors were observed while working with:

* BULK INSERT operations
* FIELDTERMINATOR and ROWTERMINATOR handling
* Hidden control characters (\r, \n)
* Malformed row handling
* End-of-file (EOF) behavior
* Implicit datatype conversions
* String functions (LEN vs DATALENGTH)
* VARCHAR vs NVARCHAR storage behavior

These observations helped build a deeper understanding of how SQL Server processes raw files during ETL pipelines.

---

## 1. File Storage as Byte Streams

CSV and text files are stored internally as continuous byte streams.

Example:

```
RAM,25
SHAM,30
```

Internal byte representation:

```
52 41 4D 2C 32 35 0D 0A 53 48 41 4D 2C 33 30
```

Where:

| Hex | Meaning              |
| --- | -------------------- |
| 2C  | Comma (,)            |
| 0D  | Carriage Return (\r) |
| 0A  | Line Feed (\n)       |

Parser behavior depends on:

* delimiters
* datatypes
* newline format
* ETL configuration
* malformed row handling

---

## 2. Windows vs Linux Newline Formats

| OS          | Newline Format |
| ----------- | -------------- |
| Windows     | \r\n           |
| Linux/macOS | \n             |

### Character Representation

| Character       | SQL      | Decimal | Hex |
| --------------- | -------- | ------- | --- |
| Carriage Return | CHAR(13) | 13      | 0D  |
| Line Feed       | CHAR(10) | 10      | 0A  |

Windows newline:

```
\r\n = 0D0A
```

Linux newline:

```
\n = 0A
```

---

## 3. Hexadecimal Representation

Each byte contains 8 bits and is represented using 2 hexadecimal digits.

Example:

| Decimal | Hex |
| ------- | --- |
| 13      | 0D  |
| 10      | 0A  |

---

## 4. Hex Prefix (0x)

Hexadecimal literals use the prefix:

```
0x
```

Example:

```
0x0D0A
```

Meaning: hexadecimal byte sequence.

---

## 5. ASCII and Unicode

| Character | Decimal | Hex |
| --------- | ------- | --- |
| A         | 65      | 41  |
| \r        | 13      | 0D  |
| \n        | 10      | 0A  |

* ASCII defines basic character encoding.
* Unicode extends support for multilingual and special characters.
* NVARCHAR uses UTF-16 encoding.

---

## 6. VARCHAR vs NVARCHAR

| Type     | Description | Storage       |
| -------- | ----------- | ------------- |
| VARCHAR  | Non-Unicode | ~1 byte/char  |
| NVARCHAR | Unicode     | ~2 bytes/char |

This directly impacts results of `DATALENGTH()`.

---

## 7. LEN() vs DATALENGTH()

### LEN()

* Returns character count
* Ignores trailing spaces

Example:

```
LEN('RAM   ') = 3
```

### DATALENGTH()

* Returns actual storage in bytes
* Includes trailing spaces and hidden characters

Used for:

* whitespace detection
* ETL validation
* hidden character detection

---

## 8. Trailing Space Behavior

SQL Server typically ignores trailing spaces in comparisons:

```
'RAM' = 'RAM   '  → TRUE
```

Leading spaces, however, affect comparisons.

Behavior depends on:

* collation
* datatype
* SQL Server configuration

---

## 9. Control Characters

| Character | Meaning         |
| --------- | --------------- |
| \r        | Carriage return |
| \n        | Line feed       |
| \t        | Tab             |

These characters control formatting rather than visible display.

---

## 10. Hidden Characters in ETL

During BULK INSERT operations:

```
ROWTERMINATOR = '\n'
```

But source files may use:

```
\r\n
```

Result:

* \n acts as row terminator
* \r remains in the data

This leads to hidden characters in loaded values.

---

## 11. Impact of Hidden Characters

Hidden control characters:

* are not visible
* consume storage
* break joins and comparisons
* create inconsistent data quality

Example:

```
RAM ≠ RAM\r
```

---

## 12. Incomplete Row Behavior

At file end or malformed rows:

```
1,2
```

Possible outcomes:

* NULL insertion
* row rejection
* column shifting
* partial ingestion

Depends on:

* parser
* ETL tool
* configuration

---

## 13. EOF (End of File)

EOF indicates the parser has reached the end of input file.

It is not:

* NULL
* empty string
* whitespace

It simply means no more data exists.

---

## 14. MAXERRORS Behavior

```
MAXERRORS = 10
```

Meaning:

* allows up to 10 errors before failing load

Errors include:

* datatype mismatches
* malformed rows
* truncation issues

---

## 15. NULL vs Empty String vs Whitespace

| Type | Meaning         |
| ---- | --------------- |
| NULL | No value        |
| ''   | Empty string    |
| ' '  | Space character |

Whitespace consumes storage and may affect transformations.

---

## 16. Import vs Query Behavior

BULK INSERT behavior may differ from SQL query behavior due to:

* parsing rules
* datatype inference
* constraints

---

## 17. Implicit Conversion

SQL Server supports implicit conversions in many cases:

Example:

```
CAST('   -5   ' AS INT) → valid
```

However, cleaning is still required for string fields.

---

## 18. Date Conversion Behavior

SQL Server supports conversion of numeric date formats like:

```
YYYYMMDD
YYMMDD
```

Two-digit year logic:

| Range | Year      |
| ----- | --------- |
| 00–49 | 2000–2049 |
| 50–99 | 1950–1999 |

---

## 19. Case Sensitivity

In this project environment:

* WHERE
* LIKE
* CASE comparisons

are case-insensitive due to SQL Server collation settings.

This is not universal across all databases.

---

## Final Observation

ETL behavior in SQL Server is influenced by multiple interacting factors:

* file encoding
* parser configuration
* delimiters
* datatype rules
* control characters
* SQL Server settings
* storage format (VARCHAR/NVARCHAR)

Understanding these behaviors is critical for building reliable data pipelines in real-world data engineering systems.
