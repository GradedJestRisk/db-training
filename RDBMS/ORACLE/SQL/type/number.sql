
-- Round
SELECT 
  2.3          valeur
  ,FLOOR(2.3)  floor_rounding
  ,TRUNC(2.3)  trunc
  ,CEIL(2.3)   ceil_rounding
FROM
   dual;



-- https://docs.oracle.com/cd/B19306_01/server.102/b14200/functions181.htm#i79330


-- Format: 
-- D => decima
-- MI => minus
-- L => local currency
-- https://docs.oracle.com/cd/B19306_01/server.102/b14200/sql_elements004.htm#i34570

-- Minimal format => inclure at least G and D 
-- 99G999D99


-- NLSD
-- - Decimal character
-- - Group separator
-- - Local currency symbol
-- - International currency symbol



-- Number (-10000) to char (AusDollars10.000,00-)
SELECT TO_CHAR(
    -10000,
    'L99G999D99MI',                                                        -- fmt                     
    'NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''AusDollars'' '       -- nls_param  
    ) "Amount"
FROM 
  DUAL;
  
  
-- Char (AusDollars10.000,00-) to number (-10000)
SELECT TO_NUMBER(
    'AusDollars10.000,00-',
    'L99G999D99MI',                                                        -- fmt                     
    'NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''AusDollars'' '       -- nls_param  
    ) "Amount"
FROM 
  DUAL;  
  
-- OK  
-- Char (AusDollars10.000,00-) to number (-10000)
SELECT 
  TO_NUMBER(
    '10,000.00',
    '99G999D99',                                                        -- fmt                     
    'NLS_NUMERIC_CHARACTERS = ''.,'' '       -- nls_param  
  ) 
FROM 
  DUAL;  
  
-- Give a try..  
-- Char (AusDollars10.000,00-) to number (-10000)
SELECT 
  TO_NUMBER(
    '10.000,00',
    '99G999D99',                                                        -- fmt                     
    'NLS_NUMERIC_CHARACTERS = '',.'' '       -- nls_param  
  ) to_number
FROM 
  DUAL;      

-- Give a try..  
-- Char (AusDollars10.000,00-) to number (-10000)
SELECT 
  TO_NUMBER(
    '00.420,51',
    '99G999D99',                                                        -- fmt                     
    'NLS_NUMERIC_CHARACTERS = '',.'' '       -- nls_param  
  ) to_number
FROM 
  DUAL;      
  
-- Give a try.. 
SELECT 
  TO_NUMBER(
    '420,51',
    '999D99',                                                        -- fmt                     
    'NLS_NUMERIC_CHARACTERS = '',.'' '       -- nls_param  
  ) to_number
FROM 
  DUAL;      
  
-- Avec séparateur de groupe  
WITH nombre AS (  
SELECT 
  TO_NUMBER(
    '12 420,51',
    '99G999D99',                                                        -- fmt                     
    'NLS_NUMERIC_CHARACTERS = '', '' '       -- nls_param  
  ) valeur
FROM 
  DUAL
)
SELECT 
  valeur
  ,TO_CHAR( valeur,  '99G999D99',  'NLS_NUMERIC_CHARACTERS = '',.'' ' )  
FROM 
  nombre
;
     

-- Sans séparateur de groupe  
WITH nombre AS (  
SELECT 
  TO_NUMBER(
    '420,51',
    '999D99',                                                        -- fmt                     
    'NLS_NUMERIC_CHARACTERS = '', '' '       -- nls_param  
  ) valeur
FROM 
  DUAL
)
SELECT 
  valeur
  ,TO_CHAR( valeur,  '999D99',  'NLS_NUMERIC_CHARACTERS = '',.'' ' )  
FROM 
  nombre
;

-- text minimal ?  
    
  
SELECT TO_CHAR(
    420.51,
    'TM9'  
    ) "Amount"
FROM 
  DUAL;  
  
SELECT TO_CHAR(
    420,51,
    'TM9',  
    'NLS_NUMERIC_CHARACTERS = '',.'' '       -- nls_param  
    ) "Amount"
FROM 
  DUAL;    
  
  
-- ALTER  
  
-- First: decimal
-- Second: group

-- American
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '.,';  

-- French
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ', ';  
  

-- TESTS


-- French
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ', ';  
 
-- Right format
SELECT 
  TO_NUMBER('420,51') 
FROM DUAL
;
-- OK

-- Wrong format
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '.,';  

SELECT 
  TO_NUMBER('420,51') 
FROM DUAL
;
-- KO: ORA-1722 Invalid number

-- select ascii(' ') from dual;
-- dot:    46
-- comma:  44
-- white:  32

SELECT 
  'Separators=>' rqt_cnt
  ,value                      nls_numeric_characters
  ,SUBSTR(value, 1, 1)        decimal_print
  ,ASCII(SUBSTR(value, 1, 1)) decimal_ascii_code
  ,SUBSTR(value, 2, 1)        group_print
  ,ASCII(SUBSTR(value, 2, 1)) group_asci_code
FROM 
  nls_session_parameters WHERE parameter = 'NLS_NUMERIC_CHARACTERS'
; 

select * from nls_database_parameters;



-- xs:double decimal = dot, no group separator
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '.';  
 
-- Right format
SELECT 
  TO_NUMBER('1420.51') 
FROM DUAL
;
-- OK

SELECT parameter, value FROM nls_session_parameters WHERE parameter = 'NLS_LANGUAGE'; 