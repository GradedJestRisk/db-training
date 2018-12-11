CREATE OR REPLACE PROCEDURE dbofap.prc_debug_dbofap IS
   i INTEGER;
BEGIN
  i := 9;
  dbms_output.put_line('Hello, world !');
END prc_debug_dbofap;
/
