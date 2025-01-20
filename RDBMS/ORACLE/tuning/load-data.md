# Load data

## External tables

https://docs.oracle.com/en/database/oracle/oracle-database/23/sutil/oracle-external-tables-concepts.html

## SQL loader

https://docs.oracle.com/en/database/oracle/oracle-database/23/sutil/oracle-sql-loader-concepts.html

### Overview
Control file

Input:
- data
- control file

Output
- database
- a log file
- a bad file if there are rejected records
- a discard file.

### Paths

#### Conventional

The input records are parsed according to the field specifications, and each data field is copied to its corresponding bind array (an area in memory where SQL*Loader stores data to be loaded).

When the bind array is full (or no more data is left to read), an array insert operation is performed.

#### Direct Path

Direct path load is much faster than conventional path load, but entails several restrictions:
- views
- field defaults
- integrity constraints

https://docs.oracle.com/en/database/oracle/oracle-database/23/sutil/oracle-sql-loader-conventional-and-direct-loads.html#GUID-26686C49-D768-4F55-8AED-771B9A8C6552

A direct path load parses the input records according to the field specifications, converts the input field data to the column data type, and builds a column array.

The column array is passed to a block formatter, which creates data blocks in Oracle database block format. The newly formatted database blocks are written directly to the database, bypassing much of the data processing that normally takes place. 
