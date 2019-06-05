CREATE OR REPLACE PACKAGE pkg_subprocedure
IS

   PROCEDURE inserer_parametrage_purge;

END pkg_subprocedure;
/
CREATE OR REPLACE PACKAGE BODY pkg_subprocedure AS


PROCEDURE inserer_parametrage_purge
AS
  parametrage    param%ROWTYPE;

  PROCEDURE inserer_parametrage (parametrage IN OUT   param%ROWTYPE)
   AS
      parametrage_existe     BINARY_INTEGER;
   BEGIN

      SELECT 
        COUNT(1)
     INTO 
        parametrage_existe
     FROM 
       param prm
     WHERE  
        prm.lib_param = parametrage.lib_param;   
                                           
     IF parametrage_existe = 0 THEN
     
       SELECT 
          MAX(prm.id_param) + 1
       INTO 
          parametrage.id_param
       FROM 
         param prm;   
   
       INSERT INTO 
         param
       VALUES
        parametrage;
   
     END IF;

   END inserer_parametrage;


BEGIN

   parametrage.lib_param := 'PURGE-FIL-INACT_HIST-PRM-DBT';
   parametrage.num_param := '2';
   parametrage.com_param := 'Purge des filieres inactives: debut historisation permanent (mois)';

   inserer_parametrage(parametrage => parametrage);

   parametrage.lib_param := 'PURGE-FIL-INACT_HIST-PRM-FIN';
   parametrage.num_param := '1';
   parametrage.com_param := 'Purge des filieres inactives: debut historisation permanent (mois)';

   inserer_parametrage(parametrage => parametrage);

   parametrage.lib_param := 'PURGE-FIL-INACT_HIST-HPRM-DBT';
   parametrage.num_param := '6';
   parametrage.com_param := 'Purge des filieres inactives: debut historisation permanent (mois)';

   inserer_parametrage(parametrage => parametrage);

   parametrage.lib_param := 'PURGE-FIL-INACT_HIST-HPRM-FIN';
   parametrage.num_param := '4';
   parametrage.com_param := 'Purge des filieres inactives: debut historisation permanent (mois)';

   inserer_parametrage(parametrage => parametrage);
 
END inserer_parametrage_purge;


END pkg_subprocedure;
/
