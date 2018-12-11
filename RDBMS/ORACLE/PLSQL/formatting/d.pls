create or replace FUNCTION fap.D (a_date IN DATE) RETURN VARCHAR2 AS 
BEGIN
  RETURN TO_CHAR(a_date,'DD/MM/YYYY');
END D;