

-- free space real-time..
SELECT 
   gb(free_space)
FROM 
   dba_temp_free_space
;
SELECT 
   t.plan_table_output
FROM 
   v$session   sss,
   gv$sql      v,
   TABLE(
         DBMS_XPLAN.DISPLAY('gv$sql_plan_statistics_all', 
                             NULL, 
                             'ADVANCED ALLSTATS LAST', 
                             'inst_id = '||v.inst_id||' AND sql_id = '''||v.sql_id||''' AND child_number = '||v.child_number) ) t
WHERE 1=1
   AND sss.username   =  'DBOFAP'
   AND sss.osuser     =  'fap'
   AND sss.status     =   'ACTIVE'
   AND sss.program    LIKE    'sqlplus%'
  -- AND sss.client_info IS NULL
   AND v.sql_id       = sss.sql_id
;

