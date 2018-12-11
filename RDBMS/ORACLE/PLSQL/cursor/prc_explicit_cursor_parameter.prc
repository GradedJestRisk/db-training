CREATE OR REPLACE PROCEDURE dbofap.prc_explicit_cursor_parameter IS

   object_name all_objects.object_name%TYPE;

   CURSOR cur_objects (p_owner IN all_objects.owner%TYPE, p_line_count PLS_INTEGER DEFAULT 100)  IS
      SELECT 
            ao.object_name
      FROM
          all_objects ao
      WHERE 1=1
         AND ao.owner    =    p_owner
         AND ROWNUM     <=   p_line_count;
   
BEGIN

   OPEN cur_objects( p_owner => 'DBOFAP' );
   LOOP

      FETCH cur_objects INTO object_name;
      EXIT WHEN cur_objects%NOTFOUND;

      dbms_output.put_line( 'Object:  ' || object_name ) ; 

   END LOOP;

   CLOSE cur_objects; 

END prc_explicit_cursor_parameter;
/
