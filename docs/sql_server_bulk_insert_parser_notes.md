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
RAM,25
SHAM,30


Internal byte representation:
52 41 4D 2C 32 35 0D 0A 53 48 41 4D 2C 33 30


Hex meaning:

| Hex | Meaning |
|-----|--------|
| 2C  | Comma (,) |
| 0D  | Carriage Return (\r) |
| 0A  | Line Feed (\n) |

Parser behavior depends on:
- Delimiters
- Datatype rules
- Encoding
- Newline format
- Malformed row handling

---

## 2. Windows vs Linux Newline Formats

| OS | Newline |
|----|--------|
| Windows | \r\n |
| Linux/macOS | \n |

ASCII representation:

| Character | SQL | Decimal | Hex |
|----------|-----|---------|-----|
| Carriage Return | CHAR(13) | 13 | 0D |
| Line Feed | CHAR(10) | 10 | 0A |

Windows:
\r\n = 0D0A

Linux/macOS:
\n = 0A


---

## 3. Why Hex Values Have Leading Zeros

A byte consists of 8 bits and is represented using 2 hex digits.

| Decimal | Hex |
|--------|-----|
| 13 | 0D |
| 10 | 0A |

---

## 4. Meaning of 0x Prefix

Hex values are written using:
0x

Example:
0x0D0A


Meaning: interpret as hexadecimal bytes.

---

## 5. ASCII, Hexadecimal, and Unicode

ASCII maps characters to numbers:

| Character | Decimal | Hex |
|----------|--------|-----|
| A | 65 | 41 |
| \r | 13 | 0D |
| \n | 10 | 0A |

Unicode extends ASCII for:
- Multilingual text
- Emojis
- Symbols

NVARCHAR uses UTF-16 encoding (~2 bytes per character).

---

## 6. VARCHAR vs NVARCHAR

VARCHAR:
- Non-Unicode
- ~1 byte/character

NVARCHAR:
- Unicode
- ~2 bytes/character

Impact:
- Storage size
- DATALENGTH()
- Performance

---

## 7. LEN() vs DATALENGTH()

LEN():
- Counts visible characters
- Ignores trailing spaces

Example:
LEN('RAM ') = 3

DATALENGTH():
- Counts actual stored bytes
- Includes spaces and hidden characters

Useful for detecting hidden characters in ETL.

---

## 8. SQL Server Trailing Space Behavior

SQL Server ignores trailing spaces in comparisons:
'RAM' = 'RAM ' → TRUE


But leading spaces are not ignored.

Behavior depends on collation.

---

## 9. Control Characters

Control characters are non-printing formatting characters:

| Character | Meaning |
|----------|--------|
| \r | Carriage return |
| \n | New line |
| \t | Tab |

---

## 10. Hidden Control Characters in This Project

Source files likely contained Windows line endings:
\r\n


But BULK INSERT used:
ROWTERMINATOR = '\n'


Result:
- \n terminated row
- \r remained in data

Fix:

```sql
REPLACE(column, CHAR(13), '')
REPLACE(column, CHAR(10), '')

11. Why Hidden Characters Are Problematic
Hidden characters:
Not visible
Consume storage
Break joins
Affect comparisons
Cause ETL inconsistencies
Example:
RAM ≠ RAM\r

12. Incomplete Row Behavior
Example:
1,2

Expected:
col1,col2,col3

Possible outcomes:
NULL insertion
Column shifting
Row rejection
Malformed row error
Depends on parser and settings.

13. EOF (End Of File)
EOF means:
No more data exists in file.
It is NOT:
NULL
Empty
Space
14. EOF vs Malformed Rows
At EOF:
1,2,

Possible outcomes:
NULL insertion
Ignore value
Partial row
Error
Depends on parser behavior.

15. MAXERRORS Behavior
Example:
MAXERRORS = 10

Meaning:
Allows 10 bad rows before failure
Errors include:
Type conversion failure
Column mismatch
Truncation
Parsing errors

16. NULL vs Empty String vs Whitespace
NULL:
No value
Empty string (''):
Zero-length value
Whitespace (' '):
Actual stored character
Whitespace consumes storage.

17. Import vs SQL Behavior
During BULK INSERT:
NULL / empty behavior may vary
Depends on:
Datatype
Constraints
Parser logic

18. Implicit Conversion Behavior
SQL Server allows flexible conversion:
CAST('   -5   ' AS INT)
Leading/trailing spaces ignored.

19. Date Conversion Behavior
Examples:
20260429
491125

Year interpretation:
| Range | Year      |
| ----- | --------- |
| 00–49 | 2000–2049 |
| 50–99 | 1950–1999 |


Example:
491125 → 2049-11-25
500101 → 1950-01-01

20. Case Sensitivity Behavior
In this system:
WHERE
LIKE
CASE
are case-insensitive due to collation.

Final Observation
ETL behavior depends on interaction of:
Parser implementation
Delimiters
Encoding
Datatypes
Control characters
Malformed row handling
SQL Server configuration
Behavior may vary across:
SQL Server versions
ETL tools
Operating systems
Cloud ingestion systems
