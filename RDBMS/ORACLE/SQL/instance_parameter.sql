------------------
-- Locale ----
------------------



-- Database parameter
select * from nls_database_parameters;


SELECT 
  'DB / Separators=>' rqt_cnt
  ,value                      nls_numeric_characters
  ,SUBSTR(value, 1, 1)        decimal_print
  ,ASCII(SUBSTR(value, 1, 1)) decimal_ascii_code
  ,SUBSTR(value, 2, 1)        group_print
  ,ASCII(SUBSTR(value, 2, 1)) group_asci_code
FROM 
  nls_database_parameters WHERE parameter = 'NLS_NUMERIC_CHARACTERS'
; 
