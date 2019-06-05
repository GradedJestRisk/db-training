-- Object
-- Given a name
select 
   ao.owner,
   ao.object_name,
   ao.object_type,
   ao.status,
   ao.last_ddl_time
   --,ao.*
from all_objects ao
where 1=1
--   AND ao.owner = 'FAP'
   --AND ao.object_type IN ('PACKAGE','PACKAGE BODY')
   AND ao.object_name = UPPER('recuperer_duree_etapes_delete')
   --AND ao.status <> 'VALID'   
--ORDER BY 
--   ao.status ASC,
--   ao.object_name ASC
 ;
 
-- Object
-- Given a name-like 
select 
   ao.owner,
   ao.object_name,
   ao.object_type,
   ao.status,
   ao.last_ddl_time
   --,ao.*
from all_objects ao
where 1=1
--   AND ao.owner = 'FAP'
   --AND ao.object_type IN ('PACKAGE','PACKAGE BODY')
   AND ao.object_name  LIKE UPPER('%f_PFL_Ctrl_Spec%')
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



-- Recompile all schema invalid object
EXEC UTL_RECOMP.recomp_serial('OPS$EKIPCGI');

BEGIN

  DBMS_UTILITY.compile_schema(
    schema      => 'OPS$EKIPCGI', 
    compile_all => false
  );

END;
/



