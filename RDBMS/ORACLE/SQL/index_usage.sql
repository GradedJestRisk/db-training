



PAE_PRIX_ACHAT
-- Monitored indexes
SELECT 
   ndx_mon.table_name,
   COUNT(1)  
FROM (SELECT 
               du.username                    AS owner, 
               io.NAME                        AS index_name,
               t.NAME                         AS table_name,
               DECODE (BITAND (i.flags, 65536),
                       0, 'NO',
                       'YES'
                      )                       AS monitoring,
               DECODE (
                  BITAND (ou.flags, 1), 
                  0, 'NO', 
                  'YES')                     AS used,
               ou.start_monitoring           AS start_monitoring,
               ou.end_monitoring             AS end_monitoring
          FROM 
               SYS.obj$ io,
               SYS.obj$ t,
               SYS.ind$ i,
               SYS.object_usage ou,
               dba_users du
         WHERE 1=1
           AND   i.obj# = ou.obj#
           AND   io.obj# = ou.obj#
           AND   t.obj# = i.bo#
           AND   io.owner# = du.user_id
           AND   BITAND (i.flags, 65536) <> 0) ndx_mon
WHERE 1=1
   AND ndx_mon.owner = 'DBOFAP'
--   AND ndx_mon.index_name = 'TRCNAT_FK'   
GROUP BY
   ndx_mon.table_name
ORDER BY
   COUNT(1) DESC
;






-- Unmonitored indexes
SELECT *
  FROM (SELECT du.username AS owner, io.NAME AS indew_name,
               t.NAME AS table_name,
               DECODE (BITAND (i.flags, 65536),
                       0, 'NO',
                       'YES'
                      ) AS MONITORING,
               DECODE (BITAND (ou.flags, 1), 0, 'NO', 'YES') AS used,
               ou.start_monitoring AS start_monitoring,
               ou.end_monitoring AS end_monitoring
          FROM SYS.obj$ io,
               SYS.obj$ t,
               SYS.ind$ i,
               SYS.object_usage ou,
               dba_users du
         WHERE                                     --io.owner# like '%AAA' and
               i.obj# = ou.obj#
           AND io.obj# = ou.obj#
           AND t.obj# = i.bo#
           AND io.owner# = du.user_id
           AND BITAND (i.flags, 65536) = 0 )
--WHERE
;

 
-- Monitored and used indexes
SELECT *
  FROM (SELECT du.username AS owner, io.NAME AS indew_name,
               t.NAME AS table_name,
               DECODE (BITAND (i.flags, 65536),
                       0, 'NO',
                       'YES'
                      ) AS MONITORING,
               DECODE (BITAND (ou.flags, 1), 0, 'NO', 'YES') AS used,
               ou.start_monitoring AS start_monitoring,
               ou.end_monitoring AS end_monitoring
          FROM SYS.obj$ io,
               SYS.obj$ t,
               SYS.ind$ i,
               SYS.object_usage ou,
               dba_users du
         WHERE                                    
               i.obj# = ou.obj#
           AND io.obj# = ou.obj#
           AND t.obj# = i.bo#
           AND io.owner# = du.user_id)
WHERE 1=1
   AND   BITAND (i.flags, 65536) <> 0
   AND   used = 'YES'
 ;

-- Monitored and unused indexes
SELECT *
  FROM (SELECT du.username AS owner, io.NAME AS indew_name,
               t.NAME AS table_name,
               DECODE (BITAND (i.flags, 65536),
                       0, 'NO',
                       'YES'
                      ) AS MONITORING,
               DECODE (BITAND (ou.flags, 1), 0, 'NO', 'YES') AS used,
               ou.start_monitoring AS start_monitoring,
               ou.end_monitoring AS end_monitoring
          FROM SYS.obj$ io,
               SYS.obj$ t,
               SYS.ind$ i,
               SYS.object_usage ou,
               dba_users du
         WHERE                                    
               i.obj# = ou.obj#
           AND io.obj# = ou.obj#
           AND t.obj# = i.bo#
           AND io.owner# = du.user_id)
WHERE 1=1
   AND   BITAND (i.flags, 65536) <> 0
   AND   used = 'NO'
 ;