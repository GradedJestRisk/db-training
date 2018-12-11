CREATE OR REPLACE PROCEDURE prc_plsqlscope_nousage AUTHID DEFINER AS

  l_first  NUMBER;
  l_second NUMBER;
  l_third  NUMBER;
  
BEGIN

   l_first  := 1;
   l_second := 2;
   l_third  := l_second;   
   
END;