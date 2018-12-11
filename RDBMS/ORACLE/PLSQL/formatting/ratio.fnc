CREATE OR REPLACE FUNCTION ratio (numerator IN NUMBER, denominator IN NUMBER) 
RETURN NUMBER
AS
  ratio        NUMBER;
BEGIN
           
   IF    ( numerator   IS NULL )
     OR ( denominator IS NULL )
     OR ( numerator   = 0 )
     OR ( denominator = 0 ) 
   THEN
      ratio := 0;
   ELSE
      ratio := numerator / denominator;
      ratio := ROUND( ratio, 2);
   END IF;
      
   RETURN(ratio);

END ratio;