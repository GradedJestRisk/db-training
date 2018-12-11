CREATE OR REPLACE PACKAGE pck_extract_ddl
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
   --------------      Types                     -------------
   ------------------------------------------------------------------------
   
   TYPE typ_tab_table IS 
   TABLE OF 
      all_tables.table_name%TYPE
   INDEX BY 
      BINARY_INTEGER;

   ---------------------------------------------------------------------------
   --------------      Gestion des traces                -------------
   ---------------------------------------------------------------------------

   PROCEDURE tracer(
      nom_objet   IN trace.tag%TYPE,
      message     IN trace.info%TYPE,
      nom_package IN all_objects.object_name%TYPE  DEFAULT 'PKG_EXTRACT_DDL' );

   PROCEDURE tracer_erreur_appelant (
               nom_objet   IN trace.tag%TYPE,
               backtrace   IN VARCHAR2,
               nom_package IN all_objects.object_name%TYPE DEFAULT 'PKG_EXTRACT_DDL');

   PROCEDURE tracer_erreur_appele ( 
               erreur IN type_erreur,
               nom_package IN all_objects.object_name%TYPE DEFAULT 'PKG_EXTRACT_DDL' );

   ---------------------------------------------------------------------------
   --------------     Principal                -------------
   ---------------------------------------------------------------------------

   PROCEDURE executer;

END  pck_extract_ddl;
/
CREATE OR REPLACE PACKAGE BODY  pck_extract_ddl
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

TYPE type_table_ddl IS RECORD (
   nom_table                    all_tables.table_name%TYPE,
   ddl_obj_dependant            type_ddl_obj_dependant,
   cle_etrangere_reference      type_tab_contrainte
);

TYPE type_tab_table_ddl IS 
   TABLE OF 
      type_table_ddl 
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
               nom_package IN all_objects.object_name%TYPE DEFAULT 'PKG_EXTRACT_DDL' )   
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
               nom_package IN all_objects.object_name%TYPE DEFAULT 'PKG_EXTRACT_DDL') 
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
--------------      Principal                    -------------
------------------------------------------------------------------------

PROCEDURE tracer(
   nom_objet   IN trace.tag%TYPE,
   message     IN trace.info%TYPE,
   nom_package IN all_objects.object_name%TYPE DEFAULT 'PKG_EXTRACT_DDL')
AS

   message_formate_fichier trace.info%TYPE;
   message_formate_table   trace.info%TYPE;

BEGIN

   -- Ecriture dans le fichier de log (écriture différée, à la fin du traitement)

--   message_formate_fichier := nom_objet || ' : '  || message;
   message_formate_fichier := message;

   dbms_output.put_line( message_formate_fichier);

   -- Ecriture dans la table de trace (écriture immédiate, visible de suite)

   message_formate_table := nom_objet || ' : ' || message;

   toolbox.trace(
      p_tag  => nom_package,
      p_info => message_formate_table); 

END;

PROCEDURE alimenter_ddl_contrainte (
               table_cible          IN all_tables.table_name%TYPE, 
               tab_ddl_contrainte   OUT type_tab_clob)
AS

  nom_objet       CONSTANT all_objects.object_name%TYPE := 'alimenter_ddl_contrainte';
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

  nom_objet       CONSTANT all_objects.object_name%TYPE := 'alimenter_ddl_cle_etrangere';
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

  nom_objet       CONSTANT all_objects.object_name%TYPE := 'alimenter_ddl_index';
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
   
  nom_objet       CONSTANT all_objects.object_name%TYPE := 'alimenter_ddl_privilege';
  erreur          type_erreur;

BEGIN
   
   tab_ddl_privilege(1) := TO_CLOB('GRANT SELECT, UPDATE, INSERT, DELETE ON ' || table_cible || ' TO XXX');

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

  nom_objet       CONSTANT all_objects.object_name%TYPE := 'alimenter_cle_etrang_ref_table';
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
         AND   cnt_pk.table_name       = table_cible
         AND   cnt_fk.constraint_type  = 'R'
         -- Les FK de la table sur elle-meme ne doivent pas etre exportees
         -- car elles seront deja crees lors de la creation des FK
         AND   cnt_fk.table_name       <> table_cible;

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

END alimenter_ddl_obj_dependant;

PROCEDURE afficher_contenu_purge (tab_table_ddl IN type_tab_table_ddl)
AS
   nom_objet       CONSTANT all_objects.object_name%TYPE := 'afficher_contenu_purge';
   erreur          type_erreur;
  
   PROCEDURE tracer_message (message trace.info%TYPE)
   AS
   BEGIN
      tracer( 
         nom_objet => nom_objet,
         message   => message );   
   END;


   PROCEDURE tracer_titre (titre trace.info%TYPE)
   AS
   
      ligne_separation VARCHAR2(100) := CHR(10) ||  '-----------------------------------------------------------------' || CHR(10) ;   

   BEGIN

      tracer( 
         nom_objet => nom_objet,
         message   => ligne_separation || titre  || ligne_separation );   
   END tracer_titre;

   PROCEDURE tracer_entete (entete trace.info%TYPE)
   AS
   
      espace             VARCHAR2(5)   := ' ';
      chaine_mise_valeur VARCHAR2(100) := '----'  ;   

   BEGIN

      tracer( 
         nom_objet => nom_objet,
         message   =>  CHR(10) || chaine_mise_valeur || espace || entete || espace || chaine_mise_valeur || CHR(10)  );   
   END tracer_entete;


