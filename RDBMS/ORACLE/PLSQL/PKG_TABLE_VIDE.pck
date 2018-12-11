CREATE OR REPLACE PACKAGE dbofap.pkg_purge_commun 
AS

   ---------------------------------------------------------------------------
   --------------      Types - Gestion des traces                -------------
   ---------------------------------------------------------------------------

  TYPE type_erreur IS RECORD (
    proprietaire     all_objects.owner%TYPE,
    nom_package      all_objects.object_name%TYPE,
    nom_objet        all_objects.object_name%TYPE,
    numero_ligne     PLS_INTEGER,
    message_erreur   VARCHAR2(256)
  );

  FUNCTION extraire_erreur (
               nom_objet      IN   all_objects.object_name%TYPE,
               message_erreur IN   VARCHAR2,
               backtrace      IN   VARCHAR2) 
   RETURN type_erreur;

   FUNCTION backtrace_sans_origine (backtrace IN VARCHAR2) RETURN VARCHAR2;

   ---------------------------------------------------------------------------
   --------------      Types - Purge                    -------------
   ------------------------------------------------------------------------

   TYPE type_entree_purge IS RECORD (
      table_source                 all_tables.table_name%TYPE,
      table_temporaire             all_tables.table_name%TYPE,
      table_historisation          all_tables.table_name%TYPE);
   
   TYPE type_tab_entree_purge IS 
   TABLE OF 
      type_entree_purge
   INDEX BY 
      BINARY_INTEGER;

   ---------------------------------------------------------------------------
   --------------      Gestion des traces                -------------
   ---------------------------------------------------------------------------


   PROCEDURE tracer(
      nom_objet   IN trace.tag%TYPE,
      message     IN trace.info%TYPE,
      nom_package IN all_objects.object_name%TYPE  DEFAULT 'PKG_PURGE_COMMUN' );

   PROCEDURE tracer_erreur_appelant (
               nom_objet   IN trace.tag%TYPE,
               backtrace   IN VARCHAR2,
               nom_package IN all_objects.object_name%TYPE DEFAULT 'PKG_PURGE_COMMUN');

   PROCEDURE tracer_erreur_appele ( 
               erreur IN type_erreur,
               nom_package IN all_objects.object_name%TYPE DEFAULT 'PKG_PURGE_COMMUN' );

   ---------------------------------------------------------------------------
   --------------     Purge                -------------
   ---------------------------------------------------------------------------

   PROCEDURE executer_purge(tab_entree_purge IN type_tab_entree_purge);

   PROCEDURE preparer_purge(tab_entree_purge IN type_tab_entree_purge);

   PROCEDURE preparer_purge_fil_inact;

END pkg_purge_commun;
/
CREATE OR REPLACE PACKAGE BODY dbofap.pkg_purge_commun
AS

---------------------------------------------------------------------------
--------------      Types Purge                    -------------
------------------------------------------------------------------------

excep_contrainte_inexistante EXCEPTION;

TYPE type_contrainte IS RECORD (
   nom_table                   all_constraints.table_name%TYPE,
   nom_contrainte              all_constraints.constraint_name%TYPE
);


TYPE type_tab_contrainte IS 
   TABLE OF 
      type_contrainte 
   INDEX BY 
      BINARY_INTEGER;

TYPE type_tab_clob IS 
   TABLE OF 
      CLOB
   INDEX BY 
      BINARY_INTEGER;


TYPE type_ddl_obj_dependant IS RECORD (
   tab_index                    type_tab_clob, 
   tab_contrainte               type_tab_clob,
   tab_cle_etrangere            type_tab_clob,
   tab_privilege                type_tab_clob,
   tab_cle_etrangere_ref        type_tab_clob  
);

TYPE type_table_purge IS RECORD (
   table_source                 all_tables.table_name%TYPE,
   table_temporaire             all_tables.table_name%TYPE,
   table_historisation          all_tables.table_name%TYPE,
   ddl_obj_dependant            type_ddl_obj_dependant,
   cle_etrangere_reference      type_tab_contrainte
);

TYPE type_tab_table_purge IS 
   TABLE OF 
      type_table_purge 
   INDEX BY 
      BINARY_INTEGER;

---------------------------------------------------------------------------
--------------     Types Gestion des traces                    -------------
---------------------------------------------------------------------------
c_name_delim  CONSTANT CHAR (1)  := '"';
c_dot_delim   CONSTANT CHAR (1)  := '.';
c_line_delim  CONSTANT CHAR (4)  := 'line';
c_eol_delim   CONSTANT CHAR (1)  := CHR (10);

---------------------------------------------------------------------------
--------------      Gestion des traces                    -------------
---------------------------------------------------------------------------

FUNCTION extraire_erreur (
               nom_objet      IN   all_objects.object_name%TYPE,
               message_erreur IN   VARCHAR2,
               backtrace      IN   VARCHAR2) 
   RETURN type_erreur
IS

   erreur  type_erreur;

   l_name_start_loc VARCHAR2(100);
   l_dot_loc        VARCHAR2(100);
   l_name_end_loc   VARCHAR2(100);
   l_line_loc       VARCHAR2(100);
   l_eol_loc        VARCHAR2(100);

