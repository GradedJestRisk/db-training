-- Tables + columns
SELECT
    tbl.name tbl
    ,clm.name clm_nm
    ,clm.column_id clm_dtf
    ,typ.name typ
    ,clm.max_length as str
    ,clm.precision
    ,clm.scale
    ,'columns=>'
    ,clm.*
FROM sys.columns clm
    INNER JOIN sys.tables tbl ON clm.object_id = tbl.object_id
    INNER JOIN sys.types typ ON typ.system_type_id = clm.system_type_id
WHERE 1=1
   AND tbl.schema_id = 1
   AND tbl.name LIKE 'T_%'
--    AND clm.is_identity = 'true'
    AND clm.name = 'LI_TICKET'
ORDER BY  tbl.name, clm.name
;

-- User
SELECT
    'utilisateurs=>'
	,li_login
    ,li_nom
    ,li_prenom
	,li_pwd
	,li_ticket
	,'T_UTILISATEURS=>'
    ,tls.*
FROM T_UTILISATEURS tls
WHERE 1=1
--     AND tls.
;