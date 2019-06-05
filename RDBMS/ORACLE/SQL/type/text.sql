-----------------------------------------------------------
--------------  Variable character  strings  (VARCHAR)  ---
-----------------------------------------------------------

-- https://fadace.developpez.com/oracle/nls/


--Par concaténation des lignes NLS_LANGUAGE, NLS_TERRITORY et NLS_CHARACTERSETS, nous obtenons donc AMERICAN_AMERICA.WE8ISO8859P15. Soit en clair:
--
--La langue anglaise (AMERICAN)
--Des codes locaux américains (pour le format des dates, des monnaies) (AMERICA)
--Un jeu de caractère ISO (ISO8859) pour l'Europe de l'Ouest (WE) codé sur 8 octets, avec une spécificité (code page 15, pour intégrer le signe de l'Euro).


SELECT * FROM nls_database_parameters WHERE parameter IN ('NLS_NCHAR_CHARACTERSET', 'NLS_CHARACTERSET')
;

select * from rdo_acces_objet_expl where ide_ligne = 35520
;

ALTER SESSION SET NLS_CHARACTERSET = 'WE8ISO8859P1';
  

SELECT parameter, value FROM nls_session_parameters WHERE parameter = 'NLS_CHARACTERSETS'; 



-----------------------------------------------------------
--------------  Access   ---
-----------------------------------------------------------

SELECT 
   SUBSTR('123', 0, 1) O_gives_1 ,
   SUBSTR('123', 1, 1) position_1, 
   SUBSTR('123', 2, 1) position_2,
   SUBSTR('123', 3, 1) position_3,
   SUBSTR('123', 4, 1) position_4
FROM 
   dual
;


-----------------------------------------------------------
--------------  Get size => LENGTH  ---
-----------------------------------------------------------


-- Size
SELECT 
   LENGTH('123')
FROM 
   dual
;

-- Size
SELECT 
   LENGTH(''),
   LENGTH(CHR(10)),
   LENGTH('A' || CHR(10))
FROM 
   dual
;


-----------------------------------------------------------
-------------- String replace => REPLACE  ---
-----------------------------------------------------------

-- String Replace 
SELECT 
   REPLACE('hello', 'e', 'a')
FROM 
   dual
;


-----------------------------------------------------------
--------------  Character map => TRANSLATE  ---
-----------------------------------------------------------

-- Character map 
SELECT 
   TRANSLATE('ààààééééé', 'àé', 'ae')
FROM 
   dual
;

SELECT 
   TRANSLATE('ààààééééé', 'éè', 'ee')
FROM 
   dual
;

-- Character remove 
SELECT 
   TRANSLATE('hello bààààèèèèèè', 'aàè', 'a')
FROM 
   dual
;


-----------------------------------------------------------
--------------  Character range deletion => REGEXP_REPLACE  ---
-----------------------------------------------------------

-- ?? 
WITH data AS (
SELECT 
    'http://domain/dest=@éééààà_____"@bcd' || chr(38)  ||'miller' value 
FROM dual
)
SELECT
    'URL escaping=>'          qry_cnt
    ,data.value              string_raw  
    ,REGEXP_REPLACE(          source_char     =>   data.value        , pattern         =>   '[^[:alnum:]'' '']' , replace_string  =>   NULL)                 string_final
FROM 
   data
;



SELECT 
    REGEXP_REPLACE('##$$$123&&!!__!','[^[:alnum:]'' '']', NULL) FROM dual;
    
    SELECT 
    REGEXP_REPLACE('aàeé@123', '[^[:alnum:]'' '']', NULL) FROM dual;

-----------------------------------------------------------
--------------  URL   ---
-----------------------------------------------------------

/*
Unreserved characters:
- A through Z, 
- a through z, 
- and 0 through 9
- hyphen (-)
- underscore (_)
- period (.)
- exclamation point (!)
- tilde (~)
- asterisk (*)
- accent (')
- left parenthesis ( ( ), 
- right parenthesis ( ) )

Reserved characters (= to be escaped):
- semi-colon (;) 
- slash (/), 
- question mark (?), 
- colon (:), 
- at sign (@), 
- ampersand (&) - 38 
- equals sign (=)
- plus sign (+)
- dollar sign ($)
- percentage sign (%)
- comma (,)

*/

-----------------------------------------------------------
--------------  URL encode => UTL_URL.escape  ---
-----------------------------------------------------------



DECLARE

    unescaped_url VARCHAR2(50);
    escaped_url   VARCHAR2(50);
    
BEGIN

    unescaped_url :=  'a' || '&' || '@b' ;

    escaped_url := UTL_URL.escape( 
        url                     => unescaped_url, 
        escape_reserved_chars   => TRUE );
       
    dbms_output.put_line('unescaped URL : ' || unescaped_url);
    dbms_output.put_line('escaped URL :   ' || escaped_url); 
       
END;
/

SELECT  
    UTL_URL.escape( 
        url                     => 'a&b'
        ,escape_reserved_chars   => 1  
       ) 
FROM dual;



-----------------------------------------------------------
--------------  Search => LIKE   ----------------
-----------------------------------------------------------

-- Search like (case sensitive)
WITH 
rqt AS
(
   SELECT 'CREATE UNIQUE INDEX ndx_alter_logi_hst_svg_id_alt ON alt_alert_logi_fap_histo_svg (id_alt)'           txt FROM DUAL
   UNION
   SELECT '|123456789|123456789|123456789|123456789|123456789|123456789|123456789|123456789|123456789|123456789' txt FROM DUAL
)
SELECT 
   rqt.txt
FROM 
   rqt
WHERE 1=1
  AND rqt.txt LIKE '%UNIQUE%'
;



-- Search like (case in-sensitive)
WITH 
rqt AS
(
   SELECT 'CREATE UNIQUE INDEX ndx_alter_logi_hst_svg_id_alt ON alt_alert_logi_fap_histo_svg (id_alt)'           txt FROM DUAL
   UNION
   SELECT '|123456789|123456789|123456789|123456789|123456789|123456789|123456789|123456789|123456789|123456789' txt FROM DUAL
)
SELECT 
   rqt.txt
FROM 
   rqt
WHERE 1=1
  AND UPPER(rqt.txt) LIKE UPPER('%unique%')
;

-----------------------------------------------------------
--------------  Search => REGEXP_LIKE   ----------------
-----------------------------------------------------------


-- Search regexp-like (case in-sensitive)
WITH 
rqt AS
(
   SELECT 'CREATE UNIQUE INDEX ndx_alter_logi_hst_svg_id_alt ON alt_alert_logi_fap_histo_svg (id_alt)'           txt FROM DUAL
   UNION
   SELECT '|123456789|123456789|123456789|123456789|123456789|123456789|123456789|123456789|123456789|123456789' txt FROM DUAL
)
SELECT 
   rqt.txt
FROM 
   rqt
WHERE 1=1
  AND REGEXP_LIKE( rqt.txt, 'unique', 'i')
;

-----------------------------------------------------------
--------------  Search => INSTR   ----------------
-----------------------------------------------------------

-- Matching
SELECT 
   INSTR('foobar', 'bar')
FROM
  dual;
-- 4  
  
--  Not matching
SELECT 
   INSTR('foobar', 'bor')
FROM
  dual;  
-- 0  
  
-- 2nd matching 
SELECT 
   INSTR(
      'foobarfooobar', 
      'bar', -- pattern
      1,     --serch start position
      2      -- nth occurence 
   )
FROM
  dual;  
  
  
-- EOL
SELECT 
   INSTR( 'foo',            CHR(10))
FROM
  dual;    
  
-- Start  
-- 1       4          5         8         9   
--'foo' || CHR(10) || 'bar' || CHR(10) || 'hello'
  
-- Backward 
SELECT
   INSTR(
      'foo' , 
      CHR(10), -- pattern
      -1,     --serch start position
      1      -- nth occurence 
   ) last_line_start_signe_line, 
   INSTR(
      'foo' || CHR(10) || 'bar' || CHR(10) || 'hello', 
      CHR(10), -- pattern
      -1,     --serch start position
      1      -- nth occurence 
   ) last_line_start_multi_line
FROM
  dual;  
    
  
-- Start  
-- 1       4          5         8         9   
--'foo' || CHR(10) || 'bar' || CHR(10) || 'hello'  
  
-- Edge cases
SELECT
   INSTR(
      '' || CHR(10), 
      CHR(10), -- pattern
      -1,     --serch start position
      1      -- nth occurence 
   ) last_line_start_multi_line,
   INSTR(
      'foo' || CHR(10) || 'bar' || CHR(10) || 'hello' || CHR(10), 
      CHR(10), -- pattern
      -1,     --serch start position
      1      -- nth occurence 
   ) last_line_start_multi_line,
   INSTR(
      'foo' || CHR(10) || 'bar' || CHR(10) || 'hello' || CHR(10), 
      CHR(10), -- pattern
      -1,     --serch start position
       2      -- nth occurence 
   ) last_line_start_multi_line   
FROM
  dual;  
    
    
  
  
SELECT
   derniere_ligne('ligne1' || CHR(10) || 'ligne2' || CHR(10) || 'ligne3')  
FROM DUAL
;  
  

-----------------------------------------------------------
--------------  Search => SUBTR   ----------------
-----------------------------------------------------------

-- Search for a (sub)string in a string 


-- SUBSTR
-- - char
-- - position 
-- - substring_length



SELECT 
   SUBSTR('123', 0, 1),
   SUBSTR('123', 1, 1),
   SUBSTR('LIGNE1XLIGNE2', 8, 6),
   LENGTH('LIGNE2')
FROM 
   dual
;


SELECT 
  INSTR('123456789', '78') debut,
  LENGTH('123456789')      taille_chaine,
  LENGTH('123456789') - INSTR('123456789', '78' )  taille_souschaine,
  SUBSTR('123456789', 7, 3)
FROM 
   dual
;

SELECT 
  INSTR('123456789' || CHR(10), '78') debut,
  LENGTH('123456789' || CHR(10))      taille_chaine,
  LENGTH('123456789' || CHR(10)) - INSTR('123456789' || CHR(10), '78' ) + 1 taille_souschaine,
  SUBSTR('123456789' || CHR(10) , 7, 3)
FROM 
   dual
;

SELECT 
   SUBSTR('123456789', 2, 3)
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


-----------------------------------------------------------
--------------  Pad string => LPAD  ---
-----------------------------------------------------------

/*
LPAD
*  string1        => '123',
* padded_length   => 3,
* pad_string      => '_'
*/

-- Size
SELECT 
   RPAD(
    ':',
    5,
    '__'
    )
FROM 
   dual
;

-- Size
SELECT 
   LPAD(
    '123',
    15,
    '_'
    )
FROM 
   dual
;


-- Size
SELECT 
   LPAD(
    '123',
    length('123') + 5,
    '_'
    )
FROM 
   dual
;

---------------------
-- Générer chaine
-----------------
SELECT
  chaine( caractere => 'a', nombre => 5)
FROM dual;


SELECT
  chaine('a',5)
FROM dual;


SELECT
  chaine(5)
FROM dual;


SELECT
  chaine_blanc(5)
FROM dual;


SELECT
  repeter_chaine('--', 5)
FROM dual;


WITH 
data AS (
SELECT 1 AS id, 1 AS msg_level,  'level1 : A' AS msg FROM DUAL UNION ALL 
SELECT 2 AS id, 2 AS msg_level,  'level2 : a' AS msg FROM DUAL UNION ALL
SELECT 3 AS id, 2 AS msg_level,  'level2 : b' AS msg FROM DUAL UNION ALL
SELECT 4 AS id, 3 AS msg_level,  'level3 : 1' AS msg FROM DUAL UNION ALL
SELECT 5 AS id, 3 AS msg_level,  'level3 : 2' AS msg FROM DUAL UNION ALL
SELECT 6 AS id, 3 AS msg_level,  'level3 : 3' AS msg FROM DUAL UNION ALL
SELECT 7 AS id, 2 AS msg_level,  'level2 : c' AS msg FROM DUAL UNION ALL
SELECT 8 AS id, 1 AS msg_level,  'level1 : B' AS msg FROM DUAL UNION ALL
SELECT 9 As id, 1 AS msg_level,  'level1 : C' AS msg FROM DUAL
),
indented_data AS (
SELECT
  dt.id,
  dt.msg_level,
  dt.msg,  
  repeter_chaine('--', dt.msg_level) prefix,
  DECODE (
      dt.msg_level - LAG(msg_level)  OVER (ORDER BY id ASC),
      1,
      'Y', 'N') increasing
   ,DECODE (
      dt.msg_level - LEAD(msg_level)  OVER (ORDER BY id ASC),
      1,
      'Y', 'N')       decreasing 
    ,DECODE (
      dt.msg_level - LAG(msg_level)  OVER (ORDER BY id ASC),
      0,
      DECODE ( dt.msg_level - LEAD(msg_level) OVER (ORDER BY id ASC),
        0,
        'Y',
        'N')      
      ,'N')       same
FROM data dt
)
-- SELECT * FROm indented_data  ;
SELECT
    dt.msg_level
   ,dt.msg
   , dt.prefix  
    || 
      DECODE (
        dt.increasing, 
        'Y', '->')
   || 
      DECODE (
        dt.decreasing, 
        'Y', '<-')        
   ||
       DECODE (
        dt.same, 
        'Y', '--')        
    ||
       dt.msg     msg_fmt
     ,dt.increasing   
     ,dt.same   
     ,dt.decreasing   
FROM indented_data dt
ORDER BY
  dt.id ASC
;