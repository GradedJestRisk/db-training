CREATE OR REPLACE PROCEDURE prc_debug_derniere_ligne
IS

  chaine          VARCHAR2(32767);
  l_derniere_ligne  VARCHAR2(32767);
  
  test_ko EXCEPTION;

BEGIN
 
 -- Nominal
 chaine :=     'ligne1' || CHR(10)
            || 'ligne2';

 l_derniere_ligne := derniere_ligne( chaine );
 IF l_derniere_ligne <> 'ligne2' THEN RAISE test_ko; END IF;
  
  -- Alternatif
  chaine := 'ligne1';
  
  l_derniere_ligne := derniere_ligne( chaine );
  IF l_derniere_ligne <> 'ligne1' THEN RAISE test_ko; END IF;  
    
  -- Exceptionnel
  chaine := 'ligne1' || CHR(10);

  l_derniere_ligne := derniere_ligne( chaine );
  IF l_derniere_ligne <> 'ligne1' THEN RAISE test_ko; END IF;

   
END prc_debug_derniere_ligne; 
