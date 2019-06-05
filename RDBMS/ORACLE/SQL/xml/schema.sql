SELECT 
  'Schema=>' rqt_cnt
  ,sch.schema_url  sch_nm
  ,sch.schema      sch_cnt  
  ,'all_xml_schemas=>'
  ,sch.*
FROM 
  all_xml_schemas sch
WHERE 1=1
  AND sch.owner        =    'RDOP'
  AND sch.schema_url   LIKE '%11%'
;