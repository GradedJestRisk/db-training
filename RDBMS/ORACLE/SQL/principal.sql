

------------------ GTT  ---------------------------








------------------ +e  ---------------------------


-- Synonyme: �tat
-- Par nom et propri�taire
SELECT 
    'Synonyme'        rqt_cnt 
   ,bjc.object_name   syn_nm
   ,bjc.owner         syn_prp
   ,bjc.status        syn_tt
   ,bjc.last_ddl_time syn_mdf_dt
FROM 
   all_objects  bjc
WHERE 1=1
   AND bjc.owner         =   'IFU_LINK'
   AND bjc.object_type   =   'SYNONYM'
   AND bjc.object_name   =   'PCK_CNF_UTIL'
;


-- Synonyme: objet r�f�renc�
-- Par nom et propri�taire
SELECT 
    'Synonyme'        rqt_cnt 
   ,syn.synonym_name  syn_nm
   ,syn.owner         syn_prp
   ,syn.db_link       syn_dbl
   ,syn.table_owner   syn_cbl_prp
   ,syn.table_name    syn_cbl_nm

FROM 
   all_synonyms syn
WHERE 1=1
   AND syn.owner          =   'IFU_LINK'
   AND syn.synonym_name   =   'PCK_CNF_UTIL'
;


-- Synonyme: objet r�f�renc�
-- Par nom et propri�taire
SELECT 
    'Synonyme'        rqt_cnt 
   ,syn.synonym_name  syn_nm
   ,syn.owner         syn_prp
   ,syn.db_link       syn_dbl
   ,syn.table_owner   syn_cbl_prp
   ,syn.table_name    syn_cbl_nm
   ,syn.*

FROM 
   all_synonyms syn
WHERE 1=1
  -- AND syn.owner          =   'IFU_LINK'
   AND syn.synonym_name   =   'PEG_PCK_DEVISE'
;

-- Invalid synonyms
select *
  from all_synonyms s
  join all_objects o
    on s.owner = o.owner
   and s.synonym_name = o.object_name
 where o.object_type = 'SYNONYM'
   and s.owner = user
   and o.status <> 'VALID'
;



-------------------- Code source --------------------------

/*
object_type

FUNCTION
PACKAGE
PACKAGE BODY
PROCEDURE

*/

-- Code source 
-- par nom d'objet
SELECT 
   --src.name,
   --src.*
   src.line,
   src.text
FROM user_source src
WHERE 1=1
--   AND src.object_type = '
   AND src.name = 'PCK_GEN_FLUX_FAX'  
   AND src.type = 'PACKAGE BODY'
ORDER BY src.name, src.line ASC
;




-- Code source 
-- par package - body
SELECT 
   --src.name,
   --src.*
   src.line,
   src.text
FROM user_source src
WHERE 1=1
--   AND src.object_type = '
   AND src.name = 'PCK_GEN_FLUX_FAX'  
   AND src.type = 'PACKAGE BODY'
ORDER BY src.name, src.line ASC
;


-- Code source 
-- Nombre lignes
SELECT COUNT(1)
FROM user_source src
;


-- Code source 
-- par package - body + contenu
SELECT 
   --src.name,
   --src.*
   src.line,
   src.text
FROM user_source src
WHERE 1=1
--   AND src.object_type = '
   AND src.name = 'PCK_GEN_FLUX_FAX'  
   AND src.type = 'PACKAGE BODY'
 --  AND src.text LIKE '%FUNCTION fct_maj_statut_fax_pegase%'
ORDER BY src.name, src.line ASC
;

SELECT 
*
--SUBSTR(src.text, 11, 30)
      FROM user_source src
      WHERE 1=1
         AND src.name = 'PCK_GEN_FLUX_FAX'  
         AND src.type = 'PACKAGE BODY'
         AND src.text LIKE '%- IN      :%'
         AND src.line BETWEEN 60 AND 78
;




SELECT 
   rgm.object_name,
   rgm.argument_name,
   rgm.data_type   
FROM all_arguments rgm
WHERE 1=1
   AND rgm.owner = 'PTOP'
   AND rgm.object_name = 'PRC_ENVOYER_DEM_ENVOI'
;

