CREATE OR REPLACE PROCEDURE prc_shadowing ( shadowed_variable_parameter IN VARCHAR2 DEFAULT 'SET_IN_PARAMETER')  IS

   -- Shadow    : to block light 
   -- Overshadow: is to obscure something by casting a shadow 


   -- SITUATION  0 : PL parameter shadowing
   -- Parameter shadowing cannot occur: compiler prevent creation of homonyms between parameter and local variable 
   -- Message would be:
   --    Error(1,1): PLS-00410: duplicate fields in RECORD,TABLE or argument list are not permitted
   --   
   -- Uncomment following line to check
   -- shadowed_variable_parameter   VARCHAR2(100) := 'SET_IN_LOCAL_VARIABLE';
   
   -- DROP TABLE tbl_shadow;
   -- CREATE TABLE tbl_shadow ( id INTEGER, shadowed_variable_column VARCHAR2(100) );
   -- INSERT INTO tbl_shadow VALUES (1, 'FROM_COLUMN'); 
   -- COMMIT;

   -- Query   
   shadowed_variable_column_slct             VARCHAR2(100);
   shadowed_variable_column_where            VARCHAR2(100);
   data_not_found                            BOOLEAN;
   
   shadowed_variable_column         CONSTANT VARCHAR2(100)      := 'SET_IN_LOCAL_VARIABLE';
   l_id                             CONSTANT tbl_shadow.id%TYPE := 1;  
  
   -- Block
   block_variable                   VARCHAR2(100);

   
   -- SITUATION  1 : PL function shadowing
   -- Function shadowing cannot occur: compiler prevent creation of homonyms between parameter and local variable 
   -- Error is: 
   --     PLS-00305: previous use of 'SHADOWED_VARIABLE_FUNCTION' (at line 37) conflicts with this use

   -- Function
   -- shadowed_variable_function  VARCHAR2(100); -- =< Uncomment this to get compilation error
   
   FUNCTION shadowed_variable_function RETURN VARCHAR2 AS
   BEGIN
      RETURN('FROM FUNCTION');
   END shadowed_variable_function;
   
BEGIN

   -- SITUATION 2: Query shadowing / SELECT

   dbms_output.put_line('-');
   dbms_output.put_line('--- Does column name in SELECT clause from query shadow local variable  ? ---');   

   dbms_output.put_line('Variable: ' || shadowed_variable_column);   

   shadowed_variable_column_slct:= '';
   
   SELECT       
      t.shadowed_variable_column
   INTO
      shadowed_variable_column_slct
   FROM tbl_shadow t
   WHERE id = l_id;

   dbms_output.put_line('Column value: ' || shadowed_variable_column_slct);   
   
   IF shadowed_variable_column_slct <> shadowed_variable_column THEN
      dbms_output.put_line('Variable has been shadowed');   
   ELSE
      dbms_output.put_line('Variable NOT been shadowed');   
   END IF;
   
   -- SITUATION 3: Query shadowing / WHERE
   
   dbms_output.put_line('-');
   dbms_output.put_line('--- Does column name in WHERE clause from query shadow local variable  ? ---');   
   
   dbms_output.put_line('Variable: ' || shadowed_variable_column);
   
   data_not_found := FALSE;
   
   BEGIN   
   
      SELECT       
         t.shadowed_variable_column      
      INTO
         shadowed_variable_column_where      
      FROM tbl_shadow t
--    WHERE t.shadowed_variable_column  = prc_shadowing.shadowed_variable_column; -- <= This works and avoid shadowing..
      WHERE t.shadowed_variable_column  = shadowed_variable_column;
      
   EXCEPTION
   
      WHEN NO_DATA_FOUND THEN
        data_not_found :=  TRUE;
        dbms_output.put_line('Data not found');   
   END;
   
   IF data_not_found  THEN
      dbms_output.put_line('Variable has NOT been shadowed');   
   ELSE
      dbms_output.put_line('Variable has been shadowed');   
   END IF;
   
   
   -- SITUATION 4 : PL block shadowing
   
   dbms_output.put_line('-');
   dbms_output.put_line('--- Does variable in innermost block shadow outtermost one  ? ---');   
   
   dbms_output.put_line('Now in outtermost');
   
   block_variable := 'PROCEDURE';
   dbms_output.put_line('Variable is: ' || block_variable);
   
   << level_one_block >>
   
   DECLARE
       
      block_variable VARCHAR2(100);
       
   BEGIN
   
      dbms_output.put_line('Entering innermost');
       
      block_variable := 'LEVEL_ONE_BLOCK';
       
      dbms_output.put_line('Variable is: ' || block_variable);
       
      IF block_variable <> 'PROCEDURE' THEN
         dbms_output.put_line('Outtermost cariable is shadowed');   
      ELSE
         dbms_output.put_line('Outtermost cariable is NOT shadowed');   
      END IF;
     
   END level_one_block;
   
   dbms_output.put_line('Back to outtermost');
   dbms_output.put_line('Variable is: ' || block_variable);
   
   IF block_variable <> 'PROCEDURE' THEN
      dbms_output.put_line('Outtermost cariable is shadowed');   
   ELSE
      dbms_output.put_line('Outtermost cariable is NOT shadowed');   
   END IF;   
   
   -- SITUATION 5 : ??
   
   

END prc_shadowing;
/
