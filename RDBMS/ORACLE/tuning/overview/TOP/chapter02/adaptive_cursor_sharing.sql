SET ECHO OFF
REM ***************************************************************************
REM ******************* Troubleshooting Oracle Performance ********************
REM ************************ http://top.antognini.ch **************************
REM ***************************************************************************
REM
REM File name...: adaptive_cursor_sharing.sql
REM Author......: Christian Antognini
REM Date........: March 2012
REM Description.: This script shows the pros and cons of adaptive cursor sharing.
REM Notes.......: This script works as of 11gR1 only.
REM Parameters..: -
REM
REM You can send feedbacks or questions about this script to top@antognini.ch.
REM
REM Changes:
REM DD.MM.YYYY Description
REM ---------------------------------------------------------------------------
REM 08.23.2012 Added test for implicit datatype conversion
REM 10.12.2012 Added child cursor invalidation for extending its selectivity
REM 07.12.2013 Added test for missing object statistics
REM 18.08.2016 Added test with equality predicate + test with expression
REM 08.11.2017 Added query to show information provided by v$sql_shared_cursor
REM ***************************************************************************

SET TERMOUT ON
SET FEEDBACK OFF
SET VERIFY OFF
SET SCAN ON

@../connect.sql

VARIABLE id NUMBER
VARIABLE n NUMBER

COLUMN is_bind_sensitive FORMAT A17
COLUMN is_bind_aware FORMAT A13
COLUMN is_shareable FORMAT A12
COLUMN peeked FORMAT A6
COLUMN predicate FORMAT A9 TRUNC
COLUMN column_name FORMAT A15
COLUMN load_optimizer_stats FORMAT A20
COLUMN bind_equiv_failure FORMAT A18

COLUMN sql_id NEW_VALUE sql_id

SET ECHO ON

REM
REM Setup test environment
REM

ALTER SYSTEM FLUSH SHARED_POOL;

ALTER SESSION SET cursor_sharing = 'EXACT';

DROP TABLE t;

CREATE TABLE t 
AS 
SELECT rownum AS id, 
       CASE WHEN rownum<100 THEN rownum ELSE 666 END AS n1, 
       CASE WHEN rownum<100 THEN rownum ELSE 666 END AS n2, 
       rpad('*',100,'*') AS pad 
FROM dual
CONNECT BY level <= 1000;

ALTER TABLE t ADD CONSTRAINT t_pk PRIMARY KEY (id);

CREATE INDEX t_n1_i ON t (n1);
CREATE INDEX t_n2_i ON t (n2);

BEGIN
  dbms_stats.gather_table_stats(
    ownname          => user, 
    tabname          => 't', 
    estimate_percent => 100, 
    method_opt       => 'for columns size 1, id, n1, pad, n2 size 100'
  );
END;
/

SELECT count(id), count(DISTINCT id), min(id), max(id) FROM t;

PAUSE

REM
REM Without bind variables different execution plans are used if the value
REM used in the WHERE clause change. This is because the query optimizer
REM recognize the different selectivity of the two predicates.
REM

SELECT count(pad) FROM t WHERE id < 990;

PAUSE

SELECT * FROM table(dbms_xplan.display_cursor(NULL, NULL, 'basic'));

PAUSE

SELECT count(pad) FROM t WHERE id < 10;

PAUSE

SELECT * FROM table(dbms_xplan.display_cursor(NULL, NULL, 'basic'));

PAUSE

REM
REM By default with bind variables the child cursor can be shared. Depending on 
REM the peeked value (10 or 990), a full table scan or an index range scan is used.
REM

EXECUTE :id := 10;

SELECT count(pad) FROM t WHERE id < :id;

PAUSE

SELECT * FROM table(dbms_xplan.display_cursor(NULL, NULL, 'basic'));

PAUSE

EXECUTE :id := 990;

SELECT count(pad) FROM t WHERE id < :id;

PAUSE

SELECT * FROM table(dbms_xplan.display_cursor(NULL, NULL, 'basic'));

PAUSE

REM
REM Display information about the associated child cursor
REM

SELECT sql_id
FROM v$sqlarea
WHERE sql_text = 'SELECT count(pad) FROM t WHERE id < :id';

