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

