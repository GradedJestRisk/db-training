CREATE OR REPLACE PACKAGE BODY pfl_k_erreur
IS

   -- Strings that delimit different parts of line in stack.
   c_name_delim   CONSTANT CHAR (1) := '"';
   c_dot_delim    CONSTANT CHAR (1) := '.';
   c_line_delim   CONSTANT CHAR (5) := 'ligne';
   c_eol_delim    CONSTANT CHAR (1) := CHR (10);
   

     
   --
   FUNCTION ligne_levant_exception (error_backtrace IN VARCHAR2)
      RETURN all_source.line%TYPE
   IS
      -- Lots of INSTRs to come; these variables keep track
      -- of the start and end points of various portions of the string.
      l_at_loc           PLS_INTEGER;
      l_dot_loc          PLS_INTEGER;
      l_name_start_loc   PLS_INTEGER;
      l_name_end_loc     PLS_INTEGER;
      l_line_loc         PLS_INTEGER;
      l_eol_loc          PLS_INTEGER;
      --
      retval             error_rt;
      
      derniere_ligne_backtrace VARCHAR2(3200);

      
   BEGIN
   
     derniere_ligne_backtrace := derniere_ligne(error_backtrace);
   
   
         l_name_start_loc := INSTR (error_backtrace, c_name_delim, 1, 1);
         l_dot_loc        := INSTR (error_backtrace, c_dot_delim);
         l_name_end_loc   := INSTR (error_backtrace, c_name_delim, 1, 2);
         l_line_loc       := INSTR (error_backtrace, c_line_delim);
         l_eol_loc        := INSTR (error_backtrace, c_eol_delim);

         IF l_eol_loc = 0
         THEN
            l_eol_loc := LENGTH (error_backtrace) + 1;
         END IF;
      
       --
      retval.program_owner :=
         SUBSTR (error_backtrace
               , l_name_start_loc + 1
               , l_dot_loc - l_name_start_loc - 1
                );
      --
      retval.program_name :=
          SUBSTR (error_backtrace, l_dot_loc + 1, l_name_end_loc - l_dot_loc - 1); 
      --
      retval.line_number :=
             SUBSTR (error_backtrace, l_line_loc + 5, l_eol_loc - l_line_loc - 5);
             
      RETURN retval.line_number;
      
   END ligne_levant_exception;
   
END pfl_k_erreur;
/