BEGIN
   
   erreur.nom_objet      := nom_objet;
   erreur.message_erreur := message_erreur;


   l_name_start_loc := INSTR (backtrace, c_name_delim, 1, 1);
   l_dot_loc        := INSTR (backtrace, c_dot_delim);
   l_name_end_loc   := INSTR (backtrace, c_name_delim, 1, 2);
   l_line_loc       := INSTR (backtrace, c_line_delim);
   l_eol_loc        := INSTR (backtrace, c_eol_delim);
      
   erreur.proprietaire :=  SUBSTR(
                              backtrace,
                              l_name_start_loc  + 1,
                              l_dot_loc - l_name_start_loc - 1);

   erreur.nom_package := SUBSTR(
                           backtrace, 
                           l_dot_loc + 1, 
                           l_name_end_loc - l_dot_loc - 1);
   
   erreur.numero_ligne  := SUBSTR(
                           backtrace, 
                           l_line_loc + 5, 
                           l_eol_loc - l_line_loc - 5);

   RETURN erreur;

END extraire_erreur;


FUNCTION backtrace_sans_origine (backtrace  IN VARCHAR2) RETURN VARCHAR2
IS

   reste_backtrace VARCHAR2(32000);   

   l_eol_loc        VARCHAR2(100);

BEGIN

   l_eol_loc        := INSTR (backtrace, c_eol_delim);
      
   reste_backtrace := SUBSTR(
      backtrace,
      l_eol_loc);

   RETURN reste_backtrace;

END backtrace_sans_origine;


PROCEDURE tracer_erreur_appele ( 
               erreur      IN type_erreur,
               nom_package IN all_objects.object_name%TYPE DEFAULT 'PKG_PURGE_COMMUN' )   
IS

   message trace.info%TYPE;

BEGIN
   message := 'Erreur'
             || ' contenu :  '    || erreur.message_erreur 
             || ' lancee par '    || erreur.nom_package || '.' || erreur.nom_objet
             || ' a la ligne :  ' || erreur.numero_ligne;

  tracer(
      nom_objet   => erreur.nom_objet,
      message     => message,
      nom_package => nom_package);

END tracer_erreur_appele;

PROCEDURE tracer_erreur_appelant (
               nom_objet   IN trace.tag%TYPE,
               backtrace   IN VARCHAR2,
               nom_package IN all_objects.object_name%TYPE DEFAULT 'PKG_PURGE_COMMUN') 
IS

   message trace.info%TYPE;

BEGIN

  message := 'Erreur - Chaine d appel (appele => appelant): ' || backtrace_sans_origine(backtrace);

  tracer(
      nom_objet   => nom_objet,
      message     => message,
      nom_package => nom_package);

END tracer_erreur_appelant;

---------------------------------------------------------------------------
--------------      Purge                    -------------
------------------------------------------------------------------------

PROCEDURE print_clob_to_output (p_clob IN CLOB)  
IS  
   l_offset     INT := 1;  
BEGIN  
   
   IF p_clob IS NULL THEN
      dbms_output.put_line('(CLOB is empty)');  
      RETURN;
   END IF;
   
   LOOP  
      EXIT WHEN l_offset > dbms_lob.getlength(p_clob);  
      dbms_output.put_line( dbms_lob.substr( p_clob, 255, l_offset ) );  
      l_offset := l_offset + 255;  
   END LOOP;  


END print_clob_to_output;

PROCEDURE tracer(
   nom_objet   IN trace.tag%TYPE,
   message     IN trace.info%TYPE,
   nom_package IN all_objects.object_name%TYPE DEFAULT 'PKG_PURGE_COMMUN')
AS
   message_formate trace.info%TYPE;

BEGIN

   message_formate := nom_objet || ' : ' || message;

   -- Ecriture dans le fichier de log (écriture différée, à la fin du traitement)
   dbms_output.put_line( nom_objet || ' : '  || message);

   -- Ecriture dans la table de trace (écriture immédiate, visible de suite)
   toolbox.trace(
      p_tag  => nom_package,
      p_info => message_formate); 

END;

FUNCTION table_vide (nom_table IN all_tables.table_name%TYPE) RETURN BOOLEAN
AS 

   nom_objet       CONSTANT all_objects.object_name%TYPE := 'table_conforme';
   erreur          type_erreur;

   requete CLOB;
   presence_enregistrement BINARY_INTEGER;
BEGIN

   requete := 'SELECT COUNT(1) FROM '|| nom_table ||' WHERE ROWNUM = 1'; 

   EXECUTE IMMEDIATE requete INTO presence_enregistrement;

   IF presence_enregistrement = 1 THEN
      RETURN FALSE;
   ELSE
      RETURN TRUE;
   END IF;

EXCEPTION

      WHEN OTHERS THEN

      erreur := extraire_erreur (
                  nom_objet      => nom_objet,
                  message_erreur => SQLERRM, 
                  backtrace      => DBMS_UTILITY.format_error_backtrace);

      tracer_erreur_appele (erreur);      

      RAISE;

END table_vide;


FUNCTION table_existe (table_source all_tables.table_name%TYPE) RETURN BOOLEAN
AS 

  nom_objet       CONSTANT all_objects.object_name%TYPE := 'table_existe';
  erreur          type_erreur;

  existence_table BINARY_INTEGER;   

BEGIN

   SELECT 
      COUNT(1)
   INTO
      existence_table         
   FROM 
      user_tables  tbl
   WHERE 1=1
      AND tbl.table_name = table_source;

   IF existence_table = 0 THEN
      RETURN FALSE;
   END IF;

   RETURN TRUE;

