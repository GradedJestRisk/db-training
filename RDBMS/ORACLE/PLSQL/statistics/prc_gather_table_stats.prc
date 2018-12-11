CREATE OR REPLACE PROCEDURE prc_gather_table_stats IS

   TYPE type_tab_table IS TABLE OF all_tables.table_name%TYPE;

   tab_table type_tab_table;

BEGIN

   tab_table := type_tab_table('alt_alert_logi_fap_histo_svg', 'alt_tar_histo_svg', 'ecm_histo_svg', 'evt_fap_detail_histo_svg', 'filiere_histo_svg', 'l_cco_fap_histo_svg', 'troncon_histo_svg', 'ul_filiere_histo_svg');
      
   FOR i IN tab_table.FIRST..tab_table.LAST LOOP

       dbms_stats.gather_table_stats(
             ownname           =>   NULL, 
             tabname           =>   UPPER(tab_table(i)),
             estimate_percent  =>   dbms_stats.auto_sample_size);

   END LOOP;
  
END prc_gather_table_stats;
/
