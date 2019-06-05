create or replace package pkg_inner is
  procedure p;
  function p_outer( p_data IN NUMBER) RETURN NUMBER;
end pkg_inner;
/

create or replace package body pkg_inner
 as
 
  function p_outer( p_data IN NUMBER) RETURN NUMBER
  is
   begin      
      RETURN (p_data/10);
      
  end p_outer;
 
 procedure p
   is
       l_data       number;
       l_other_data number;
       
       function p_inner( p_data IN NUMBER) RETURN NUMBER
       is
       begin
          l_data := 3;
          RETURN (p_data/10);
       end;
       
 begin
   
       l_data := 42;
       l_other_data := 84;
       
       l_other_data := p_inner( l_other_data );
 
       dbms_output.put_line( 'l_other_data = ' || l_other_data );
       dbms_output.put_line( 'SIDE effect ! l_data = ' || l_data  );
       
       
       -- Not working.. fucntion may not be used in SQL
       --SELECT p_inner(l_other_data) INTO  l_other_data FROM DUAL;
       --dbms_output.put_line( 'l_data = ' || l_data || ', l_other_data = ' || l_other_data );
   
        -- Not working.. fucntion may not be used in SQL
       SELECT p_outer(l_other_data) INTO  l_other_data FROM DUAL;
       dbms_output.put_line( 'l_data = ' || l_data || ', l_other_data = ' || l_other_data );
 
 end p;
 
end pkg_inner;
/