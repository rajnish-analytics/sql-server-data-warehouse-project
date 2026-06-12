# SQL Server Data Ingestion, BULK INSERT & Parsing Notes

> **Note:**
> Many behaviors described in this document are implementation-specific observations made during this project. Results may vary across SQL Server versions, operating systems, file encodings, ETL tools, and database configurations.

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

A single hexadecimal digit represents only 4 bits, therefore two digits are required to represent one full byte.

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

ASCII assigns numeric values to characters.

Examples:

| Character | Decimal | Hex |
| --------- | ------- | --- |
| A         | 65      | 41  |
| \r        | 13      | 0D  |
| \n        | 10      | 0A  |

ASCII defines basic character encoding.

Unicode extends support for:

* multilingual text
* symbols
* emojis
* international character sets

NVARCHAR stores Unicode using UTF-16 encoding.

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

```sql
LEN('RAM   ') = 3
```

### DATALENGTH()

* Returns actual storage in bytes
* Includes trailing spaces, hidden characters, and control characters

Used for:

* whitespace detection
* ETL validation
* hidden character detection

---

## 8. Trailing Space Behavior

SQL Server typically ignores trailing spaces in comparisons:

```sql
'RAM' = 'RAM   '  → TRUE
```

Leading spaces, however, affect comparisons.

Behavior depends on:

* collation
* datatype
* SQL Server configuration

---

## 9. Control Characters

Control characters historically controlled:

* printers
* terminals
* cursor movement
* line positioning

| Character | Meaning         | Purpose                     |
| --------- | --------------- | --------------------------- |
| \r        | Carriage return | move carriage to line start |
| \n        | Line feed       | move to next line           |
| \t        | Tab             | horizontal tab              |

They are called “control characters” because they primarily control formatting behavior instead of displaying visible text.

---

## 10. Hidden Characters in ETL

During BULK INSERT operations:

```sql
ROWTERMINATOR = '\n'
```

But source files may use:

```
\r\n
```

Result:

* `\n` acts as row terminator
* residual `\r` remained attached in the data

This leads to hidden characters in loaded values.

This can be handled in two ways:

### a) During Bronze-layer Loading

By specifying the appropriate row terminator during `BULK INSERT`:

```sql
ROWTERMINATOR = '\r\n'  or  ROWTERMINATOR = '0x0D0A'
```

### b) During Silver-layer Cleansing

By removing residual control characters using:

```sql
REPLACE(column, CHAR(13), '')
REPLACE(column, CHAR(10), '')
```

---

## 11. Impact of Hidden Characters

Hidden control characters:

* consume storage bytes
* may not display visually
* affect joins and comparisons
* create cleansing inconsistencies

Example:

```
RAM ≠ RAM\r
```

---

## 12. Incomplete Row Behavior

Example:

Expected:

```
col1,col2,col3
```

Actual:

```
1,2
```

Possible outcomes depend on parser behavior and import settings:

* NULL insertion
* malformed-row detection
* shifted column alignment
* row rejection

Behavior varies across:

* SQL Server versions
* parsers
* ETL tools
* import configurations 

Observed behavior near EOF can differ from malformed rows occurring in the middle of a file. Depending on parser settings and row structure, SQL Server may tolerate, reject, or flag incomplete final rows.

---

## 13. EOF (End of File)

EOF indicates the parser has reached the end of input file.

It is not:

* NULL
* empty string
* whitespace

It simply indicates no more bytes remain in the file.

---

## 14. EOF and Malformed Row Handling

Near the EOF, parsers may tolerate certain trailing empty values or lines differently compared to malformed rows occurring mid-file.

Example:

```
1,2,
EOF
```

Possible behaviors:

* insert NULL
* ignore trailing value or lines
* tolerate incomplete final row
* raise malformed-row error

Behavior depends on parser implementation and import settings.

---

## 15. MAXERRORS Behavior

```sql
MAXERRORS = 10
```

Meaning:

* SQL Server tolerates up to 10 malformed rows
* import stops after threshold is exceeded

Malformed rows may include:

* datatype conversion failures
* incorrect column counts
* truncation issues
* unrecoverable parsing errors

---

## 16. NULL vs Empty String vs Whitespace

| Type   | Meaning         |
| ------ | --------------- |
| `NULL` | No value        |
| `''`   | Empty string    |
| `' '`  | Space character |

Whitespace physically consumes storage bytes and may create hidden cleansing issues.

---

## 17. Import Behavior vs SQL Query Behavior

Behavior may differ between SQL expressions and BULK INSERT operations.

### Files (CSV/Text)

Files are inherently treated as raw text streams during ingestion, removing the need for literal string qualifiers for dates or strings.

### BULK Load

BULK INSERT may determine outcomes using:

* import-specific layout flags
* table constraints
* parser rules
* datatype inference

Thus empty or whitespace fields may become:

* NULL
* empty strings
* default values

### SQL Engine

SQL expressions require explicit string literals such as `'YYYY-MM-DD'` to avoid interpretation conflicts during parsing and compilation.

### Best Practice — Raw String Ingestion

Ingest bulk data into staging tables using raw string (`VARCHAR`) datatypes first.

Benefits:

* preserves original source data
* reduces initial datatype conversion failures
* allows controlled validation and transformation later

---

## 18. Implicit Conversion Behavior

SQL Server implicit conversion commonly tolerates:

* leading spaces
* trailing spaces
* leading `+`
* leading `-`

Example:

```sql
CAST('   -5   ' AS INT) → valid
```

Therefore:

* `TRIM()` is usually unnecessary for numeric/date conversion
* `TRIM()` is important for string cleansing

---

## 19. Date Conversion Behavior

SQL Server supports conversion of numeric date formats like:

* `YYYYMMDD`
* `YYMMDD`
* `YYYY`

Two-digit year logic:

| Range | Year      |
| ----- | --------- |
| 00–49 | 2000–2049 |
| 50–99 | 1950–1999 |

Examples:

```text
491125 → 2049-11-25
500101 → 1950-01-01
```

Behavior depends on:

* server settings
* language settings
* DATEFORMAT configuration

---

## 20. Case Sensitivity

In this project environment:

* `WHERE`
* `LIKE`
* `CASE` comparisons

are case-insensitive due to SQL Server collation settings.

This behavior is not universal across all databases or collations.

---

## 21. Project-Specific Observations

During this project:

* Source files contained Windows-style CRLF line endings (`\r\n`).
* Bronze layer used `ROWTERMINATOR = '\n'`.
* Residual `CHAR(13)` values remained in imported text columns.
* Hidden control characters were removed during Silver-layer transformations.
* `DATALENGTH()` was preferred over `LEN()` when validating whitespace issues.
* Date conversion behavior was validated for both `YYYYMMDD` and `YYMMDD` formats.
* Case-insensitive comparisons were observed due to the active database collation.

---

## Key Takeaways

ETL behavior in SQL Server is influenced by multiple interacting factors:

* file encoding
* parser configuration
* delimiters
* newline conventions
* datatype rules
* control characters
* malformed-row handling
* SQL Server settings
* storage format (VARCHAR/NVARCHAR)

Many behaviors are parser-specific and may vary across:

* SQL Server versions
* ETL tools
* operating systems
* CSV parsers
* cloud ingestion systems

<div align="center">

### ◈ ◈ ◈

</div>