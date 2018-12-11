create or replace FUNCTION s (s_string IN VARCHAR2) RETURN VARCHAR2 AS 
BEGIN
  RETURN TRIM(s_string);
END s;