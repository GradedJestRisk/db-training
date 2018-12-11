CREATE OR REPLACE FUNCTION mb(bytes IN NUMBER) 
RETURN NUMBER 
AS
  mb NUMBER;
BEGIN
             
   mb := ROUND(      --  kilo  mega
               (bytes / 1024 / 1024),
               2);

  RETURN(mb);

END mb;
/
