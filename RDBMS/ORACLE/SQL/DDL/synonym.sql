SELECT 
  'Synonym'
  ,syn.owner
  ,syn.synonym_name
  ,' TARGET IS :' 
  ,syn.db_link
  ,syn.table_name
FROM 
  all_synonyms syn
WHERE 1=1
  AND syn.owner = 'PUBLIC' --'OPS$EKIPCGI'
  AND REGEXP_LIKE (syn.table_name, 'rdo_f_alim_benef_effectif_0cgi', 'i' )  
;


SELECT  
  ao.*
FROM 
 all_objects ao 
WHERE 1=1
  AND REGEXP_LIKE (ao.object_name, 'rdo_f_alim_benef_effectif_0cgi', 'i' )  
;

SELECT 
  'Synonym'
  ,syn.owner
  ,syn.synonym_name
  ,' TARGET IS :' 
  ,syn.db_link
  ,syn.table_name
  ,ao.status
FROM 
  all_synonyms syn
    INNER JOIn all_objects ao On ao.object_name = syn.synonym_name
WHERE 1=1
  AND syn.owner = 'PUBLIC' --'OPS$EKIPCGI'
  AND REGEXP_LIKE (syn.table_name, 'rdo_f_alim_benef_effectif_0cgi', 'i' )  
;
