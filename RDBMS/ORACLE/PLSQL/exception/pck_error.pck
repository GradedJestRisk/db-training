CREATE OR REPLACE PACKAGE pck_error
IS

  TYPE type_erreur IS RECORD (
    program_owner    all_objects.owner%TYPE,
    program_name     all_objects.object_name%TYPE,
    line_number      PLS_INTEGER,
    error_code       PLS_INTEGER,
    error_message    VARCHAR2(256)
  );

  FUNCTION extraire_erreur (
               error_code    IN   PLS_INTEGER,
               error_message IN   VARCHAR2,
               backtrace     IN   VARCHAR2) 
   RETURN type_erreur;

   FUNCTION backtrace_sans_origine (backtrace IN VARCHAR2) RETURN VARCHAR2;



   PROCEDURE p1_calling_p2;

END pck_error;
/
CREATE OR REPLACE PACKAGE BODY pck_error AS

   unhandled_exception EXCEPTION;

   c_name_delim  CONSTANT CHAR (1)  := '"';
   c_dot_delim   CONSTANT CHAR (1)  := '.';
   c_line_delim  CONSTANT CHAR (4)  := 'line';
   c_eol_delim   CONSTANT CHAR (1)  := CHR (10);



FUNCTION extraire_erreur (
               error_code    IN   PLS_INTEGER,
               error_message IN   VARCHAR2,
               backtrace     IN   VARCHAR2) 
   RETURN type_erreur
IS

   error  type_erreur;

   l_name_start_loc VARCHAR2(100);
   l_dot_loc        VARCHAR2(100);
   l_name_end_loc   VARCHAR2(100);
   l_line_loc       VARCHAR2(100);
   l_eol_loc        VARCHAR2(100);

BEGIN

   error.error_code     := error_code;
   error.error_message := error_message;


   l_name_start_loc := INSTR (backtrace, c_name_delim, 1, 1);
   l_dot_loc        := INSTR (backtrace, c_dot_delim);
   l_name_end_loc   := INSTR (backtrace, c_name_delim, 1, 2);
   l_line_loc       := INSTR (backtrace, c_line_delim);
   l_eol_loc        := INSTR (backtrace, c_eol_delim);
      
   error.program_owner :=  SUBSTR(
                              backtrace,
                              l_name_start_loc  + 1,
                              l_dot_loc - l_name_start_loc - 1);

   error.program_name := SUBSTR(
                           backtrace, 
                           l_dot_loc + 1, 
                           l_name_end_loc - l_dot_loc - 1);
   
   error.line_number  := SUBSTR(
                           backtrace, 
                           l_line_loc + 5, 
                           l_eol_loc - l_line_loc - 5);

   RETURN error;

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


PROCEDURE tracer_erreur_appele (erreur IN type_erreur ) IS
BEGIN
   dbms_output.put_line('Erreur - Contenu : ' || erreur.error_message || '(' || erreur.ERROR_CODE || ')' ||  ' raised by ' || erreur.program_name ||' at line :  ' || erreur.line_number);
END tracer_erreur_appele;

PROCEDURE tracer_erreur_appelant (backtrace IN VARCHAR2) IS
BEGIN
   dbms_output.put_line('Erreur - Chaine d appel (appele => appelant): ' || backtrace_sans_origine(backtrace));
END tracer_erreur_appelant;


--PROCEDURE p1_calling_p2;
PROCEDURE p2_calling_p3;
PROCEDURE p3_calling_p4;
PROCEDURE p4_throwing_error;

PROCEDURE p1_calling_p2
IS
   erreur   type_erreur;
BEGIN

   --RAISE NO_DATA_FOUND;
   NULL;
   p2_calling_p3;
   NULL;


EXCEPTION

   WHEN unhandled_exception THEN

         tracer_erreur_appelant(dbms_utility.format_error_backtrace());    

         -- Throws exception to caller if useful
         RAISE;

   WHEN OTHERS THEN

   /*
      dbms_output.put_line('SQLERRM         in p1_calling_p2 : ' || SQLERRM); 
      dbms_output.put_line('Error stack     in p1_calling_p2 : ' || dbms_utility.format_error_stack());
      dbms_output.put_line('Error backtrace in p1_calling_p2 : ' || dbms_utility.format_error_backtrace());
   */

      -- Give call stack and message
      --dbms_output.put_line('Message and call stack : ' || dbms_utility.format_error_backtrace());    

         erreur := extraire_erreur (
                     error_code    => SQLCODE, 
                     error_message => SQLERRM, 
                     backtrace     => DBMS_UTILITY.format_error_backtrace);
   
         tracer_erreur_appele (erreur);  

         -- Throws exception to caller if useful
         RAISE;


END p1_calling_p2;

PROCEDURE p2_calling_p3
IS
BEGIN

   NULL;
   p3_calling_p4;
   NULL;


END p2_calling_p3;

PROCEDURE p3_calling_p4
IS
BEGIN

   NULL;
   p4_throwing_error;
   NULL;
/*
EXCEPTION
   WHEN OTHERS THEN
      RAISE;
*/

END p3_calling_p4;


PROCEDURE p4_throwing_error
IS

   erreur   type_erreur;

BEGIN

   NULL;
   dbms_output.put_line('Throwing NO_DAT_FOUND at line 158');
   RAISE NO_DATA_FOUND;
   NULL;
 
EXCEPTION

   WHEN OTHERS THEN


      /*
      -- Give error content (error code / message)
      dbms_output.put_line('SQLERRM         in p4_throwing_error : ' || SQLERRM); 

      --   dbms_output.put_line('Backtrace: ' || dbms_utility.format_error_stack());

      -- Give line when error was throwned
      dbms_output.put_line('Error backtrace in p4_throwing_error : ' || dbms_utility.format_error_backtrace());

      dbms_output.put_line('$$PLSQL_LINE  in p4_throwing_error:  ' || $$PLSQL_LINE);
      */

      erreur := extraire_erreur (
                  error_code    => SQLCODE, 
                  error_message => SQLERRM, 
                  backtrace     => DBMS_UTILITY.format_error_backtrace);

      tracer_erreur_appele (erreur);      

      -- Give line when error was throwned
      --dbms_output.put_line('Error raised at line : ' || dbms_utility.format_error_backtrace());      

      RAISE unhandled_exception;

END p4_throwing_error;

END pck_error;
/
