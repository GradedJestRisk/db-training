CREATE OR REPLACE FUNCTION RDOP.derniere_ligne (chaine IN VARCHAR2)
      RETURN VARCHAR2
  IS
  
    caractere_fin_ligne CONSTANT CHAR (1) := CHR (10);
   
  /* 
    debut_ligne_courante  PLS_INTEGER;
    fin_ligne_courante    PLS_INTEGER;
    taille_chaine         PLS_INTEGER;
     debut_ligne_unique          CONSTANT PLS_INTEGER := 0;
    */
    
    position_fin_ligne  PLS_INTEGER;
    chaine_monoligne    BOOLEAN;
        
    position_debut_derniere_ligne  PLS_INTEGER;
    longueur_derniere_ligne    PLS_INTEGER;
    
    dernier_caractere          CHAR(1);
    position_dernier_caractere PLS_INTEGER;
    
    derniere_ligne        VARCHAR2(32000);
    
    mode_recherche_avant        CONSTANT PLS_INTEGER :=  1;    
    mode_recherche_arriere      CONSTANT PLS_INTEGER := -1;
    
    position_debut_recherche    CONSTANT PLS_INTEGER := mode_recherche_arriere;
    premiere_occurence          CONSTANT PLS_INTEGER := 1;
    deuxieme_occurence          CONSTANT PLS_INTEGER := 2;
   
  BEGIN
  
    -- Cas aux limites
    
    -- Chaine presque vide
    IF chaine = CHR(10) THEN
      RETURN NULL;
    END IF;
    
    -- Mono-ligne
    position_fin_ligne := INSTR( chaine, caractere_fin_ligne);
    
    IF position_fin_ligne = 0 THEN
      chaine_monoligne := TRUE;
    END IF;
       
    IF chaine_monoligne THEN
    
       derniere_ligne := chaine;
       
    ELSE 
       
      dernier_caractere := SUBSTR(chaine, -1, 1);

      IF dernier_caractere = caractere_fin_ligne THEN 
      
         position_debut_derniere_ligne := INSTR(
          chaine, 
          caractere_fin_ligne,
          position_debut_recherche,  
          deuxieme_occurence 
         ) + 1 ;
         
         longueur_derniere_ligne := length(chaine) - position_debut_derniere_ligne;
         
      ELSE
      
       position_debut_derniere_ligne := INSTR(
        chaine, 
        caractere_fin_ligne,
        position_debut_recherche,  
        premiere_occurence 
       ) + 1 ;
       
        longueur_derniere_ligne := length(chaine) - position_debut_derniere_ligne;
              
      END IF; 

      derniere_ligne := SUBSTR(chaine, position_debut_derniere_ligne, longueur_derniere_ligne);
       
    END IF;
      
    RETURN(derniere_ligne);

  END derniere_ligne;
/