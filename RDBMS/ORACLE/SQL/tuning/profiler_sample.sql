CREATE OR REPLACE PROCEDURE do_something (p_times  IN  NUMBER) AS
  l_dummy  NUMBER;
BEGIN
  FOR i IN 1 .. p_times LOOP
    SELECT l_dummy + 1
    INTO   l_dummy
    FROM   dual;
  END LOOP;
END;
/

DECLARE
  l_result  BINARY_INTEGER;
BEGIN
  l_result := DBMS_PROFILER.start_profiler(run_comment => 'do_something: ' || SYSDATE);
  do_something(p_times => 100);
  l_result := DBMS_PROFILER.stop_profiler;
END;
/

SELECT 
   runid,
   run_date,
   run_comment,
    run_total_time
FROM   
   plsql_profiler_runs
ORDER BY 
   runid
;

SELECT 
   u.runid,
   u.unit_number,
   u.unit_type,
   u.unit_owner,
   u.unit_name,
   d.line#,
   d.total_occur,
   d.total_time,
   d.min_time,
    d.max_time
FROM   
   plsql_profiler_units u
       JOIN plsql_profiler_data d ON u.runid = d.runid AND u.unit_number = d.unit_number
WHERE  
   u.runid = 1
ORDER BY 
   u.unit_number, 
   d.line#
;

SELECT line || ' : ' || text
FROM   all_source
WHERE  owner = 'FAP'
AND    type  = 'PROCEDURE'
AND    name  = 'DO_SOMETHING'
;