CREATE OR REPLACE PACKAGE pfl_k_erreur
IS
   FUNCTION numero_ligne_levant_exception ( error_backtrace IN VARCHAR2)
   RETURN all_source.line%TYPE;

END pfl_k_erreur;
/