EXCEPTION

      WHEN OTHERS THEN

      erreur := extraire_erreur (
                  nom_objet      => nom_objet,
                  message_erreur => SQLERRM, 
                  backtrace      => DBMS_UTILITY.format_error_backtrace);

      tracer_erreur_appele (erreur);      

      RAISE;

END table_existe;


FUNCTION table_conforme (table_source all_tables.table_name%TYPE) RETURN BOOLEAN
AS 

BEGIN

   IF NOT table_existe(table_source => table_source)  THEN
      RETURN FALSE;
   END IF;

   IF table_vide(nom_table => table_source)  THEN
      RETURN FALSE;
   END IF;

   RETURN TRUE;

END table_conforme;


PROCEDURE alimenter_ddl_contrainte (
               table_cible          IN all_tables.table_name%TYPE, 
               tab_ddl_contrainte   OUT type_tab_clob)
AS

  nom_objet       CONSTANT all_objects.object_name%TYPE := 'table_existe';
  erreur          type_erreur;

   CURSOR contrainte_ddl (table_cible all_tables.table_name%TYPE) IS
      SELECT 
         dbms_metadata.get_ddl (
            object_type   =>   'CONSTRAINT', 
            name          =>   cnt.constraint_name) ddl
   FROM 
      user_constraints cnt
   WHERE 1=1
      AND   cnt.table_name        =   UPPER(table_cible)
      AND   cnt.constraint_type   <> ('R');

BEGIN

  -- Contraintes: clef primaire et CHECK et attribut colonne (ex: name NOT NULL) 
   OPEN contrainte_ddl(table_cible);
   LOOP
      FETCH contrainte_ddl
      BULK COLLECT INTO tab_ddl_contrainte;
      EXIT WHEN contrainte_ddl%NOTFOUND;
   END LOOP;
   CLOSE contrainte_ddl;

EXCEPTION

      WHEN OTHERS THEN

      erreur := extraire_erreur (
                  nom_objet      => nom_objet,
                  message_erreur => SQLERRM, 
                  backtrace      => DBMS_UTILITY.format_error_backtrace);

      tracer_erreur_appele (erreur);      

      RAISE;

END alimenter_ddl_contrainte;

PROCEDURE alimenter_ddl_cle_etrangere (
            table_cible             IN  all_tables.table_name%TYPE, 
            tab_ddl_cle_etrangere   OUT type_tab_clob)
AS

  nom_objet       CONSTANT all_objects.object_name%TYPE := 'table_existe';
  erreur          type_erreur;

   CURSOR cle_etrangere_ddl (table_cible all_tables.table_name%TYPE) IS
      SELECT 
         dbms_metadata.get_ddl (
            object_type   =>   'REF_CONSTRAINT', 
            name          =>   cnt.constraint_name) ddl
   FROM 
      user_constraints cnt
   WHERE 1=1
      AND   cnt.table_name        =   UPPER(table_cible)
      AND   cnt.constraint_type   =   'R';

BEGIN

   OPEN cle_etrangere_ddl(table_cible);
   LOOP
      FETCH cle_etrangere_ddl
      BULK COLLECT INTO tab_ddl_cle_etrangere;
      EXIT WHEN cle_etrangere_ddl%NOTFOUND;
   END LOOP;
   CLOSE cle_etrangere_ddl;

EXCEPTION

      WHEN OTHERS THEN

      erreur := extraire_erreur (
                  nom_objet      => nom_objet,
                  message_erreur => SQLERRM, 
                  backtrace      => DBMS_UTILITY.format_error_backtrace);

      tracer_erreur_appele (erreur);      

      RAISE;

END alimenter_ddl_cle_etrangere;

PROCEDURE alimenter_ddl_index (
            table_cible     IN  all_tables.table_name%TYPE, 
            tab_ddl_index   OUT type_tab_clob)
AS

  nom_objet       CONSTANT all_objects.object_name%TYPE := 'table_existe';
  erreur          type_erreur;
   CURSOR index_ddl (table_cible all_tables.table_name%TYPE) IS
      SELECT 
         dbms_metadata.get_ddl (
            object_type   =>   'INDEX', 
            name          =>   ndx.index_name) ddl
      FROM 
         user_indexes ndx
      WHERE 1=1
         AND   ndx.table_name        =   UPPER(table_cible);

BEGIN

   OPEN index_ddl(table_cible);
   LOOP
      FETCH index_ddl
      BULK COLLECT INTO tab_ddl_index;
      EXIT WHEN index_ddl%NOTFOUND;
   END LOOP;
   CLOSE index_ddl;

EXCEPTION

      WHEN OTHERS THEN

      erreur := extraire_erreur (
                  nom_objet      => nom_objet,
                  message_erreur => SQLERRM, 
                  backtrace      => DBMS_UTILITY.format_error_backtrace);

      tracer_erreur_appele (erreur);      

      RAISE;

END alimenter_ddl_index;


PROCEDURE alimenter_ddl_privilege(
               table_cible         IN all_tables.table_name%TYPE, 
               tab_ddl_privilege   OUT type_tab_clob)
AS
   
  nom_objet       CONSTANT all_objects.object_name%TYPE := 'table_existe';
  erreur          type_erreur;

BEGIN
   
   -- Seul endroit où le DDL est statique
   -- Cause: il n'est pas possible d'obtenir les privilèges individuellement pour interroger dbms_metadata / OBJECT_GRANT
   -- Solution: extraction du code contenu dans l'installation automatisée (fap\bdd\install\divers\grant.sql)
   tab_ddl_privilege(1) := TO_CLOB('GRANT SELECT, UPDATE, INSERT, DELETE ON ' || table_cible || ' TO fap');

