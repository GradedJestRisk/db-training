CREATE OR REPLACE FUNCTION gb_from_block (block_count IN NUMBER) 
RETURN NUMBER 
AS
  size_gb        NUMBER;
  octet_in_block CONSTANT BINARY_INTEGER := 8192;
BEGIN
             
   size_gb := ROUND(                              --  kilo  mega   giga
               (block_count * octet_in_block / 1024     / 1024  / 1024 ),
               2);

  RETURN(size_gb);

END gb_from_block;