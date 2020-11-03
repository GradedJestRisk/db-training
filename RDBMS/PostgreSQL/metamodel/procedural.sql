--Languages
select lanname AS name from pg_language;

SELECT
 lng.lanname lng_name,
 prc.proname prc_name 
FROM
 pg_language lng,
 pg_proc      prc
WHERE 1=1
 AND lng.lanname = 'plpgsql'
 AND prc.prolang = lng.oid
;
