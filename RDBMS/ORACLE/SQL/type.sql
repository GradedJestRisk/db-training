-- type header
SELECT * FROM all_types
WHERE type_name = upper('array_tarifs_t')
;

-- text
SELECT *
FROM all_type_versions
WHERE type_name = upper('ARRAY_MDLS_t')
ORDER BY line ASC   
;


SELECT
   atv.text
   ,INSTR(atv.text, ' ')
   ,SUBSTR(atv.text, 0, INSTR(atv.text,' '))
FROM 
   all_type_versions atv
WHERE 1=1
   AND type_name = 'TYPE_FILIERE_ROW'
   AND line > 1
ORDER BY line ASC   
;


