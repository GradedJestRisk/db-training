select * from pg_views
;

-- Views
SELECT
       'Indexes=>' qry
       ,vws.viewname    vw_nm
       ,vws.viewowner   vw_wnr
       ,vws.definition  vw_dfn
       ,'vws=>' qry
       ,vws.*
FROM pg_views vws
WHERE 1=1
    AND vws.schemaname <> 'pg_catalog'
   -- AND vws.viewname = 'students'
;



-- Views
SELECT COUNT(1) FROM pg_views vws WHERE vws.viewname = 'students';

