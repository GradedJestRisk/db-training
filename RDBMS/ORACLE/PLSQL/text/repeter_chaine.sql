CREATE OR REPLACE FUNCTION repeter_chaine(chaine_base IN VARCHAR, nombre IN INTEGER) 
RETURN VARCHAR2 
AS
  chaine VARCHAR2(100);
BEGIN

   FOR i IN 1.. nombre LOOP
      chaine := chaine || chaine_base;
   END LOOP;    
         
  RETURN(chaine);

END repeter_chaine;
/