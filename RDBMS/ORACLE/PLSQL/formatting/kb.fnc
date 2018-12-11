CREATE OR REPLACE FUNCTION kb(bytes IN NUMBER) 
RETURN NUMBER 
AS
  kb NUMBER;
BEGIN
             
   kb := ROUND(      --  kilo
               (bytes / 1024 ),
               2);

  RETURN(kb);

END kb;
/