BEGIN

   FOR i IN tab_table_ddl.FIRST..tab_table_ddl.LAST LOOP

        tracer_titre('----------- ' || ' Table: ' || tab_table_ddl(i).nom_table ||  ' ----------------');

        IF tab_table_ddl(i).ddl_obj_dependant.tab_contrainte.COUNT > 0 THEN 

           tracer_entete('constraintes');

           FOR j IN tab_table_ddl(i).ddl_obj_dependant.tab_contrainte.FIRST..tab_table_ddl(i).ddl_obj_dependant.tab_contrainte.LAST LOOP
              tracer_message(tab_table_ddl(i).ddl_obj_dependant.tab_contrainte(j));
           END LOOP;

        END IF;

        IF tab_table_ddl(i).ddl_obj_dependant.tab_cle_etrangere.COUNT > 0 THEN 

           tracer_entete('clef etrangere');

           FOR j IN tab_table_ddl(i).ddl_obj_dependant.tab_cle_etrangere.FIRST..tab_table_ddl(i).ddl_obj_dependant.tab_cle_etrangere.LAST LOOP
              tracer_message(tab_table_ddl(i).ddl_obj_dependant.tab_cle_etrangere(j));
           END LOOP;

        END IF;

        IF tab_table_ddl(i).ddl_obj_dependant.tab_privilege.COUNT > 0 THEN 

           tracer_entete('privilege');

           FOR j IN tab_table_ddl(i).ddl_obj_dependant.tab_privilege.FIRST..tab_table_ddl(i).ddl_obj_dependant.tab_privilege.LAST LOOP
              tracer_message(tab_table_ddl(i).ddl_obj_dependant.tab_privilege(j));
           END LOOP;

        END IF;

        IF tab_table_ddl(i).ddl_obj_dependant.tab_index.COUNT > 0 THEN 
           
           tracer_entete('index'); 

           FOR j IN tab_table_ddl(i).ddl_obj_dependant.tab_index.FIRST..tab_table_ddl(i).ddl_obj_dependant.tab_index.LAST LOOP
              tracer_message(tab_table_ddl(i).ddl_obj_dependant.tab_index(j));
           END LOOP;

        END IF;

       IF tab_table_ddl(i).cle_etrangere_reference.COUNT > 0 THEN 

           tracer_entete('cle etrangere referencante - suppression');

           FOR j IN tab_table_ddl(i).cle_etrangere_reference.FIRST..tab_table_ddl(i).cle_etrangere_reference.LAST LOOP
              tracer_message('Table : '         || tab_table_ddl(i).cle_etrangere_reference(j).nom_table   ||
                                    ' - Contrainte : ' || tab_table_ddl(i).cle_etrangere_reference(j).nom_contrainte);
   
           END LOOP;

        END IF;

        IF tab_table_ddl(i).ddl_obj_dependant.tab_cle_etrangere_ref.COUNT > 0 THEN 

           tracer_entete('cle etrangere referencante - recreation'); 

           FOR j IN tab_table_ddl(i).ddl_obj_dependant.tab_cle_etrangere_ref.FIRST..tab_table_ddl(i).ddl_obj_dependant.tab_cle_etrangere_ref.LAST LOOP
             tracer_message(tab_table_ddl(i).ddl_obj_dependant.tab_cle_etrangere_ref(j));
           END LOOP;

        END IF;


   END LOOP; 

EXCEPTION

      WHEN OTHERS THEN

      erreur := extraire_erreur (
                  nom_objet      => nom_objet,
                  message_erreur => SQLERRM, 
                  backtrace      => DBMS_UTILITY.format_error_backtrace);

      tracer_erreur_appele (erreur);      

      RAISE;

END afficher_contenu_purge;

PROCEDURE extraire_ddl (
   tab_table IN  typ_tab_table)
AS

   tab_table_ddl  type_tab_table_ddl;
   nom_objet                    CONSTANT all_objects.object_name%TYPE := 'extraire_ddl';

BEGIN
   
   DBMS_METADATA.SET_TRANSFORM_PARAM( DBMS_METADATA.SESSION_TRANSFORM, 'STORAGE',          FALSE);

   FOR i IN tab_table.FIRST..tab_table.LAST LOOP

      tab_table_ddl(i).nom_table        := UPPER(tab_table(i));
        
      alimenter_ddl_obj_dependant(
            table_cible       => tab_table_ddl(i).nom_table, 
            ddl_obj_dependant => tab_table_ddl(i).ddl_obj_dependant);

      alimenter_cle_etrang_ref_table (
               table_cible                   => tab_table_ddl(i).nom_table,
               tab_contrainte                => tab_table_ddl(i).cle_etrangere_reference,
               tab_cle_etrangere_ref_table   => tab_table_ddl(i).ddl_obj_dependant.tab_cle_etrangere_ref );  
   END LOOP; 

   afficher_contenu_purge(tab_table_ddl => tab_table_ddl);

END extraire_ddl;

PROCEDURE ajouter_table_extraire (tab_table OUT typ_tab_table)
IS
   nom_objet       CONSTANT all_objects.object_name%TYPE := 'ajouter_table_extraire';

BEGIN

   tab_table(1)    := 'TABLE_1;
   tab_table(2)    := 'TABLE_2';


END ajouter_table_extraire;

PROCEDURE executer
IS
   nom_objet       CONSTANT all_objects.object_name%TYPE := 'executer';

   tab_table       typ_tab_table;

BEGIN

   ajouter_table_extraire(tab_table => tab_table);

   extraire_ddl(tab_table => tab_table);

EXCEPTION

   WHEN OTHERS THEN

      tracer_erreur_appelant(
            nom_objet => nom_objet,
            backtrace => dbms_utility.format_error_backtrace());    

      RAISE;

END executer;




END  pck_extract_ddl;
/
