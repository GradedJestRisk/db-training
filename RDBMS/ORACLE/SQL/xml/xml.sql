
-- http://www.experience-developpement.fr/oracle-generez-du-xml-directement-dans-vos-select/

-------------------------
------ Generate markup ---------
-------------------------





--- Generate one element (nom + contenu) => (XML)ELEMENT

-- Markup, without payload
SELECT
  XMLELEMENT("markup")
FROM
  DUAL
;
-- <markup></markup>


-- Long Markup (> 30), without payload
SELECT
  XMLELEMENT("0123456789012345678901234567890")
FROM
  DUAL
;
-- <01234567890123456789012345678901></01234567890123456789012345678901>


-- Markup, with payload
WITH data AS (
    SELECT 'value_one' AS value FROM DUAL
    UNION ALL
    SELECT 'value_two' AS value FROM DUAL    
) 
SELECT 
   XMLELEMENT("markup", data.value ) markup
FROM 
    data
;
-- <markup>value_one</markup>
-- <markup>value_two</markup>



--- Markup, with child
WITH data AS (
    SELECT 'value_one' AS value FROM DUAL
    UNION ALL
    SELECT 'value_two' AS value FROM DUAL    
) 
SELECT 
   XMLELEMENT("parent",  XMLELEMENT("child", data.value ) markup ) markup
FROM 
    data
;



-------------------------
------ Generate attributes  ---------
-------------------------
/*
XMLATTRIBUTES
- valeur de l'attribut1 AS nom de l'attribut1  
(..)
- valeur de l'attributN AS nom de l'attributN
*/

-- Attribute
WITH data AS (
    SELECT 'value_one:a' AS value1, 'value_two:c' AS value2 FROM DUAL
    UNION ALL
    SELECT 'value_one:b' AS value1, 'value_two:d' AS value2 FROM DUAL    
) 
SELECT 
   XMLELEMENT(
     "markup"
     ,XMLATTRIBUTES(
        value1 AS attribute1,
        value2 AS attribute2        
        )
   ) markup
FROM 
    data
;
-- <markup ATTRIBUTE1="value_one:a" ATTRIBUTE2="value_two:c"></markup>
-- <markup ATTRIBUTE1="value_one:b" ATTRIBUTE2="value_two:d"></markup>


-------------------------
------ Agregate ---------
-------------------------


--- Aggregate 2 lines in same line => XMLAGG
WITH data AS (
    SELECT 'value_one' AS value FROM DUAL
    UNION ALL
    SELECT 'value_two' AS value FROM DUAL    
), 
data_xml AS (
SELECT 
   XMLELEMENT("markup", data.value ) markup
FROM 
    data)
SELECT
      XMLAGG (data_xml.markup)
--      data_xml.markup
FROM data_xml
;
-- <markup>value_one</markup><markup>value_two</markup>


--- Aggragate 2 columns  in one line => XMLFOREST
WITH data AS (
    SELECT 'dataValue1Line1' AS value1, 'dataValue2Line1' AS value2  FROM DUAL
), 
data_xml AS (
SELECT 
   XMLFOREST(data.value1, data.value2 ) markup
FROM 
    data)
SELECT
      XMLAGG (data_xml.markup)
--      data_xml.markup
FROM data_xml
;
-- <VALUE1>dataValue1</VALUE1><VALUE2>dataValue2</VALUE2>

-------------------------
------ Format XML ---------
-------------------------

SELECT
  format_xml('<X><Y><Z>123</Z></Y></X>')
FROM
  dual 
;


-------------------------
------  XML search ---------
-------------------------


-- A réparer (XMLTYPE ??)
WITH affaire AS(
  SELECT '2671823' AS numero FROM DUAL
) 
SELECT 
   xml_svg.id_opvprep
   ,SUBSTR(xml_svg.element_xml, INSTR( xml_svg.element_xml, affaire.numero) - 30, 100)  extrait_xml
   ,xml_svg.element_xml                                                                xml_complet
FROM
  pfl_xml_svg_telefi xml_svg,
  affaire 
WHERE 1=1
--   AND xml_svg.id_opvprep = 17539920 
   AND INSTR( xml_svg.element_xml, affaire.numero) <> 0
;



-------------------------
------  XML ? : XMLFOREST ---------
-------------------------




-------------------------
------  XML ? : XMLCONCAT ---------
-------------------------





-------------------------------------
------  XML extract : EXTRACTVALUE --
-------------------------------------

-- Extract payload
WITH data AS (
SELECT 
    XMLTYPE('<node>payload</node>') value 
FROM dual
)
SELECT
    d.value                         content, 
    EXTRACTVALUE(d.value, '/node') payload
FROM 
   data d
;






-- Extract payload (nested node)
WITH data AS (
SELECT 
    XMLTYPE('<node1>
                <node2>payload</node2>
             </node1>'
    ) value 
FROM dual
)
SELECT
    d.value                         content, 
    EXTRACTVALUE(d.value, '/node1/node2') payload
FROM 
   data d
;


-- Extract payload (nested node) => can only retrieve a leaf !!
WITH data AS (
SELECT 
    XMLTYPE('<node1>
                <node2>payload</node2>
             </node1>'
    ) value 
FROM dual
)
SELECT
    d.value                         content, 
    EXTRACTVALUE(d.value, '/node1') payload
FROM 
   data d
;
-- ORA-19026: EXTRACTVALUE can only retrieve value of leaf node



-- Extract unexisting noded (nested node)
WITH data AS (
SELECT 
    XMLTYPE('<node1>
                <node3>payload</node3>
             </node1>'
    ) value 
FROM dual
)
SELECT
    d.value                         content 
    ,EXTRACTVALUE(d.value, '/node1/node2') payload
    ,NVL(EXTRACTVALUE(d.value, '/node1/node2'),'NOT EXISTS') not_existing
    ,DECODE(EXTRACTVALUE(d.value, '/node1/node2'), 
        NULL, 'NOT EXISTS',
        'EXISTS') existing_state 
FROM 
   data d
;



-- Extract attribute
WITH data AS (
SELECT 
    XMLTYPE('<node1 attribute1="8"/>') value 
FROM dual
)
SELECT
    d.value                         content, 
    EXTRACTVALUE(d.value, '/node1/@attribute1') payload
FROM 
   data d
;


-- Extract sequence
SELECT 
  extracted_sequence.column_value                    node
  ,EXTRACTVALUE(VALUE(extracted_sequence), '/node2') payload
FROM     
    TABLE(
      XMLSEQUENCE( 
        EXTRACT(
          XMLTYPE('
          <node1>
              <node2>a</node2>
              <node2>b</node2>
            </node1>'
          ), 
          '/node1/node2' ) 
      ) 
    ) extracted_sequence
;
