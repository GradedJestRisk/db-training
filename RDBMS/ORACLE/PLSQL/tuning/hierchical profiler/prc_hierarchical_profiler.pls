CREATE OR REPLACE PROCEDURE 
   dbofap.prc_hierarchical_profiler
AS
   l_chaine VARCHAR2(100);
   
BEGIN

   dbms_hprof.start_profiling('temp', 'prc_hierarchical_profiler.txt');

   dbms_output.put_line('Start of prc_hierarchical_profiler');

   FOR i IN 1..2000 LOOP
      SELECT object_name INTO l_chaine FROM all_objects WHERE object_name = 'prc_hierarchical_profiler';
   END LOOP;
   
   FOR i IN 1..2000 LOOP
      prc_dbms_output();
   END LOOP;   
   
   dbms_hprof.stop_profiling;
   
END;
/