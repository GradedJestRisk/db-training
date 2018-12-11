create or replace FUNCTION ND 
(
  P_NUMBER IN NUMBER 
) RETURN VARCHAR2 AS 

   s_format  VARCHAR2(30);
   s_nls     VARCHAR2(30);
   
BEGIN
  
   s_format  := '999G999G999D99';
   s_nls     := 'NLS_NUMERIC_CHARACTERS = '', ''';   
  
  --RETURN TO_CHAR(1234,'999G999G999D99', 'NLS_NUMERIC_CHARACTERS = '', ''');
  RETURN TO_CHAR(P_NUMBER, s_format, s_nls);
  
END ND;