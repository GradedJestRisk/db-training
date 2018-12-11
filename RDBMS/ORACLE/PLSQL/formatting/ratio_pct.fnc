CREATE OR REPLACE FUNCTION ratio_pct (numerator IN NUMBER, denominator IN NUMBER) 
RETURN BINARY_INTEGER
AS

  l_ratio        NUMBER;
  ratio_pct    BINARY_INTEGER;
  
BEGIN
             
  l_ratio := ratio(
            numerator   => numerator, 
            denominator => denominator);           
            
   ratio_pct := ROUND(
                  (l_ratio * 100),
                  0);
                  
   RETURN(ratio_pct);

END ratio_pct;