CREATE OR REPLACE FUNCTION derniere_ligne (chaine IN VARCHAR2)
      RETURN VARCHAR2
  IS
  
    caractere_fin_ligne CONSTANT CHAR (1) := CHR (10);
   
  /* 
    debut_ligne_courante  PLS_INTEGER;
    fin_ligne_courante    PLS_INTEGER;
    taille_chaine         PLS_INTEGER;
     debut_ligne_unique          CONSTANT PLS_INTEGER := 0;
    */
    debut_derniere_ligne  PLS_INTEGER;
    fin_derniere_ligne  PLS_INTEGER;
    derniere_ligne        VARCHAR2(32000);
    
    
    mode_recherche_arriere      CONSTANT PLS_INTEGER := -1;
    position_debut_recherche    CONSTANT PLS_INTEGER := mode_recherche_arriere;
    premiere_occurence          CONSTANT PLS_INTEGER := 1;
   
  BEGIN
  
    debut_derniere_ligne := INSTR(
      chaine, 
      caractere_fin_ligne,
      position_debut_recherche,  
      premiere_occurence 
     ) + 1 ;
     
    fin_derniere_ligne :=  length(chaine) - 1;
     
    derniere_ligne := SUBSTR(chaine, debut_derniere_ligne, fin_derniere_ligne);
     
    RETURN(derniere_ligne);

  END derniere_ligne;
  /