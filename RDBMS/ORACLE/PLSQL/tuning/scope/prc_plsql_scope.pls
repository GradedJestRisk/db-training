CREATE OR REPLACE PROCEDURE prc_plsql_scope AUTHID DEFINER AS
  l_object_name all_objects.object_name%TYPE;
BEGIN

   SELECT 
      obj.object_name
   INTO 
      l_object_name
   FROM (
      SELECT * 
      FROM all_objects ao 
      WHERE 1=1
         AND owner       = 'FAP' 
         AND object_name = UPPER('prc_plsql_scope')
   ) obj;
   
END;