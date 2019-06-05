-- Identify a row without PK (ROWID)
SELECT
  t.ROWID row_id,
  t.*
FROM ref_batch t
;
-- Do       work for table
-- Does NOT work for views, intermediate results (WITH, GROUP BY ..) 

-- Limit number rows retrieved  (RONWUM)
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
  AND ROWNUM <= 2
;