EXCEPTION

      WHEN OTHERS THEN

      erreur := extraire_erreur (
                  nom_objet      => nom_objet,
                  message_erreur => SQLERRM, 
                  backtrace      => DBMS_UTILITY.format_error_backtrace);

      tracer_erreur_appele (erreur);      

      RAISE;

END alimenter_ddl_privilege;

PROCEDURE alimenter_cle_etrang_ref_table (
               table_cible                 IN    all_tables.table_name%TYPE, 
               tab_contrainte              OUT   type_tab_contrainte,
               tab_cle_etrangere_ref_table OUT   type_tab_clob)
AS

  nom_objet       CONSTANT all_objects.object_name%TYPE := 'table_existe';
  erreur          type_erreur;

   CURSOR cle_etrang_table_contrainte (table_cible all_tables.table_name%TYPE) IS
      SELECT 
          cnt_fk_source.table_name,
          cnt_fk_source.constraint_name
      FROM 
         all_constraints cnt_fk_source
            INNER JOIN all_constraints cnt_pk_cible ON cnt_fk_source.r_constraint_name =  cnt_pk_cible.constraint_name
      WHERE 1=1
         AND cnt_fk_source.constraint_type =   'R' 
         AND cnt_pk_cible.constraint_type  IN  ('P' ,'U')
         AND cnt_pk_cible.table_name       =   table_cible;   


   CURSOR cle_etrang_table_ddl (table_cible all_tables.table_name%TYPE) IS
      SELECT 
         dbms_metadata.get_ddl (
            object_type   =>   'REF_CONSTRAINT', 
            name          =>   cnt_fk.constraint_name) ddl
      FROM   
         user_constraints cnt_fk
             JOIN user_constraints cnt_pk ON cnt_fk.r_constraint_name = cnt_pk.constraint_name
      WHERE  1=1
         AND   cnt_pk.constraint_type IN ('P','U')
         AND   cnt_fk.constraint_type  = 'R'
         AND   cnt_pk.table_name       = table_cible;

BEGIN

   OPEN cle_etrang_table_contrainte(table_cible);

   LOOP

        FETCH cle_etrang_table_contrainte
        BULK COLLECT INTO tab_contrainte;

        EXIT WHEN cle_etrang_table_contrainte%NOTFOUND;

   END LOOP;

   CLOSE cle_etrang_table_contrainte;

   OPEN cle_etrang_table_ddl(table_cible);

   LOOP

        FETCH cle_etrang_table_ddl
        BULK COLLECT INTO tab_cle_etrangere_ref_table;

        EXIT WHEN cle_etrang_table_ddl%NOTFOUND;

   END LOOP;

   CLOSE cle_etrang_table_ddl;

EXCEPTION

      WHEN OTHERS THEN

      erreur := extraire_erreur (
                  nom_objet      => nom_objet,
                  message_erreur => SQLERRM, 
                  backtrace      => DBMS_UTILITY.format_error_backtrace);

      tracer_erreur_appele (erreur);      

      RAISE;

END alimenter_cle_etrang_ref_table;

PROCEDURE alimenter_ddl_obj_dependant (table_cible IN all_tables.table_name%TYPE, ddl_obj_dependant OUT type_ddl_obj_dependant)
AS

BEGIN

   alimenter_ddl_index(
            table_cible    => table_cible,
            tab_ddl_index  =>  ddl_obj_dependant.tab_index);

   alimenter_ddl_contrainte(
            table_cible           =>   table_cible,
            tab_ddl_contrainte    =>   ddl_obj_dependant.tab_contrainte);

   alimenter_ddl_cle_etrangere(
            table_cible            => table_cible,
            tab_ddl_cle_etrangere  =>  ddl_obj_dependant.tab_cle_etrangere);

   alimenter_ddl_privilege(
            table_cible         => table_cible,
            tab_ddl_privilege   =>  ddl_obj_dependant.tab_privilege);

END alimenter_ddl_obj_dependant
;

PROCEDURE initialiser_purge (
   tab_entree_purge IN  type_tab_entree_purge, 
   tab_table_purge  OUT type_tab_table_purge)
AS

   excep_table_non_conforme              EXCEPTION;

   msg_excep_table_non_conforme CONSTANT VARCHAR2(1000)               := 'Une des tables n est pas conforme (inexistante ou vide), sortie immediate du traitement'; 
   nom_objet                    CONSTANT all_objects.object_name%TYPE := 'initialiser_purge';

BEGIN

   FOR i IN tab_entree_purge.FIRST..tab_entree_purge.LAST LOOP

      tab_table_purge(i).table_source        := UPPER(tab_entree_purge(i).table_source);
      IF NOT table_conforme(tab_table_purge(i).table_source) THEN RAISE excep_table_non_conforme; END IF;

      tab_table_purge(i).table_historisation        := UPPER(tab_entree_purge(i).table_historisation);
      IF NOT table_conforme(tab_table_purge(i).table_historisation) THEN RAISE excep_table_non_conforme; END IF;

      tab_table_purge(i).table_temporaire := UPPER(tab_entree_purge(i).table_temporaire);
      IF NOT table_conforme( table_source => tab_table_purge(i).table_temporaire) THEN RAISE excep_table_non_conforme; END IF;
         
      /*
      alimenter_ddl_obj_dependant(
            table_cible       => tab_table_purge(i).table_source, 
            ddl_obj_dependant => tab_table_purge(i).ddl_obj_dependant);

      alimenter_cle_etrang_ref_table (
               table_cible                   => tab_table_purge(i).table_source,
               tab_contrainte                => tab_table_purge(i).cle_etrangere_reference,
               tab_cle_etrangere_ref_table   => tab_table_purge(i).ddl_obj_dependant.tab_cle_etrangere_ref );   
   */


   END LOOP; 