SELECT child_number, is_bind_sensitive, is_bind_aware, is_shareable, plan_hash_value
FROM v$sql
WHERE sql_id = '&sql_id';

PAUSE

REM
REM After the previous (sub-optimal) execution the initial execution plan
REM is invalidated.
REM

SELECT count(pad) FROM t WHERE id < :id;

PAUSE

SELECT * FROM table(dbms_xplan.display_cursor(NULL, NULL, 'basic'));

PAUSE

EXECUTE :id := 10;

SELECT count(pad) FROM t WHERE id < :id;

PAUSE

SELECT * FROM table(dbms_xplan.display_cursor(NULL, NULL, 'basic'));

PAUSE

REM
REM Display information about the associated child cursors
REM

SELECT child_number, is_bind_sensitive, is_bind_aware, is_shareable, plan_hash_value
FROM v$sql
WHERE sql_id = '&sql_id'
ORDER BY child_number;

PAUSE

SELECT child_number, load_optimizer_stats, bind_equiv_failure
FROM v$sql_shared_cursor
WHERE sql_id = '&sql_id'
ORDER BY child_number;

PAUSE

SELECT * FROM table(dbms_xplan.display_cursor('&sql_id', NULL, 'basic'));

PAUSE

SELECT child_number, peeked, executions, rows_processed, buffer_gets
FROM v$sql_cs_statistics 
WHERE sql_id = '&sql_id'
ORDER BY child_number;

PAUSE

SELECT child_number, trim(predicate) AS predicate, low, high
FROM v$sql_cs_selectivity 
WHERE sql_id = '&sql_id'
ORDER BY child_number;

PAUSE

SELECT child_number, bucket_id, count
FROM v$sql_cs_histogram 
WHERE sql_id = '&sql_id'
ORDER BY child_number, bucket_id;

PAUSE

REM
REM Child cursors can be made unshareable to extend the predicate selectivity
REM associated to them

SELECT child_number, trim(predicate) AS predicate, low, high
FROM v$sql_cs_selectivity 
WHERE sql_id = '&sql_id'
ORDER BY child_number;

PAUSE

EXECUTE :id := 500;

SELECT count(pad) FROM t WHERE id < :id;

PAUSE

SELECT child_number, is_bind_sensitive, is_bind_aware, is_shareable, plan_hash_value
FROM v$sql
WHERE sql_id = '&sql_id'
ORDER BY child_number;

PAUSE

SELECT child_number, load_optimizer_stats, bind_equiv_failure
FROM v$sql_shared_cursor
WHERE sql_id = '&sql_id'
ORDER BY child_number;

PAUSE

SELECT child_number, trim(predicate) AS predicate, low, high
FROM v$sql_cs_selectivity 
WHERE sql_id = '&sql_id'
ORDER BY child_number;

PAUSE

REM
REM As of 11.1.0.7 it is possible to create a bind-aware cursor by specifying
REM the BIND_AWARE hint
REM

EXECUTE :id := 10;

SELECT /*+ bind_aware */ count(pad) FROM t WHERE id < :id;

PAUSE

SELECT * FROM table(dbms_xplan.display_cursor(NULL, NULL, 'basic'));

PAUSE

EXECUTE :id := 990;

SELECT /*+ bind_aware */ count(pad) FROM t WHERE id < :id;

PAUSE

SELECT * FROM table(dbms_xplan.display_cursor(NULL, NULL, 'basic'));

PAUSE

SELECT sql_id, child_number, is_bind_sensitive, is_bind_aware, is_shareable
FROM v$sql
WHERE sql_text = 'SELECT /*+ bind_aware */ count(pad) FROM t WHERE id < :id'
ORDER BY child_number;

PAUSE

REM
REM Show that adaptive cursor sharing is not used when an implicit datatype
REM conversion takes place
REM

VARIABLE idv VARCHAR2(10)

EXECUTE :idv := 10;

SELECT /*+ bind_aware */ count(pad) FROM t WHERE id < :idv;

PAUSE

SELECT * FROM table(dbms_xplan.display_cursor(NULL, NULL, 'basic'));

