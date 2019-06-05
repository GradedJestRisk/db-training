CREATE OR REPLACE PROCEDURE prc_debug IS

  string VARCHAR2(100);

BEGIN

  string := 'world';

    dbms_output.put_line('Hello, ' || string );

END prc_debug;
/

