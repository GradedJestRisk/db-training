
SET SERVEROUTPUT ON;

DECLARE 

   TYPE type_tab_table IS TABLE OF all_tables.table_name%TYPE;

   tab_table type_tab_table;
   requete   CLOB;
   nb_enreg  PLS_INTEGER;

BEGIN

   tab_table := type_tab_table('ALT_ALERT_LOGI_FAP', 'ALT_TAR', 'ECM_ELEMENT_COUT_MODELE', 'EVT_FAP_DETAIL', 'FILIERE', 'L_CCO_FAP', 'TRONCON', 'UL_FILIERE');
      
   FOR i IN tab_table.FIRST..tab_table.LAST LOOP

--      requete := 'SELECT COUNT(1) FROM ' || tab_table(i) || '_HISTO';
      requete := 'SELECT COUNT(1) FROM ' || tab_table(i);
      --dbms_output.put_line(requete);

      EXECUTE IMMEDIATE requete INTO nb_enreg; 

      -- ALT_TAR_HISTO 569
      -- dbms_output.put_line(tab_table(i) || ': '|| nb_enreg);

      -- 569
      dbms_output.put_line(nb_enreg);

   END LOOP;

 END;
/    


