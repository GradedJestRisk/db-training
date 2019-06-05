select * 
from 
  all_objects ao
where 1=1
  --and ao.object_type LIKE '%JAVA%'
  --and REGEXP_LIKE( object_name, 'facturat', 'i') ;
  and ao.objet
  and REGEXP_LIKE( object_name, 'webDiffusionDirecte', 'i') 
; 

select 
  aso.line, 
  aso.text
from all_source aso
where 1=1
  and aso.name = 'FacturationEkip'
;


select 
  aso.line, 
  aso.text
from all_source aso
where 1=1
  and REGEXP_LIKE( aso.name, '%KSL%', 'i')
;


select 
  aso.name,
  aso.line, 
  aso.text
from all_source aso
where 1=1
  and  aso.text LIKE '%KSLComm%'
;


select 
  --aso.name,
  --aso.line, 
  aso.text
from all_source aso
where 1=1
  and  aso.name = 'KSLComm'
ORDER BY 
  aso.line ASC
;