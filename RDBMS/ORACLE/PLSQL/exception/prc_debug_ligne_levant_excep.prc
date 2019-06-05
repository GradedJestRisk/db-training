CREATE OR REPLACE PROCEDURE prc_debug_ligne_levant_excep
IS
  retval NUMBER;
  error_backtrace VARCHAR2(32767);

BEGIN
 
  error_backtrace :=    'ORA-06512: ¦ "RDOP.PCK_ERROR_RAW", ligne 45' || CHR(10)
                     || 'ORA-06512: ¦ "RDOP.PCK_ERROR_RAW", ligne 15';


  error_backtrace := 'ORA-06512: at "RDOP.PFL_P_ALIM_OFFRE_XML", line 553' || CHR(10);

  retval := rdop.pfl_k_erreur.numero_ligne_levant_exception ( error_backtrace );
  COMMIT;
   
END prc_debug_ligne_levant_excep; 
