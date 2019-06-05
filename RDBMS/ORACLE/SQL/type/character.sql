-----------------------------------------------------------
--------------  Character  ---------------------------------
-----------------------------------------------------------


-- ' 39
-- " 34


-- Code ASCII 
-- Given a caracter
SELECT
  ASCII('&')
FROM 
   DUAL
;

-- Blank character
SELECT
  ASCII('')
FROM 
   DUAL
;

-- Quote
SELECT
  ASCII('''')
FROM 
   DUAL
;

-- Unix :   LF(10) 
-- Windows: CR(13)  LF(10)

-- Have a try
SELECT ASCII('
') FROM DUAL;
-- On client - IDE         - Windows: 10(LF) => Why ? : because code is executed on server-side (Unix)
-- On server - trough SSH  - Unix:    10(LF)


-- CR
SELECT
  CHR(13)
FROM 
   DUAL
;

-- LF 
SELECT
  CHR(10)
FROM 
   DUAL
;





-- Character
-- Given an ASCII code
SELECT
  CHR(39)
FROM 
   DUAL
;

-- Character => ASCII code => Character
SELECT
  CHR(ASCII('_'))
FROM 
   DUAL
;


SELECT
  CHR(ASCII('a'))
FROM 
   DUAL
;


-- Replace rewline with underscore
WITH string AS 
(SELECT 'abcd ' AS value FROM dual)
SELECT 
   string.value,
   REPLACE( string.value, 
            CHR(' '),
            '_' 
)
FROM 
   string
;

-- Check last char 
SELECT 
--   t.*,
   t.transporteur,
   SUBSTR(t.transporteur, -1, 1)        last_char,
   ASCII(SUBSTR(t.transporteur, -1, 1)) last_char_ascii_code
FROM 
   extfil t
WHERE 1=1
   AND t.cod_utl_enc = '20'
;


-- Check if last char if Windows CR (=issue)
SELECT 
--   t.*,
   t.transporteur,
   SUBSTR(t.transporteur, -1, 1)        last_char,
   ASCII(SUBSTR(t.transporteur, -1, 1)) last_char_ascii_code,
   REPLACE( t.transporteur, 
            CHR(13),
            '_' ) cr_sub_with_underscore
FROM 
   extfil t
WHERE 1=1
   AND t.cod_utl_enc = '20'
;

SELECT
  CHR(13)
FROM 
   DUAL
;

-----------------------------------------------------------
--------------  Variable character  strings  (VARCHAR)  ---
-----------------------------------------------------------



-- SUBSTR
-- - char
-- - position 
-- - substring_length



SELECT 
   SUBSTR('123', 1, 1)
FROM 
   dual
;

-- You can still use position 0 anyway..
SELECT 
   SUBSTR('123', 0, 1)
FROM 
   dual
;

-- use monospace font for ruler: 
-- - windows => Courrier new

/*
start   20
lenght  31
end     51
*/

WITH 
rqt AS
(
   SELECT 'CREATE UNIQUE INDEX ndx_alter_logi_hst_svg_id_alt ON alt_alert_logi_fap_histo_svg (id_alt)' txt FROM DUAL
   UNION
   SELECT '|123456789|123456789|123456789|123456789|123456789|123456789|123456789|123456789|123456789|123456789' txt FROM DUAL
),
pattern AS
(
SELECT 
   rqt.txt,
   INSTR(rqt.txt, 'INDEX') + LENGTH('INDEX')     pattern_start, 
   INSTR(rqt.txt, 'ON')                          pattern_stop
FROM 
   rqt
)
SELECT 
   pattern.txt,
   pattern.pattern_start, 
   pattern.pattern_stop,
  (pattern.pattern_stop - pattern_start  ) susbtring_length,
   SUBSTR( 
      pattern.txt,
      pattern.pattern_start, 
      (pattern.pattern_stop - pattern_start - 1 )
    ) substring,
   TRIM(SUBSTR( 
      pattern.txt,
      pattern.pattern_start, 
      (pattern.pattern_stop - pattern_start - 1 )
   ) ) trimmed_substring
   
FROM
   pattern
;