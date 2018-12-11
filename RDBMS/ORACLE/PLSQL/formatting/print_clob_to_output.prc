CREATE OR REPLACE PROCEDURE print_clob_to_output (p_clob IN CLOB)  
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
/
