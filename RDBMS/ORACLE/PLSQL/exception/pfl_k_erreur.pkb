CREATE OR REPLACE PACKAGE BODY pfl_k_erreur
IS

    --------------------------------------------------------
    --  But: Extraire de la backtrace le num�ro de la ligne 
    --       � l'origine de l'exception (derni�re) 
    --
    -- Exemple
    -- Backtrace: 
    --  ORA-06512: at "RDOP.PFL_P_ALIM_OFFRE_XML", line 2687
    --  ORA-06512: at "RDOP.PFL_P_ALIM_OFFRE_XML", line 553
    -- Sortie: 553
    ------------------------------------------------
    -- Gestion exception: 
    --  en cas de succ�s, renvoyer le num�rr de ligne
    --  en cas d'erreur,  renvoyer 0
    -------------------------------------------------
    --  Date        Version   Auteur     Description
    -------------------------------------------------
    --  22/05/2019    1.0      PTOP      Cr�ation
    --
    -------------------------------------------------

   FUNCTION numero_ligne_levant_exception (error_backtrace IN VARCHAR2)
      RETURN all_source.line%TYPE
   IS
      
      c_motif_ligne   CONSTANT CHAR (5) := 'line';
      
      derniere_ligne_backtrace  VARCHAR2(3200);
      
      position_debut_motif_ligne  PLS_INTEGER;
      position_debut_numero_ligne PLS_INTEGER;
      
      chaine_ligne_levant_exception all_source.line%TYPE;
      numero_ligne_levant_exception all_source.line%TYPE;
      
   BEGIN
   
      derniere_ligne_backtrace := derniere_ligne(error_backtrace);
     
      position_debut_motif_ligne   := INSTR (derniere_ligne_backtrace, c_motif_ligne);
      position_debut_numero_ligne  := position_debut_motif_ligne + LENGTH(c_motif_ligne);
     
      chaine_ligne_levant_exception :=  SUBSTR (derniere_ligne_backtrace, position_debut_numero_ligne);
             
      numero_ligne_levant_exception := TO_NUMBER(chaine_ligne_levant_exception);
      
      RETURN numero_ligne_levant_exception;
   
   EXCEPTION
   
   -- Ne pas g�rer d'erreur imbriqu�e 
   WHEN OTHERS THEN
    RETURN 0;   
      
   END numero_ligne_levant_exception;
   
END pfl_k_erreur;
/