CREATE OR REPLACE PROCEDURE prc_debug IS
   i INTEGER;
BEGIN
  i := 9;
  dbms_output.put_line('Hello, world !');
END prc_debug;
/