EXCEPTION

   WHEN excep_table_non_conforme THEN

      tracer( 
         nom_objet => nom_objet,
         message   => msg_excep_table_non_conforme );      

      RAISE;

END initialiser_purge
;

/*

PROCEDURE afficher_contenu_purge (tab_table_purge IN type_tab_table_purge)
AS
BEGIN

   FOR i IN tab_table_purge.FIRST..tab_table_purge.LAST LOOP

        dbms_output.put_line('---------------------------');

        dbms_output.put_line('table_source :' || tab_table_purge(i).table_source);
        dbms_output.put_line('table_temporaire :' || tab_table_purge(i).table_temporaire);
        dbms_output.put_line('table_historisation :' || tab_table_purge(i).table_historisation);

        dbms_output.put_line('constrainte :');
        print_clob_to_output(tab_table_purge(i).ddl_obj_dependant.contrainte);

        dbms_output.put_line('cle_etrangere :');
        print_clob_to_output(tab_table_purge(i).ddl_obj_dependant.cle_etrangere);

        dbms_output.put_line('privilege :');
        print_clob_to_output(tab_table_purge(i).ddl_obj_dependant.privilege);

        --dbms_output.put_line('index_table :');
        --print_clob_to_output(tab_table_purge(i).ddl_obj_dependant.index_table);


        --dbms_output.put_line('deactivation cle_etrangere_vers_table :');
       -- print_clob_to_output(tab_table_purge(i).ddl_obj_dependant.desact_cle_etrang_vers_table);

        --dbms_output.put_line('activation cle_etrangere_vers_table :');
        --print_clob_to_output(tab_table_purge(i).ddl_obj_dependant.act_cle_etrang_vers_table);

   END LOOP; 

END afficher_contenu_purge;
*/

PROCEDURE supprimer_table(table_cible IN all_tables.table_name%TYPE)
AS
  nom_objet       CONSTANT all_objects.object_name%TYPE := 'table_existe';
  erreur          type_erreur;
   requete CLOB;
BEGIN

   requete := 'DROP TABLE ' || table_cible;
   EXECUTE IMMEDIATE requete;

EXCEPTION

      WHEN OTHERS THEN

      erreur := extraire_erreur (
                  nom_objet      => nom_objet,
                  message_erreur => SQLERRM, 
                  backtrace      => DBMS_UTILITY.format_error_backtrace);

      tracer_erreur_appele (erreur);      

      RAISE;

END supprimer_table;

PROCEDURE renommer_table(table_source IN all_tables.table_name%TYPE, table_cible IN all_tables.table_name%TYPE)
AS
   nom_objet       CONSTANT all_objects.object_name%TYPE := 'table_existe';
   erreur          type_erreur;
   requete CLOB;
BEGIN

   requete := 'RENAME ' || table_source || ' TO ' || table_cible;
   EXECUTE IMMEDIATE requete;

EXCEPTION

      WHEN OTHERS THEN

      erreur := extraire_erreur (
                  nom_objet      => nom_objet,
                  message_erreur => SQLERRM, 
                  backtrace      => DBMS_UTILITY.format_error_backtrace);

      tracer_erreur_appele (erreur);      

      RAISE;

END renommer_table;

PROCEDURE modifier_cle_etrangere_table(activer BOOLEAN, tab_contrainte IN type_tab_contrainte)
AS
  nom_objet       CONSTANT all_objects.object_name%TYPE := 'table_existe';
  erreur          type_erreur;

   requete CLOB;
   action  VARCHAR2(7);
BEGIN

   IF activer THEN
      action := 'ENABLE';
   ELSE
      action := 'DISABLE';
   END IF;

   FOR i IN tab_contrainte.FIRST..tab_contrainte.LAST LOOP

      requete := 'ALTER TABLE ' || tab_contrainte(i).nom_table || ' ' || action  || ' CONSTRAINT ' || tab_contrainte(i).nom_contrainte ;

      EXECUTE IMMEDIATE requete;

   END LOOP;

EXCEPTION

      WHEN OTHERS THEN

      erreur := extraire_erreur (
                  nom_objet      => nom_objet,
                  message_erreur => SQLERRM, 
                  backtrace      => DBMS_UTILITY.format_error_backtrace);

      tracer_erreur_appele (erreur);      

      RAISE;

END modifier_cle_etrangere_table;

PROCEDURE supprimer_cle_etrang_ref_table(tab_contrainte IN type_tab_contrainte)
AS
  nom_objet       CONSTANT all_objects.object_name%TYPE := 'table_existe';
  erreur          type_erreur;

   requete CLOB;   
BEGIN

   FOR i IN tab_contrainte.FIRST..tab_contrainte.LAST LOOP

      requete := 'ALTER TABLE ' || tab_contrainte(i).nom_table || ' DROP CONSTRAINT ' || tab_contrainte(i).nom_contrainte ;

      EXECUTE IMMEDIATE requete;

   END LOOP;

