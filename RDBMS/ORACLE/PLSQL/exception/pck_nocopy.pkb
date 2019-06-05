CREATE OR REPLACE PACKAGE BODY pck_nocopy AS

PROCEDURE prc_exception_without_nocopy (p_error_message OUT VARCHAR2)
IS
BEGIN
  
  RAISE NO_DATA_FOUND;
   
EXCEPTION
   WHEN OTHERS THEN
   
      p_error_message := SQLERRM;
      RAISE;

END prc_exception_without_nocopy;


PROCEDURE prc_exception_with_nocopy (p_error_message OUT NOCOPY VARCHAR2)
IS
BEGIN
  
  RAISE NO_DATA_FOUND;
   
EXCEPTION
   WHEN OTHERS THEN
   
      p_error_message := SQLERRM;
      RAISE;

END prc_exception_with_nocopy;


PROCEDURE prc_test_exception
IS

  l_error_message VARCHAR2(1000);

BEGIN
  
  BEGIN
    prc_exception_without_nocopy( p_error_message => l_error_message );
  EXCEPTION
    WHEN OTHERS THEN
       dbms_output.put_line('prc_exception_without_nocopy - l_error_message: ' || l_error_message);
  END;

  BEGIN
    prc_exception_with_nocopy( p_error_message => l_error_message );
  EXCEPTION
    WHEN OTHERS THEN
       dbms_output.put_line('prc_exception_with_nocopy - l_error_message: ' || l_error_message);
  END;

END prc_test_exception;


END pck_nocopy;
/

