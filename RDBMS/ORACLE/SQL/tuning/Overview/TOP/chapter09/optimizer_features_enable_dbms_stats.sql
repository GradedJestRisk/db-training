SET ECHO OFF
REM ***************************************************************************
REM ******************* Troubleshooting Oracle Performance ********************
REM ************************* http://top.antognini.ch *************************
REM ***************************************************************************
REM
REM File name...: optimizer_features_enable_dbms_stats.sql
REM Author......: Christian Antognini
REM Date........: January 2015
REM Description.: This script shows that DBMS_STATS, specifically the gathering
REM               of histograms, is not controlled by OPTIMIZER_FEATURES_ENABLE.
REM               As a result, even though in 12.1 OPTIMIZER_FEATURES_ENABLE is
REM               set to 10.2.0.4, the estimation of the query optimizer can be
REM               based on top-frequency and hybrid histograms and, therefore,
REM               be different than the estimations of the 10.2.0.4 query
REM               optimizer.
REM Notes.......: Top-frequency and hybrid histograms are produced by 12.1 only
REM Parameters..: -
REM
REM You can send feedbacks or questions about this script to top@antognini.ch.
REM
REM Changes:
REM DD.MM.YYYY Description
REM ---------------------------------------------------------------------------
REM 
REM ***************************************************************************

SET TERMOUT ON
SET FEEDBACK OFF
SET VERIFY OFF
SET SCAN OFF

COLUMN column_name FORMAT A11

@../connect.sql

SET ECHO ON

REM
REM Setup test environment
REM

DROP TABLE t PURGE;

CREATE TABLE t 
AS 
SELECT rownum AS id, mod(rownum,255) AS n1, mod(rownum,256) AS n2, rpad('*',100,'*') AS pad 
FROM dual 
CONNECT BY level <= 10000;

PAUSE

ALTER SESSION SET optimizer_features_enable = '10.2.0.4';

REM
REM In 12.1: TOP-FREQUENCY histogram on column N1 and HYBRID histogram on column N2
REM In previous versions: HEIGHT BALANCED histogram on both column N1 and column N2
REM

BEGIN
  dbms_stats.gather_table_stats(ownname          => user,
                                tabname          => 't',
                                estimate_percent => dbms_stats.auto_sample_size,
                                method_opt       => 'for columns size 1 id, pad, n1 size 254, n2 size 254');
END;
/

SELECT column_name, histogram 
FROM user_tab_col_statistics 
WHERE table_name = 'T';

PAUSE

DELETE plan_table;
COMMIT;

BEGIN
  FOR i IN 0..255
  LOOP
    EXECUTE IMMEDIATE 'EXPLAIN PLAN SET statement_id = ''N1_'||i||''' FOR SELECT * FROM t WHERE n1 = '||i;
    EXECUTE IMMEDIATE 'EXPLAIN PLAN SET statement_id = ''N2_'||i||''' FOR SELECT * FROM t WHERE n2 = '||i;
  END LOOP;
END;
/

SELECT substr(statement_id,1,2) AS column_name, cardinality, count(*) 
FROM plan_table 
WHERE id = 1 
GROUP BY substr(statement_id,1,2), cardinality
ORDER BY 1, 2;

PAUSE

REM
REM HEIGHT BALANCED histogram on both column N1 and column N2
REM

BEGIN
  dbms_stats.gather_table_stats(ownname          => user,
                                tabname          => 't',
                                estimate_percent => 100,
                                method_opt       => 'for columns size 1 id, pad, n1 size 254, n2 size 254');
END;
/

SELECT column_name, histogram 
FROM user_tab_col_statistics 
WHERE table_name = 'T';

PAUSE

DELETE plan_table;
COMMIT;

BEGIN
  FOR i IN 0..255
  LOOP
    EXECUTE IMMEDIATE 'EXPLAIN PLAN SET statement_id = ''N1_'||i||''' FOR SELECT * FROM t WHERE n1 = '||i;
    EXECUTE IMMEDIATE 'EXPLAIN PLAN SET statement_id = ''N2_'||i||''' FOR SELECT * FROM t WHERE n2 = '||i;
  END LOOP;
END;
/

SELECT substr(statement_id,1,2) AS column_name, cardinality, count(*) 
FROM plan_table 
WHERE id = 1 
GROUP BY substr(statement_id,1,2), cardinality
ORDER BY 1, 2;

PAUSE

REM
REM Cleanup
REM

DROP TABLE t PURGE;
