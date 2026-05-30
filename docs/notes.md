# SQL Server BULK INSERT & Parser Behavior Notes

Overview

During Bronze-layer ingestion and Silver-layer cleansing, several SQL Server parsing and datatype behaviors were explored while working with:

* BULK INSERT
* FIELDTERMINATOR
* ROWTERMINATOR
* hidden control characters
* malformed rows
* EOF handling
* implicit datatype conversion
* LEN() vs DATALENGTH()
* VARCHAR vs NVARCHAR

These observations helped improve understanding of how SQL Server processes raw file data during ETL operations.


## 1. Files Are Internally Stored as Byte Streams

CSV/text files are internally stored as continuous byte streams.

Example:

RAM,25
SHAM,30

Internally resembles:

52 41 4D 2C 32 35 0D 0A 53 48 41 4D 2C 33 30

Where:

Hex	Meaning
2C	comma ,
0D	carriage return \r
0A	line feed \n

Parser interpretation depends on:

* delimiters
* datatype rules
* parser implementation
* newline format
* malformed-row handling


## 2. Windows vs Linux Newline Formats

Common newline conventions:

OS	Newline
Windows	\r\n
Linux/macOS	\n

Equivalent representations:

Character	SQL	Decimal	Hex
Carriage Return	CHAR(13)	13	0D
Line Feed	CHAR(10)	10	0A

Windows-style newline:

\r\n = 0D0A

Linux-style newline:

\n = 0A


## 3. Why 0D and 0A Have Leading Zeroes

One byte:

* contains 8 bits
* is represented using 2 hexadecimal digits

Examples:

Decimal	Hex
13	0D
10	0A

A single hexadecimal digit represents only 4 bits, therefore two digits are required to represent one full byte.


## 4. Meaning of 0x Prefix

Hexadecimal literals are commonly written using:

0x

Example:

0x0D0A

Meaning:

interpret following values as hexadecimal bytes.


## 5. ASCII, Hexadecimal, and Unicode

ASCII assigns numeric values to characters.

Examples:

Character	Decimal	Hex
A	65	41
\r	13	0D
\n	10	0A

Unicode extends ASCII to support:

* multilingual text
* symbols
* emojis
* international character sets

NVARCHAR commonly stores Unicode using UTF-16 encoding.


## 6. VARCHAR vs NVARCHAR

VARCHAR

* non-Unicode datatype
* typically uses ~1 byte per character

NVARCHAR

* Unicode datatype
* typically uses ~2 bytes per character

Example:

Datatype	Character A
VARCHAR	~1 byte
NVARCHAR	~2 bytes

This directly affects:

DATALENGTH()

results.


## 7. LEN() vs DATALENGTH()

LEN()

* counts visible characters
* ignores trailing spaces

Example:

LEN('RAM   ') = 3

⸻

DATALENGTH()

* counts actual storage bytes
* includes:
    * trailing spaces
    * hidden characters
    * control characters

Useful for:

* whitespace validation
* hidden-character detection
* ETL cleansing checks


## 8. SQL Server Trailing Space Behavior

SQL Server commonly ignores trailing spaces during string comparison.

Example:

'RAM' = 'RAM   '

may evaluate as TRUE.

However leading spaces are not treated similarly.

Behavior may vary depending on:

* collation
* datatype
* SQL Server configuration


## 9. Control Characters

Control characters historically controlled:

* printers
* terminals
* cursor movement
* line positioning

Examples:

Character	Purpose
\r	move carriage to line start
\n	move to next line
\t	horizontal tab

They are called “control characters” because they primarily control formatting behavior instead of displaying visible text.


## 10. Hidden Control Characters in This Project

During Bronze-layer loading:

ROWTERMINATOR = '\n'

was used while source files likely contained Windows-style line endings:

\r\n

Result:

* \n acted as row terminator
* residual \r remained attached to imported values

This caused hidden carriage-return characters to appear inside imported data.

These were later cleaned in Silver layer using:

REPLACE(column, CHAR(13), '')
REPLACE(column, CHAR(10), '')


## 11. Why Hidden Characters Become Problematic

Hidden control characters:

* consume storage bytes
* may not display visually
* affect joins and comparisons
* create cleansing inconsistencies

Example:

RAM

and:

RAM\r

may visually appear identical while being physically different values.


## 12. Incomplete Row Behavior

Example:

Expected:

col1,col2,col3

Actual:

1,2

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


## 13. EOF (End Of File)

EOF means:

parser reached physical file end.

EOF is not:

* NULL
* blank
* space
* zero

It simply indicates no more bytes remain in the file.


## 14. EOF and Malformed Row Handling

Near EOF, parsers may tolerate certain incomplete trailing values differently compared to malformed rows occurring in the middle of the file.

Example:

1,2,
EOF

Possible behaviors:

* insert NULL
* ignore trailing value
* tolerate incomplete final row
* raise malformed-row error

Behavior depends on parser implementation and import settings.


## 15. MAXERRORS Behavior

Example:

MAXERRORS = 10

Meaning:

* SQL Server tolerates up to 10 malformed rows
* import stops after threshold is exceeded

Malformed rows may include:

* datatype conversion failures
* incorrect column counts
* truncation issues
* unrecoverable parsing errors


## 16. NULL vs Empty String vs Whitespace

NULL

Represents:

absence of value

⸻

Empty String ('')

Represents:

zero-length string value

⸻

Whitespace (' ')

Represents:

actual stored character data

Whitespace physically consumes storage bytes and may create hidden cleansing issues.


## 17. Import Behavior vs SQL Query Behavior

Behavior during BULK INSERT may differ from standard SQL expressions.

Example during import:

,,

may become:

* NULL
* empty string
* default value

depending on:

* datatype
* constraints
* parser behavior


## 18. Implicit Conversion Behavior

SQL Server implicit conversion commonly tolerates:

* leading spaces
* trailing spaces
* leading +
* leading -

Example:

CAST('   -5   ' AS INT)

works successfully.

Therefore:

* TRIM() is usually unnecessary for numeric/date conversion
* more important for string cleansing


## 19. Date Conversion Observations

Examples:

20260429
491125

may successfully convert to DATE.

SQL Server internally applies year cutoff logic:

Input	Interpreted Year
00–49	2000–2049
50–99	1950–1999

Examples:

* 491125 → 2049-11-25
* 500101 → 1950-01-01

Behavior depends on:

* server settings
* language settings
* DATEFORMAT configuration


## 20. Case Sensitivity

In this project environment:

* WHERE
* LIKE
* CASE

behaved case-insensitively due to SQL Server collation settings.

This behavior is not universal across all databases or collations.



## Final Observation

This project highlighted how ETL behavior depends on interaction between:

* parser implementation
* delimiters
* newline conventions
* datatype conversion
* control characters
* malformed-row handling
* SQL Server configuration
* storage encoding

Many behaviors are parser-specific and may vary across:

* SQL Server versions
* ETL tools
* operating systems
* CSV parsers
* cloud ingestion systems
