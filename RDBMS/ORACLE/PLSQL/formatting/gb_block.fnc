CREATE OR REPLACE FUNCTION gb_from_block(block IN NUMBER) 
RETURN NUMBER 
AS
  gb NUMBER;
BEGIN
             
   gb := ROUND(      --  kilo  mega   giga
               (BLOCK / 8     / 1024  / 1024 ),
               2);

  RETURN(gb);

END gb_from_block;
/
