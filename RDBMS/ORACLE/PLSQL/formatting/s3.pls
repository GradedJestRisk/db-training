create or replace FUNCTION s3 (s_string IN VARCHAR2) RETURN VARCHAR2 AS 
BEGIN
  RETURN TRIM(regexp_replace( s_string , '(...)', '\1 ' ));
END s3;