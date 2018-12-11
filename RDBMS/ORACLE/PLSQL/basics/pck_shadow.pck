CREATE OR REPLACE PACKAGE pck_shadow
IS
   PROCEDURE shadow_variable;

END pck_shadow;
/
CREATE OR REPLACE PACKAGE BODY pck_shadow AS


FUNCTION  shadowed_variable RETURN VARCHAR2
IS
BEGIN
   RETURN('FROM FUNCTION');
END;


PROCEDURE shadow_variable
IS
   shadowed_variable               VARCHAR2(32000);

BEGIN

   shadowed_variable := 'FROM VARIABLE';

   -- Reference
   dbms_output.put_line('shadowed_variable : ' || shadowed_variable );

  -- Give "PLS-00222: no function with name 'SHADOWED_VARIABLE' exists in this scope"
-- dbms_output.put_line('shadowed_variable() : ' || shadowed_variable() );

   dbms_output.put_line('shadowed_variable() : ' || pck_shadow.shadowed_variable() );

   -- Assignation
   dbms_output.put_line(' shadowed_variable := shadowed_variable; ' );
   shadowed_variable := shadowed_variable;

   dbms_output.put_line('shadowed_variable : ' || shadowed_variable );

   dbms_output.put_line(' shadowed_variable := pck_shadow.shadowed_variable; ' );
   shadowed_variable := pck_shadow.shadowed_variable;

   dbms_output.put_line('shadowed_variable : ' || shadowed_variable );

END shadow_variable;

END pck_shadow;
/
