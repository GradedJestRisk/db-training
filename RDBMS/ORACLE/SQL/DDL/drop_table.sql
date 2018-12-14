/*
Are dropped:
- all rows from the table
- all indexes 
- all triggers 
- all partitions (use PURGE keyword for performance)

If the table is 
- a base table for a view
- referenced in a stored procedure, function, or package
Then 
- these objects are invalidated

All granted object privileges on the views, stored procedures, functions, or packages need not be regranted after table re-creation.
*/

DROP TABLE t;