select bjt.name, clm.*
FROM sys.columns clm
    INNER JOIN sys.objects bjt ON bjt.object_id = clm.object_id
WHERE 1=1
    AND clm.name = 'CD_ETAP_SIN'
: