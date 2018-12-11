-- Without variable
BEGIN   
  prc_supp_fil_frn_cug('93966000S304',
                       '20180814',
                       '000083194');
END;
/

/*   l_n_is_dossier_trait := pck_bat_fg_uc.fct_rattrap_batch_fguc_contrat(
                                                              a_n_is_produit         =>   l_n_is_produit,
                                                              a_d_effet              =>   l_d_effet,
                                                              a_n_is_protocole       =>   l_n_is_protocole,
                                                              a_n_is_dossier_sousc   =>   l_n_is_dossier_sousc
                                                           );*/

     
     SELECT 
         'l_n_doss := pck_bat_fg_uc.fct_rattrap_batch_fguc_contrat(' || dss.is_produit || ' ,TO_DATE(''' || TO_CHAR(dss.d_effet,'YYYYMMDD''') || ',''YYYYMMDD''),  ' || dss.is_protocole || ', ' || dss.is_dossier_racine || ');'
         --is_dossier, is_produit, is_protocole, is_dossier_racine, d_effet, lp_etat_doss
      FROM 
         db_dossier dss
      WHERE 1=1
         AND no_police       =   'T0040174051'
         AND cd_dossier     IN  ('FGUC','FGUCF')
         AND lp_etat_doss    IN   ('ANNUL')
         AND d_effet        >=   TO_DATE('20151116','YYYYMMDD')
      --ORDER BY d_effet DESC;
      ORDER BY d_effet ASC
;


-- With variable  and output

SET SERVEROUTPUT ON;

DECLARE 
   l_n_doss NUMBER;
BEGIN
   DBMS_OUTPUT.PUT_LINE("Hello!");  
   l_n_doss := pck_bat_fg_uc.fct_rattrap_batch_fguc_contrat(1334 ,TO_DATE('20151130','YYYYMMDD'),  2244, 9959030);
   l_n_doss := pck_bat_fg_uc.fct_rattrap_batch_fguc_contrat(1334 ,TO_DATE('20151231','YYYYMMDD'),  2244, 9959030);

END;
/

DECLARE 
   nom_table VARCHAR2(100);
   action VARCHAR2(100);
   nom_contrainte VARCHAR2(100);
   requete CLOB;
BEGIN

      nom_table := 'TBL_FOO';
      action := 'DISABLE';
      nom_contrainte := 'FK_TBL_FOO';
      
      requete := 'ALTER TABLE ' || nom_table || ' :1 CONSTRAINT :2';

      EXECUTE IMMEDIATE 
         requete 
      USING 
         action,
         nom_contrainte;
 END;
/    


--   
SET SERVEROUTPUT ON;
DECLARE 
   nom_table VARCHAR2(100);
   action VARCHAR2(100);
   nom_contrainte VARCHAR2(100);
   requete CLOB;
BEGIN

      nom_table := 'TBL_FOO';
      action := 'DISABLE';
      nom_contrainte := 'FK_TBL_FOO';
      
      requete := 'ALTER TABLE ' || nom_table || ' ' || action  || ' CONSTRAINT ' || nom_contrainte;
      dbms_output.put_line(requete);

      EXECUTE IMMEDIATE requete; 
 END;
/    




