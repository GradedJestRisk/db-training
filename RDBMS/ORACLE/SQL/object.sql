select 
   ao.object_name,
   ao.object_type,
   ao.status
   --,ao.*
from all_objects ao
where 1=1
--   AND ao.owner = 'FAP'
   --AND ao.object_type IN ('PACKAGE','PACKAGE BODY')
   AND ao.object_name = UPPER('purge_table')
   --AND ao.status <> 'VALID'   
--ORDER BY 
--   ao.status ASC,
--   ao.object_name ASC
 ;
 
 
 
select 
   ao.object_name,
   ao.object_type,
   ao.status
   --,ao.*
from all_objects ao
where 1=1
   AND ao.owner = 'FAP'
   --AND ao.object_type IN ('PACKAGE','PACKAGE BODY')
   AND ao.object_name = 'PRC_PLSQL_SCOPE'
   --AND ao.status <> 'VALID'   
ORDER BY 
   ao.status ASC,
   ao.object_name ASC
 ;
 purge_table

select 
   ao.object_name,
   ao.object_type,
   ao.status
   --,ao.*
from all_objects ao
where 1=1
   AND ao.owner = 'DBOFAP'
   AND ao.object_type IN ('PACKAGE','PACKAGE BODY')
   --AND ao.object_name = 'PKG_GEN_FILIERE'
   AND ao.status <> 'VALID'   
ORDER BY 
   ao.status ASC,
   ao.object_name ASC
 ;
 
 select 
   ao.object_name,
   ao.object_type,
   ao.status,
   ao.last_ddl_time
   --,ao.*
from all_objects ao
where 1=1
   AND ao.owner = 'DBOFAP'
   AND ao.object_type IN ('PACKAGE','PACKAGE BODY')
   AND ao.object_name = 'PKG_GEN_FILIERE'
   --AND ao.status <> 'VALID'   
ORDER BY 
   ao.status ASC,
   ao.object_name ASC
   ;



 select 
   ao.object_name,
   ao.object_type,
   ao.status,
   ao.last_ddl_time
   --,ao.*
from all_objects ao
where 1=1
   AND ao.owner = 'DBOFAP'
   AND ao.object_type IN ('PACKAGE','PACKAGE BODY')
   --AND ao.object_name = 'PKG_GEN_FILIERE'
   --AND ao.status <> 'VALID'   
ORDER BY 
   ao.status ASC,
   ao.object_name ASC
   ;


-- Invalid objects 
 select 
   ao.owner,
   ao.object_name,
   ao.object_type,
   ao.status,
   ao.last_ddl_time
   --,ao.*
from all_objects ao
where 1=1
--   AND ao.owner = 'DBOFAP'
--   AND ao.object_type IN ('PACKAGE','PACKAGE BODY')
--   AND ao.object_name = 'PKG_GEN_FILIERE'
   AND ao.status <> 'VALID'   
   AND ao.object_type NOT IN ('SYNONYM')
ORDER BY 
   ao.owner,
   ao.status ASC,
   ao.object_name ASC
   ;


