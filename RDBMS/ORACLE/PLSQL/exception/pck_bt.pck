CREATE OR REPLACE PACKAGE bt
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

END bt;
/
CREATE OR REPLACE PACKAGE BODY bt
IS

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

   error.error_code    := error_code;
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

END bt;
/