EXCEPTION

      WHEN OTHERS THEN

      erreur := extraire_erreur (
                  nom_objet      => nom_objet,
                  message_erreur => SQLERRM, 
                  backtrace      => DBMS_UTILITY.format_error_backtrace);

      tracer_erreur_appele (erreur);      

      RAISE;

END supprimer_cle_etrang_ref_table;


PROCEDURE recreer_cle_etrang_ref_table(tab_cle_etrangere_ref IN type_tab_clob)
AS
  nom_objet       CONSTANT all_objects.object_name%TYPE := 'table_existe';
  erreur          type_erreur;
BEGIN

   FOR i IN tab_cle_etrangere_ref.FIRST..tab_cle_etrangere_ref.LAST LOOP

      EXECUTE IMMEDIATE tab_cle_etrangere_ref(i);

   END LOOP;

EXCEPTION

      WHEN OTHERS THEN

      erreur := extraire_erreur (
                  nom_objet      => nom_objet,
                  message_erreur => SQLERRM, 
                  backtrace      => DBMS_UTILITY.format_error_backtrace);

      tracer_erreur_appele (erreur);      

      RAISE;

END recreer_cle_etrang_ref_table;

PROCEDURE executer_tableau_ddl (tab_ddl IN type_tab_clob)
AS
  nom_objet       CONSTANT all_objects.object_name%TYPE := 'table_existe';
  erreur          type_erreur;
BEGIN
   
   IF tab_ddl.COUNT > 0 THEN 

      FOR i IN tab_ddl.FIRST..tab_ddl.LAST LOOP
         print_clob_to_output(tab_ddl(i));

         BEGIN
            EXECUTE IMMEDIATE tab_ddl(i);
         EXCEPTION
         WHEN OTHERS THEN     
            IF SQLCODE = -01442 THEN
               NULL;
            END IF;           
         END;

      END LOOP; 

   END IF;

EXCEPTION

      WHEN OTHERS THEN

      erreur := extraire_erreur (
                  nom_objet      => nom_objet,
                  message_erreur => SQLERRM, 
                  backtrace      => DBMS_UTILITY.format_error_backtrace);

      tracer_erreur_appele (erreur);      

      RAISE;

END executer_tableau_ddl;


PROCEDURE recreer_objet_dependant (ddl_obj_dependant IN type_ddl_obj_dependant)
AS

BEGIN

   executer_tableau_ddl( tab_ddl => ddl_obj_dependant.tab_index);
   executer_tableau_ddl( tab_ddl => ddl_obj_dependant.tab_contrainte);
   executer_tableau_ddl( tab_ddl => ddl_obj_dependant.tab_cle_etrangere);
   executer_tableau_ddl( tab_ddl => ddl_obj_dependant.tab_privilege);

END recreer_objet_dependant;

PROCEDURE remplacer_table_source (tab_table_purge IN type_tab_table_purge)
AS
BEGIN

   FOR i IN tab_table_purge.FIRST..tab_table_purge.LAST LOOP

      supprimer_cle_etrang_ref_table(
         tab_contrainte => tab_table_purge(i).cle_etrangere_reference);
      
      supprimer_table(       
         table_cible  => tab_table_purge(i).table_source
      );      

      renommer_table(
         table_source => tab_table_purge(i).table_temporaire,
         table_cible  => tab_table_purge(i).table_source
      );

      recreer_objet_dependant(
         ddl_obj_dependant => tab_table_purge(i).ddl_obj_dependant
      );

      recreer_cle_etrang_ref_table(
         tab_cle_etrangere_ref => tab_table_purge(i).ddl_obj_dependant.tab_cle_etrangere_ref);

   END LOOP; 

END;

PROCEDURE afficher_volumetrie (tab_table_purge IN type_tab_table_purge)
AS

   nom_objet                    CONSTANT all_objects.object_name%TYPE := 'afficher_volumetrie';
   erreur          type_erreur;

   SUBTYPE number_notnull IS NUMBER NOT NULL;

   taille_table_source         NUMBER(10);
   taille_table_temporaire     NUMBER(10);
   taille_table_historisation  NUMBER(10);

   pourcentage_suppression     NUMBER(5,2);
   pourcentage_historisation   NUMBER(5,2);
   pourcentage_conservation    NUMBER(5,2);

   requete CLOB;
   message VARCHAR2(32000);


   FUNCTION ratio_pourcent (numerateur IN number_notnull, denominateur IN number_notnull) RETURN NUMBER
   IS
      ratio NUMBER(5,2);
   BEGIN
      
      IF denominateur = 0 THEN 
         ratio := 0;
      ELSE
         ratio:= ROUND((numerateur/denominateur) * 100, 2);
      END IF;
      
      RETURN ratio;   
         
   END;


   FUNCTION nombre_formate (nombre IN NUMBER) RETURN VARCHAR2 
   IS   
      format       VARCHAR2(30);
      separateur   VARCHAR2(30);
      
   BEGIN
     
      format       := '999G999G999';
      separateur   := 'NLS_NUMERIC_CHARACTERS = '', ''';   
     
      RETURN TO_CHAR(nombre, format, separateur);
     
   END nombre_formate;


   PROCEDURE tracer_message (message trace.info%TYPE)
   AS
   BEGIN
      tracer( 
         nom_objet => nom_objet,
         message   => message );   
   END;

