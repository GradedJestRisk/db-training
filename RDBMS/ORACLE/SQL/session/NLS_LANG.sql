-- https://fadace.developpez.com/oracle/nls/

--Par concat�nation des lignes NLS_LANGUAGE, NLS_TERRITORY et NLS_CHARACTERSETS, nous obtenons donc AMERICAN_AMERICA.WE8ISO8859P15. Soit en clair:
--
--La langue anglaise (AMERICAN)
--Des codes locaux am�ricains (pour le format des dates, des monnaies) (AMERICA)
--Un jeu de caract�re ISO (ISO8859) pour l'Europe de l'Ouest (WE) cod� sur 8 octets, avec une sp�cificit� (code page 15, pour int�grer le signe de l'Euro).


-- $NLS_LANG = FRENCH_FRANCE.WE8ISO8859P1
-- $NLS_LANG = FRENCH FRANCE WE8ISO8859P1
-- - NLS_LANGUAGE = FRENCH
-- - NLS_TERRITORY = FRANCE
-- - NLS_CHARACTERSETS = WE8ISO8859P1

--Si les variables NLS_CURRENCY, NLS_DUAL_CURRENCY, NLS_ISO_CURRENCY, NLS_DATE_FORMAT, NLS_TIMESTAMP_FORMAT, NLS_TIMESTAMP_TZ_FORMAT, NLS_NUMERIC_CHARACTERS 
--ne sont pas d�finies, elles sont issues par d�faut du NLS_TERRITORY.


-- Session parameter
SELECT parameter, value 
FROM nls_session_parameters 
WHERE parameter IN ('NLS_LANGUAGE','NLS_TERRITORY','NLS_NUMERIC_CHARACTERS'); 



SELECT 
  'Session / Separators=>' rqt_cnt
  ,value                      nls_numeric_characters
  ,SUBSTR(value, 1, 1)        decimal_print
  ,ASCII(SUBSTR(value, 1, 1)) decimal_ascii_code
  ,SUBSTR(value, 2, 1)        group_print
  ,ASCII(SUBSTR(value, 2, 1)) group_asci_code
FROM 
  nls_session_parameters WHERE parameter = 'NLS_NUMERIC_CHARACTERS'
; 


