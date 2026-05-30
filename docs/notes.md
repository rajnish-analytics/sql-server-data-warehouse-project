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