PAUSE

EXECUTE :id := 990;

SELECT /*+ bind_aware */ count(pad) FROM t WHERE id < :idv;

PAUSE

SELECT * FROM table(dbms_xplan.display_cursor(NULL, NULL, 'basic'));

PAUSE

SELECT sql_id, child_number, is_bind_sensitive, is_bind_aware, is_shareable
FROM v$sql
WHERE sql_text = 'SELECT /*+ bind_aware */ count(pad) FROM t WHERE id < :idv'
ORDER BY child_number;

PAUSE

REM
REM Show that with an equality predicate an histogram is necessary to get
REM several execution plans, and that even though the cursor is made bind aware
REM

REM note that only the column N2 has an histogram

SELECT column_name, histogram
FROM user_tab_col_statistics
WHERE table_name = 'T'
ORDER BY column_name;

PAUSE

REM the first series of queries is executed by referencing N1
REM => even though the cursor is bind aware a single execution plan is used

PAUSE

EXECUTE :n := 42;

SELECT count(pad) FROM t WHERE n1 = :n;

PAUSE

EXECUTE :n := 666;

SELECT count(pad) FROM t WHERE n1 = :n;
SELECT count(pad) FROM t WHERE n1 = :n;

PAUSE

EXECUTE :n := 42;

SELECT count(pad) FROM t WHERE n1 = :n;

PAUSE

SELECT sql_id, child_number, is_bind_sensitive, is_bind_aware, is_shareable, executions
FROM v$sql
WHERE sql_text = 'SELECT count(pad) FROM t WHERE n1 = :n'
ORDER BY child_number;

PAUSE

SELECT sql_id, child_number, trim(predicate) AS predicate, low, high
FROM v$sql_cs_selectivity 
WHERE sql_id = '&sql_id'
ORDER BY child_number;

PAUSE

REM the second series of queries is executed by referencing N2
REM => two execution plans are used

PAUSE

EXECUTE :n := 42;

SELECT count(pad) FROM t WHERE n2 = :n;

PAUSE

EXECUTE :n := 666;

SELECT count(pad) FROM t WHERE n2 = :n;
SELECT count(pad) FROM t WHERE n2 = :n;

PAUSE

EXECUTE :n := 42;

SELECT count(pad) FROM t WHERE n2 = :n;

PAUSE

SELECT sql_id, child_number, is_bind_sensitive, is_bind_aware, is_shareable, executions
FROM v$sql
WHERE sql_text = 'SELECT count(pad) FROM t WHERE n2 = :n'
ORDER BY child_number;

PAUSE

SELECT sql_id, child_number, trim(predicate) AS predicate, low, high
FROM v$sql_cs_selectivity 
WHERE sql_id = '&sql_id'
ORDER BY child_number;

PAUSE

REM
REM Show that adaptive cursor sharing is not used when a variable is involved 
REM in an expression. In fact, when an expression is involved, bind sensitivity
REM is not enabled.
REM

EXECUTE :id := 10;

select /*+ bind_aware */ count(pad) from t where id < :id*10;

PAUSE

SELECT sql_id, child_number, is_bind_sensitive, is_bind_aware, is_shareable
FROM v$sql
WHERE sql_text = 'select /*+ bind_aware */ count(pad) from t where id < :id*10'
ORDER BY child_number;

PAUSE

REM
REM Show that adaptive cursor sharing is not used when no object statistics  
REM are available. In fact, when no object statistics are available, bind 
REM sensitivity is not enabled.
REM

BEGIN
  dbms_stats.delete_table_stats(
    ownname          => user, 
    tabname          => 't', 
    cascade_indexes  => true
  );
END;
/

EXECUTE :id := 10;

select /*+ bind_aware */ count(pad) from t where id < :id;

PAUSE

SELECT sql_id, child_number, is_bind_sensitive, is_bind_aware, is_shareable
FROM v$sql
WHERE sql_text = 'select /*+ bind_aware */ count(pad) from t where id < :id'
ORDER BY child_number;

PAUSE

REM
REM Cleanup
REM

UNDEFINE sql_id

DROP TABLE t;
PURGE TABLE t;
