CREATE OR REPLACE PROCEDURE prc_alter (p_message IN VARCHAR2 ) IS

   v_nom_schema           all_users.username%TYPE;
   v_nom_table            all_tables.table_name%TYPE;
   v_nom_colonne          all_tab_columns.column_name%TYPE;
   v_definition_colonne   VARCHAR2(100);

   PROCEDURE ajoute_colonne (   
     p_nom_schema           IN all_users.username%TYPE,    
     p_nom_table            IN all_tables.table_name%TYPE,
     p_nom_colonne          IN all_tab_columns.column_name%TYPE,
     p_definition_colonne   IN VARCHAR2
   ) 
   IS
   
     v_compteur              NUMBER(1);
     v_colonne_existe        BOOLEAN;
     v_requete_ajout_colonne VARCHAR2(1000);
   
   BEGIN
   
     SELECT COUNT(1) INTO v_compteur FROM all_tab_columns clm WHERE clm.owner = v_nom_schema AND clm.table_name = v_nom_table AND clm.column_name = v_nom_colonne;

      IF v_compteur >= 1 THEN 
        v_colonne_existe := TRUE;
      ELSE
        v_colonne_existe := FALSE;
      END IF;
        
     IF v_colonne_existe THEN
      
        dbms_output.put_line('La colonne existe deja, sortie du script sans action' );
        
     ELSE
      
        dbms_output.put_line('La colonne n existe pas, ajout de la colonne' );
        
        v_requete_ajout_colonne:= 'ALTER TABLE ' || v_nom_schema || '.' ||  v_nom_table || ' ADD ( ' || v_nom_colonne || ' ' || v_definition_colonne ||  ' )';

        dbms_output.put_line('Requete utilisee: ' || v_requete_ajout_colonne );
        
        EXECUTE IMMEDIATE(v_requete_ajout_colonne);
        
        dbms_output.put_line('La colonne a ete ajoutee' );
    
     END IF;
   
  END ajoute_colonne;
   

BEGIN

  v_nom_schema          := UPPER('rdop');
  v_nom_table           := UPPER('pfl_dataaff_tmp');
  
  
  -- Ajout du flag VAD
  v_nom_colonne         := UPPER('issu_vente_a_distance');
  v_definition_colonne  := 'VARCHAR2(1)';  

  ajoute_colonne(
     p_nom_schema           => v_nom_schema,
     p_nom_table            => v_nom_table,
     p_nom_colonne          => v_nom_colonne,
     p_definition_colonne   => v_definition_colonne
  );
  
  
  -- Ajout du flag DCE
  v_nom_colonne         := UPPER('a_demande_commenceme_execution');
  v_definition_colonne  := 'VARCHAR2(1)';  
  
  ajoute_colonne(
     p_nom_schema           => v_nom_schema,
     p_nom_table            => v_nom_table,
     p_nom_colonne          => v_nom_colonne,
     p_definition_colonne   => v_definition_colonne
  );

END prc_alter;
/
