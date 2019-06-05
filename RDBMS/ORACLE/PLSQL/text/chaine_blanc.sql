CREATE OR REPLACE FUNCTION chaine_blanc(nombre IN INTEGER) 
RETURN VARCHAR2 
AS
  chaine VARCHAR2(100);
BEGIN

   FOR i IN 1.. nombre LOOP
      chaine := chaine || '-';
   END LOOP;    
         
  RETURN(chaine);

END chaine_blanc;
/