BEGIN


   FOR i IN tab_table_purge.FIRST..tab_table_purge.LAST LOOP

      requete := 'SELECT COUNT(1) FROM ' || tab_table_purge(i).table_source;
      EXECUTE IMMEDIATE requete INTO taille_table_source;

      requete := 'SELECT COUNT(1) FROM ' || tab_table_purge(i).table_historisation;
      EXECUTE IMMEDIATE requete INTO taille_table_historisation;

      requete := 'SELECT COUNT(1) FROM ' || tab_table_purge(i).table_temporaire;
      EXECUTE IMMEDIATE requete INTO taille_table_temporaire;

      pourcentage_historisation := ratio_pourcent( numerateur => taille_table_historisation, denominateur=> taille_table_source);
      pourcentage_conservation  := ratio_pourcent( numerateur => taille_table_temporaire,    denominateur=> taille_table_source);
      pourcentage_suppression   := 100 - pourcentage_historisation - pourcentage_conservation;

      message := tab_table_purge(i).table_source || ' : '  ||  nombre_formate(taille_table_source) || ' enregistrements';
      tracer_message(message);
      
      message := tab_table_purge(i).table_historisation || ' : '  ||  nombre_formate(taille_table_historisation) || ' enregistrements';
      tracer_message(message);

      message := tab_table_purge(i).table_temporaire || ' : '  ||  nombre_formate(taille_table_temporaire) || ' enregistrements';
      tracer_message(message);

      message := 'Enregistrements supprimes:  ' || pourcentage_suppression ||' % ' ;
      tracer_message(message);

      message := 'Enregistrements historises:  ' || pourcentage_historisation ||' % ' ;
      tracer_message(message);

      message := 'Enregistrements conserves:  ' || pourcentage_conservation ||' % ' ;
      tracer_message(message);

   END LOOP; 

EXCEPTION

      WHEN OTHERS THEN

      erreur := extraire_erreur (
                  nom_objet      => nom_objet,
                  message_erreur => SQLERRM, 
                  backtrace      => DBMS_UTILITY.format_error_backtrace);

      tracer_erreur_appele (erreur);      

      RAISE;
  
END afficher_volumetrie;

PROCEDURE collecter_statistique (tab_table_purge IN type_tab_table_purge)
AS

  nom_objet       CONSTANT all_objects.object_name%TYPE := 'table_existe';
  erreur          type_erreur;
   
   pourcentage_collecte  CONSTANT BINARY_INTEGER := 5;
   requete               VARCHAR2(32000);

BEGIN

   FOR i IN tab_table_purge.FIRST..tab_table_purge.LAST LOOP

      requete := 'BEGIN 
                     dbms_stats.gather_table_stats( 
                        ownname => USER,
                        tabname => :1,
                        estimate_percent  => :2); 
                  END;';

     EXECUTE IMMEDIATE requete USING tab_table_purge(i).table_source, pourcentage_collecte;

   END LOOP; 

EXCEPTION

      WHEN OTHERS THEN

      erreur := extraire_erreur (
                  nom_objet      => nom_objet,
                  message_erreur => SQLERRM, 
                  backtrace      => DBMS_UTILITY.format_error_backtrace);

      tracer_erreur_appele (erreur);      

      RAISE;
  
END collecter_statistique;

PROCEDURE preparer_purge(tab_entree_purge IN type_tab_entree_purge)
AS
   nom_objet       CONSTANT all_objects.object_name%TYPE := 'preparer_purge';

   tab_table_purge      type_tab_table_purge;

   -- Trace
   type_traitement   CONSTANT str_sui_trt.cod_trt_str%TYPE := 'PRG_FL_IN-PR_VR';
   libelle_succes    CONSTANT str_sui_trt.lib_err_str%TYPE := '';
   tag_etape         det_sui_trt. tag%TYPE;
   message_debut     CONSTANT det_sui_trt.info%TYPE := 'Debut';
   message_fin       CONSTANT det_sui_trt.info%TYPE := 'Fin';

   numero_suivi      str_sui_trt.id_str%TYPE;

BEGIN

   -- Tracer le début du traitement
   numero_suivi := pkg_commun.deb_suivi_trt(
                        p_cod_trt_str => type_traitement);

   -- Verifier que les tables sont alimentees et charger le DDL
   tag_etape       := 'Initialisation'; 

   pkg_commun.det_suivi_trt(
                  p_id_str   =>    numero_suivi,
                  p_info     =>    message_debut,
                  p_tag      =>    tag_etape);

   initialiser_purge( 
      tab_entree_purge => tab_entree_purge,
      tab_table_purge  => tab_table_purge
   );

   pkg_commun.det_suivi_trt(
                  p_id_str   =>    numero_suivi,
                  p_info     =>    message_fin,
                  p_tag      =>    tag_etape);

   -- Afficher la volumetrie (supprimée, historisée, gardée)
   tag_etape       := 'Volumetrie'; 

   pkg_commun.det_suivi_trt(
                  p_id_str   =>    numero_suivi,
                  p_info     =>    message_debut,
                  p_tag      =>    tag_etape);


   afficher_volumetrie(tab_table_purge => tab_table_purge);

   pkg_commun.det_suivi_trt(
                  p_id_str   =>    numero_suivi,
                  p_info     =>    message_fin,
                  p_tag      =>    tag_etape);


   -- Tracer la fin du traitement   
   pkg_commun.fin_suivi_trt( p_id_str       =>  numero_suivi,
                             p_lib_err_str  => libelle_succes);


