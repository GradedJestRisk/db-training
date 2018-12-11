CREATE OR REPLACE PACKAGE pkg_test
IS

   PROCEDURE test;

END pkg_test;
/
CREATE OR REPLACE PACKAGE BODY pkg_test AS

PROCEDURE test
IS

   pourcentage_collecte  BINARY_INTEGER;
   requete               VARCHAR2(32000);
   nombre_enreg          PLS_INTEGER;

BEGIN

   FOR cur_table IN (

      SELECT 'TEST'      table_name FROM DUAL
      UNION ALL
      SELECT 'TBL_INDEX' table_name FROM DUAL

   ) LOOP
      
      requete := 'SELECT COUNT(1) FROM ' || cur_table.table_name;
      
      EXECUTE IMMEDIATE requete INTO nombre_enreg;

      CASE
         WHEN nombre_enreg < 100000   THEN
            pourcentage_collecte := 100;        
      END CASE;
      
      requete := 'BEGIN 
                     dbms_stats.gather_table_stats( 
                        ownname           => USER,
                        tabname           => :1,
                        estimate_percent  => :2); 
                  END;';

     EXECUTE IMMEDIATE requete USING cur_table.table_name, pourcentage_collecte;

   END LOOP; 
 
END test;



END pkg_test;
/
