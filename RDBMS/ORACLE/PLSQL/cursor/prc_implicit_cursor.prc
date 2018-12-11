CREATE OR REPLACE PROCEDURE dbofap.prc_implicit_cursor IS

   FUNCTION requete_modification_cache_20 ( nom_sequence IN user_sequences.sequence_name%TYPE ) 
   RETURN VARCHAR2
   IS
   BEGIN
     
     RETURN('ALTER SEQUENCE ' || nom_sequence || ' CACHE 20');
     
   END;
   
BEGIN

   FOR sequence_cache_0  IN (SELECT sqc.sequence_name nom_sequence FROM  user_sequences sqc WHERE sqc.cache_size = 0) LOOP
   
      --EXECUTE IMMEDIATE(requete_modification_cache_20(sequence_cache_0.nom_sequence));
     
      dbms_output.put_line(requete_modification_cache_20(sequence_cache_0.nom_sequence));
              
   END LOOP sequence_cache_0;

END prc_implicit_cursor;
/
