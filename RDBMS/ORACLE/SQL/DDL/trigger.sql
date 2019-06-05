------------------ Trigger  ---------------------------

SELECT *
FROM all_triggers trg
WHERE 1=1
   AND UPPER(trg.table_name)   IN UPPER('db_derogation')
;




SELECT *
FROM all_triggers trg
WHERE 1=1
   AND UPPER(trg.table_name)   IN UPPER('editique_fluxdepot1')
;

SELECT *
FROM all_trigger_cols trg
WHERE 1=1
   AND UPPER(trg.table_name)   IN UPPER('db_valeur_rga')
;



----------------------------------------------------
--- Trigger / Source
-----------------------------------------------------

-- Trigger / Code source 
-- Pour source / Contenu
SELECT
  'Source =>' qry_cnt 
   --,src.name
   ,src.line
   ,src.text
   --,'all_source=>'
   --,src.*   
FROM 
   all_source src
WHERE 1=1
   AND src.owner       = 'OPS$EKIPCGI'
   AND src.type        = 'TRIGGER'
   AND src.name        = 'DBTRGA_INSUPD_DOCDOSADM_0CGI'  
ORDER BY 
   src.name, 
   src.line ASC
;



-- Trigger / Code source 
-- Pour source / Contenu
SELECT 
   src.name,
   --src.*
   src.line,
   src.text
FROM 
   all_source src
WHERE 1=1
--   AND src.owner = 'DBOFAP'
--   AND src.object_type = '
--   AND src.name = 'PCK_GEN_FLUX_FAX'  
   AND src.type = 'TRIGGER'
   AND lower(src.text) LIKE '%pfl_hist_courriers_0cgi%'

ORDER BY 
   src.name, 
   src.line ASC
;

