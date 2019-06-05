----------------------------- S�quence ----------------------------------

-- S�quence
-- Pour s�quence / nom
SELECT   
   'Séquence=>'              rqt_cnt
   ,sqc.sequence_owner       sqc_prp
   ,sqc.sequence_name        sqc_nm 
   ,sqc.*
FROM 
   all_sequences   sqc
WHERE 1=1
   AND   sqc.sequence_owner   =   'DBOFAP'
   AND   sqc.sequence_name    = 'SEQ_PARAM'
ORDER BY
   sqc.sequence_name          ASC
;

-- S�quence
-- Pour s�quence / nom (approximatif)
SELECT   
   'S�quence=>'              rqt_cnt
   ,sqc.sequence_owner       sqc_prp
   ,sqc.sequence_name        sqc_nm 
   ,sqc.*
FROM 
   all_sequences   sqc
WHERE 1=1
   --AND   sqc.sequence_owner   =   'DBOFAP'
   AND   REGEXP_LIKE(sqc.sequence_name, 'opvprep', 'i') 
ORDER BY
   sqc.sequence_name          ASC
;

ALTER SEQUENCE sys.jobseq START WITH 40845
;
select jobseq.nextval from dual;

ALTER SEQUENCE seq_id_alt_tar  CACHE 1000; 