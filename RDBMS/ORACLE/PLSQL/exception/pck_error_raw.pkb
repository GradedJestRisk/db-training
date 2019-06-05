CREATE OR REPLACE PACKAGE BODY pck_error_raw AS

--PROCEDURE p1_calling_p2;
PROCEDURE p2_calling_p3;
PROCEDURE p3_calling_p4;
PROCEDURE p4_throwing_error;

PROCEDURE p1_calling_p2
IS
  
BEGIN

   --RAISE NO_DATA_FOUND;
   NULL;
   p2_calling_p3;
   NULL;


EXCEPTION

   WHEN OTHERS THEN
   
      dbms_output.put_line('p1_calling_p2 - WHEN OTHERS at line ' || $$PLSQL_LINE);
   
      dbms_output.put_line('SQLERRM         in p1_calling_p2 : ' || SQLERRM); 
      dbms_output.put_line('Error stack     in p1_calling_p2 : ' || dbms_utility.format_error_stack());
      dbms_output.put_line('Error backtrace in p1_calling_p2 : ' || dbms_utility.format_error_backtrace());
   
      RAISE;

END p1_calling_p2;

PROCEDURE p2_calling_p3
IS
BEGIN

   NULL;
   p3_calling_p4;
   NULL;
   
EXCEPTION
   WHEN OTHERS THEN
   
      dbms_output.put_line('p2_calling_p3 - WHEN OTHERS at line ' || $$PLSQL_LINE);
      RAISE;

END p2_calling_p3;

PROCEDURE p3_calling_p4
IS
BEGIN

   NULL;
   p4_throwing_error;
   NULL;
   
EXCEPTION
   WHEN OTHERS THEN
   
      dbms_output.put_line('p3_calling_p4 - WHEN OTHERS at line ' || $$PLSQL_LINE);
      RAISE;

END p3_calling_p4;


PROCEDURE p4_throwing_error
IS

BEGIN

   NULL;
   dbms_output.put_line('Throwing NO_DATA_FOUND at line ' || $$PLSQL_LINE);
   RAISE NO_DATA_FOUND;
   NULL;
 
EXCEPTION

   WHEN OTHERS THEN

      dbms_output.put_line('p4_throwing_error - WHEN OTHERS at line ' || $$PLSQL_LINE);

      dbms_output.put_line('p4_throwing_error - SQLERRM : '        || SQLERRM); 
      dbms_output.put_line('p4_throwing_error - Error stack  : '   || dbms_utility.format_error_stack());
      dbms_output.put_line('p4_throwing_error - Error backtrace: ' || dbms_utility.format_error_backtrace());

      RAISE;

END p4_throwing_error;

END pck_error_raw;
/

