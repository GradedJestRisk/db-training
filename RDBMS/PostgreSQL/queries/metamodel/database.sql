SHOW SERVER_ENCODING;
-- UTF8

SHOW CLIENT_ENCODING;
-- UTF8

SELECT
    'database=>'
    ,db.oid     db_dtf
    ,db.datname db_nm
    ,'pg_database=>'
    ,db.*
FROM
    pg_database db
WHERE 1=1
--    AND db.datname = 'database'
;

select * from information_schema.schemata;

SELECT CURRENT_DATABASE();
DROP OWNED BY postgres;
DROP DATABASE pix;