-- Exceptions / SQLCODE
-- 
select text 
from all_source 
where owner='SYS' and name='STANDARD' 
and lower(text) like '%exception_init%'
--and lower(text) LIKE '%54%'
;

-- Date de derni�re compilation

SELECT    
   t.timestamp dt_drn_cmp
FROM 
   dba_objects t
WHERE 1=1
   AND t.object_name = 'PCK_GEN_FLUX_FAX'
   AND t.object_type = 'PACKAGE BODY'
   AND t.owner       = 'PEGASE'
;  






-- Synonymes
-- Par nom de table

SELECT *
FROM all_synonyms snm
WHERE 1=1
   AND snm.table_name = 'TQ_ENVOI_FAX_SM1'
;

-- NLS_LANG instance
SELECT 
   nls.parameter, 
   nls.value
FROM v$nls_parameters nls
WHERE 1=1
   AND nls.parameter IN (
      'NLS_LANGUAGE',
      'NLS_TERRITORY',
      'NLS_CHARACTERSET'
)
;


-- Comparaison NLS client / instance
SELECT 
   prm_lng_ss.parameter prm_nm,
   prm_lng_ss.value     prm_ss_vlr,
   prm_lng_db.value     prm_db_vlr   
FROM 
   nls_session_parameters   prm_lng_ss,
   nls_database_parameters  prm_lng_db
WHERE 1=1
   AND prm_lng_db.parameter = prm_lng_ss.parameter
;




----------------------------- Objet ----------------------------------

-- Objet
-- Par nom 

SELECT 
   'Objet: '
   ,bjt.object_name  bjt_nm
   ,bjt.object_type  bjt_typ
   ,bjt.owner        bjt_prp
   ,bjt.status       bjt_tt
   ,bjt.created      bjt_crt_dt
   ,bjt.*
FROM 
   all_objects bjt
WHERE 1=1
   AND UPPER(bjt.object_name) = UPPER('pck_cnf_util')
;


----------------------------- Transaction ----------------------------------

SELECT 
   DECODE(NVL(taddr, 'A'), 'A',  'Aucune transaction en cours', 'Transaction en cours')
FROM v$session 
WHERE sid=(select sid from v$mystat where rownum=1)
;



select clb.ui_collaborateur, ora_rowscn  
from db_collaborateur_cs clb;


----------------------------- DB Link ----------------------------------

SELECT 
   * 
FROM
   all_db_links
WHERE 1=1
   AND
;

SELECT * FROM dba_db_links;

select * from dba_objects
;

select owner, db_link, username from dba_db_links;




----------------------------
----------- Job ---------
----------------------------


-- Job  de l'utilisateur
-- Tous
SELECT   
  'Job=>'            rqt_cnt
   ,job.job          job_dtf
   ,DECODE(job.broken, 'N', 'ACTIVE', 'Y', 'INACTIVE')           job_tt
   ,job.schema_user  schema_exec
   ,job.what         cmd
   ,job.failures     exec_last_error_count
   ,job.last_date    exec_last_sucessfull
   ,job.this_date    exec_current_start
   ,job.next_date    exec_next
   --,job.*
FROM 
   all_jobs job
WHERE 1=1
--   AND job.JOB = 1102
;

select * from db_job where is_job = 1487365
;

WHERE 1=1
   AND job.is_classe_evt   =   104
ORDER BY
   vnt_typ.cd_evt          ASC,
   vnt_typ.is_classe_evt   DESC
;

-- Tous (m�me ceux d'autres utilisateurs)
SELECT 
   job.schema_user,
   job.job job_id
FROM 
   v_dba_jobs   job 
WHERE 1=1
--   job.
ORDER BY
   job.job DESC
;

-- Supprimer
exec dbms_job.remove(1086); commit;

-- Stopper
exec dbms_job.broken(1095, TRUE); commit;



SELECT *
FROM 
   user_jobs
;


-- Partitions / Tables
SELECT * FROM all_part_tables
WHERE owner = 'DBOFAP'
;

-- Partitions / Segments
SELECT * FROM all_tab_partitions
WHERE table_owner = 'DBOFAP'
;

-- Partitions / Clefs
SELECT * FROM all_part_key_columns
WHERE owner = 'DBOFAP'
;