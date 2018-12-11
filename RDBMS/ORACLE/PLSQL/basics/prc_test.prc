CREATE OR REPLACE PROCEDURE prc_test IS

   l_foo tbl_test.foo%TYPE;

BEGIN

   SELECT foo INTO l_foo 
   FROM tbl_test
   WHERE id = 1;

END PRC_TEST;
/