END preparer_purge;


PROCEDURE executer_purge(tab_entree_purge IN type_tab_entree_purge)
AS
   nom_objet       CONSTANT all_objects.object_name%TYPE := 'executer_purge';

   tab_table_purge      type_tab_table_purge;

   -- Trace
   type_traitement   CONSTANT str_sui_trt.cod_trt_str%TYPE := 'PRG_FIL_IN-EXEC';
   libelle_erreur    str_sui_trt.lib_err_str%TYPE;
   tag_etape         det_sui_trt. tag%TYPE;
   message_etape     det_sui_trt.info%TYPE;
   numero_suivi      str_sui_trt.id_str%TYPE;

BEGIN

   -- Tracer le début du traitement
   numero_suivi := pkg_commun.deb_suivi_trt(
                        p_cod_trt_str => type_traitement);

   -- Verifier que les tables sont alimentees et charger le DDL
   tag_etape       := 'Initialisation'; 
   message_etape   := 'Debut';

   pkg_commun.det_suivi_trt(
                  p_id_str   =>    numero_suivi,
                  p_info     =>    message_etape,
                  p_tag      =>    tag_etape);

   initialiser_purge( 
      tab_entree_purge => tab_entree_purge,
      tab_table_purge  => tab_table_purge
   );

   message_etape   := 'Fin';

   pkg_commun.det_suivi_trt(
                  p_id_str   =>    numero_suivi,
                  p_info     =>    message_etape,
                  p_tag      =>    tag_etape);

   -- Remplacer les tables sources par les données des tables temporaires
   tag_etape       := 'Remplacement'; 
   message_etape   := 'Debut';

   pkg_commun.det_suivi_trt(
                  p_id_str   =>    numero_suivi,
                  p_info     =>    message_etape,
                  p_tag      =>    tag_etape);


   remplacer_table_source(tab_table_purge => tab_table_purge);

   message_etape   := 'Fin';

   pkg_commun.det_suivi_trt(
                  p_id_str   =>    numero_suivi,
                  p_info     =>    message_etape,
                  p_tag      =>    tag_etape);

   -- Collecter les statistiques
   tag_etape       := 'Statistiques'; 
   message_etape   := 'Debut';

   pkg_commun.det_suivi_trt(
                  p_id_str   =>    numero_suivi,
                  p_info     =>    message_etape,
                  p_tag      =>    tag_etape);

   collecter_statistique(tab_table_purge => tab_table_purge);

   message_etape   := 'Fin';

   pkg_commun.det_suivi_trt(
                  p_id_str   =>    numero_suivi,
                  p_info     =>    message_etape,
                  p_tag      =>    tag_etape);

   -- Tracer la fin du traitement
   libelle_erreur := '';
   pkg_commun.fin_suivi_trt( p_id_str       =>  numero_suivi,
                             p_lib_err_str  => libelle_erreur);

EXCEPTION

   WHEN OTHERS THEN

      tracer_erreur_appelant(
            nom_objet => nom_objet,
            backtrace => dbms_utility.format_error_backtrace());    

      RAISE;

END executer_purge;


PROCEDURE preparer_purge_fil_inact
IS
   nom_objet       CONSTANT all_objects.object_name%TYPE := 'preparer_purge_fil_inact';

   tab_entree_purge type_tab_entree_purge;

BEGIN

   tab_entree_purge(1).table_source        := 'alt_alert_logi_fap';
   tab_entree_purge(1).table_historisation := 'alt_alert_logi_fap_histo';
   tab_entree_purge(1).table_temporaire    := 'alt_alert_logi_fap_garde';

   tab_entree_purge(2).table_source        := 'ecm_element_cout_modele';
   tab_entree_purge(2).table_historisation := 'ecm_element_cout_modele_histo';
   tab_entree_purge(2).table_temporaire    := 'ecm_element_cout_modele_garde';

   tab_entree_purge(3).table_source        := 'evt_fap_detail';
   tab_entree_purge(3).table_historisation := 'evt_fap_detail_histo';
   tab_entree_purge(3).table_temporaire    := 'evt_fap_detail_garde';

   tab_entree_purge(4).table_source        := 'filiere';
   tab_entree_purge(4).table_historisation := 'filiere_histo';
   tab_entree_purge(4).table_temporaire    := 'filiere_garde';

   tab_entree_purge(5).table_source        := 'l_cco_fap_histo';
   tab_entree_purge(5).table_historisation := 'l_cco_fap_histo';
   tab_entree_purge(5).table_temporaire    := 'l_cco_fap_histo';

   tab_entree_purge(6).table_source        := 'troncon';
   tab_entree_purge(6).table_historisation := 'troncon_histo';
   tab_entree_purge(6).table_temporaire    := 'troncon_histo';

   tab_entree_purge(7).table_source        := 'ul_filiere';
   tab_entree_purge(7).table_historisation := 'ul_filiere_histo';
   tab_entree_purge(7).table_temporaire    := 'ul_filiere_garde';

   preparer_purge(tab_entree_purge => tab_entree_purge);

EXCEPTION

   WHEN OTHERS THEN

      tracer_erreur_appelant(
            nom_objet => nom_objet,
            backtrace => dbms_utility.format_error_backtrace());    

      RAISE;

END preparer_purge_fil_inact;


END pkg_purge_commun ;
/
