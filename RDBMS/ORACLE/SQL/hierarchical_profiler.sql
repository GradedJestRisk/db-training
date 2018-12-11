---------------------------------------------------------------------------
--------------     Setup                    -------------
---------------------------------------------------------------------------

select * from sys.user_tab_stat_prefs ;
;

SELECT 
   *
FROM 
   dba_objects
WHERE 1=1
--   AND owner       = 'SYS'
--   AND object_type = 'PACKAGE'
   AND object_name = UPPER('dbms_hprof')
;
 
-- Need SYS privileges ?   
GRANT EXECUTE ON 
   dbms_hprof 
TO
   dbofap
;

CREATE DIRECTORY  
   tmp 
AS 
   '/product/FAP/tmp'
;


GRANT 
   READ, WRITE 
ON DIRECTORY 
   tmp 
TO 
   dbofap
;


SELECT 
   * 
FROM 
   all_directories dir
WHERE 1=1
   AND dir.directory_name = UPPER('TMP')
;

---------------------------------------------------------------------------
--------------     Create tables                  -------------
---------------------------------------------------------------------------

-- Create
-- sqlplus / @dbmshptab.sql

-- Check
-- sqlplus /
SELECT * FROM dbmshp_runs
;



---------------------------------------------------------------------------
--------------     Launch                  -------------
---------------------------------------------------------------------------

EXEC DBMS_HPROF.start_profiling('TMP','test_dbmshp.txt');
EXEC prc_dbms_output;
EXEC DBMS_HPROF.stop_profiling;


---------------------------------------------------------------------------
--------------      Analyse                    -------------
---------------------------------------------------------------------------
BEGIN
   DBMS_OUTPUT.PUT_LINE( DBMS_HPROF.ANALYZE( 'TMP', 'test_dbmshp.txt'));
END;
/

---------------------------------------------------------------------------
--------------      Generate HTML                   -------------
---------------------------------------------------------------------------

plshprof -output /product/FAP/tmp/output_html_format /product/FAP/tmp/test_dbmshp.txt


---------------------------------------------------------------------------
--------------     Get results                 -------------
---------------------------------------------------------------------------


SELECT 
   * 
FROM 
   dbofap.dbmshp_runs run
WHERE 1=1
--   AND run.runid = 1
;

SELECT * 
FROM 
   dbofap.dbmshp_function_info
;


SELECT * 
FROM 
   dbofap.dbmshp_parent_child_info
;


SELECT 
   level,
   RPAD(' ', (level-1)*2, ' ') || a.name AS name,
   TRUNC(a.subtree_elapsed_time / 1000000 / 60) min,
   a.function_elapsed_time,
   a.calls
FROM   (SELECT fi.symbolid,
               pci.parentsymid,
               RTRIM(fi.owner || '.' || fi.module || '.' || NULLIF(fi.function,fi.module), '.') AS name,
               NVL(pci.subtree_elapsed_time, fi.subtree_elapsed_time) AS subtree_elapsed_time,
               NVL(pci.function_elapsed_time, fi.function_elapsed_time) AS function_elapsed_time,
               NVL(pci.calls, fi.calls) AS calls
        FROM   dbofap.dbmshp_function_info fi
               LEFT JOIN dbofap.dbmshp_parent_child_info pci ON fi.runid = pci.runid AND fi.symbolid = pci.childsymid
        WHERE  fi.runid = 2
        AND    fi.module != 'DBMS_HPROF') a
CONNECT BY a.parentsymid = PRIOR a.symbolid
--START WITH a.parentsymid IS NULL
;



