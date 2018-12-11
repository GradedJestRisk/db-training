CREATE OR REPLACE FUNCTION gb(bytes IN NUMBER) 
RETURN NUMBER 
AS
  gb NUMBER;
BEGIN
             
   gb := ROUND(      --  k, m, g
               bytes  / POWER(1024, 3),
               2);

  RETURN(gb);

END gb;
/
