-----------------------------------------------------------
--------------  Character  ---------------------------------
-----------------------------------------------------------

-- ' 39
-- " 34
SELECT
  ASCII('a')
FROM 
   DUAL
;

-- Sp�ciaux
SELECT
  ASCII('''')
FROM 
   DUAL
;


SELECT
  CHR(34)
FROM 
   DUAL
;

SELECT
  CHR(ASCII('a'))
FROM 
   DUAL
;


-----------------------------------------------------------
--------------  Variable character  strings  (VARCHAR)  ---
-----------------------------------------------------------



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



-- SUBSTR
-- - char
-- - position 
-- - substring_length

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