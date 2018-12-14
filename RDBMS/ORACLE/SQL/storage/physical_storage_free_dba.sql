
set lines 150 pages 100
col STATUT for A20 head "STATUT" wrap
col tbsName for A25 head "TABLESPACE" wrap
col prmType for A1 head "T" trunc

col extMan for A1 head "X" trunc
col tbsStat for A2 head "On" trunc
col tbsMsize for 9,999,990 head "TAILLE|Allouée|(M)" trunc
col tbsMsizeMax for 99,999,990 head "TAILLE|Limite|(M)" trunc
col usedSize for 9,999,990 head "VOLUME|Utilise|(M)" trunc
col usedPct for 999.99 head "VOLUME|/alloué|(%)" trunc
col usedTotPct for 999.99 head "VOLUME|/limite|(%)" trunc

SELECT
--decode( greatest(90,nvl(t.BYTES/a.BYTES*100,0)), 90, 'TAILLE_TBS_OK', 'WARNING_TBS_FULL' ) STATUT,
         CASE
            WHEN d.tablespace_name LIKE 'SYS%'
               THEN ' NO_CHECK'
            WHEN CASE
                   WHEN NVL (w.BYTES / 1024 / 1024, 0) != 0
                      THEN NVL (  (a.BYTES - NVL (f.BYTES, 0))
                                / NVL (w.BYTES, 0)
                                * 100,
                                0
                               )
                   ELSE NVL ((a.BYTES - NVL (f.BYTES, 0)) / a.BYTES * 100, 0)
                END > 95
               THEN '!! ALERT_TBS > 95%'
            WHEN CASE
                   WHEN NVL (w.BYTES / 1024 / 1024, 0) != 0
                      THEN NVL (  (a.BYTES - NVL (f.BYTES, 0))
                                / NVL (w.BYTES, 0)
                                * 100,
                                0
                               )
                   ELSE NVL ((a.BYTES - NVL (f.BYTES, 0)) / a.BYTES * 100, 0)
                END > 85
               THEN '! WARNING_TBS > 85%'
            ELSE ' TBS_SIZE_OK'
         END statut,
         d.tablespace_name tbsname,
         DECODE (d.CONTENTS,
                 'PERMANENT', 'P',
                 'TEMPORARY', 'T',
                 'UNDO', 'U'
                ) prmtype,
         DECODE (d.extent_management, 'LOCAL', 'L', 'D') extman,
         DECODE (d.status, 'ONLINE', ' Y', ' N') tbsstat,
         NVL (a.BYTES / 1024 / 1024, 0) tbsmsize,
         NVL (w.BYTES / 1024 / 1024, 0) tbsmsizemax,
         NVL (a.BYTES - NVL (f.BYTES, 0), 0) / 1024 / 1024 usedsize,
         NVL ((a.BYTES - NVL (f.BYTES, 0)) / a.BYTES * 100, 0) usedpct,
         CASE
            WHEN NVL (w.BYTES / 1024 / 1024, 0) != 0
               THEN NVL ((a.BYTES - NVL (f.BYTES, 0)) / NVL (w.BYTES, 0) * 100,
                         0
                        )
            ELSE NVL ((a.BYTES - NVL (f.BYTES, 0)) / a.BYTES * 100, 0)
         END usedtotpct
    FROM dba_tablespaces d,
         (SELECT   tablespace_name, SUM (BYTES) BYTES
              FROM dba_data_files
          GROUP BY tablespace_name) a,
         (SELECT   tablespace_name, SUM (BYTES) BYTES
              FROM dba_free_space
          GROUP BY tablespace_name) f,
         (SELECT   tablespace_name,
                   SUM (CASE
                           WHEN (autoextensible = 'YES')
                              THEN maxbytes
                           ELSE BYTES
                        END
                       ) BYTES
              FROM dba_data_files
          GROUP BY tablespace_name) w
   WHERE d.tablespace_name = a.tablespace_name(+)
     AND d.tablespace_name = f.tablespace_name(+)
     AND d.tablespace_name = w.tablespace_name(+)
     AND NOT (d.extent_management = 'LOCAL' AND d.CONTENTS = 'TEMPORARY')
UNION ALL
SELECT
--decode( greatest(90,nvl(t.BYTES/a.BYTES*100,0)), 90, 'TAILLE_TBS_OK', 'WARNING_TBS_FULL' ) STATUT,
         CASE
            WHEN d.tablespace_name LIKE 'SYS%'
               THEN ' NO_CHECK'
            WHEN CASE
                   WHEN NVL (w.BYTES / 1024 / 1024, 0) != 0
                      THEN NVL (t.BYTES / NVL (w.BYTES, 0) * 100, 0)
                   ELSE NVL (t.BYTES / a.BYTES * 100, 0)
                END > 95
               THEN '!! ALERT_TBS > 95%'
            WHEN CASE
                   WHEN NVL (w.BYTES / 1024 / 1024, 0) != 0
                      THEN NVL (t.BYTES / NVL (w.BYTES, 0) * 100, 0)
                   ELSE NVL (t.BYTES / a.BYTES * 100, 0)
                END > 85
               THEN '! WARNING_TBS > 85%'
            ELSE ' TBS_SIZE_OK'
         END statut,
         d.tablespace_name tbsname,
         DECODE (d.CONTENTS,
                 'PERMANENT', 'P',
                 'TEMPORARY', 'T',
                 'UNDO', 'U'
                ) prmtype,
         DECODE (d.extent_management, 'LOCAL', 'L', 'D') extman,
         DECODE (d.status, 'ONLINE', ' Y', ' N') tbsstat,
         NVL (a.BYTES / 1024 / 1024, 0) tbsmsize,
         NVL (w.BYTES / 1024 / 1024, 0) tbsmsizemax,
         NVL (t.BYTES, 0) / 1024 / 1024 usedsize,
         NVL (t.BYTES / a.BYTES * 100, 0) usedpct,
         CASE
            WHEN NVL (w.BYTES / 1024 / 1024, 0) != 0
               THEN NVL (t.BYTES / NVL (w.BYTES, 0) * 100, 0)
            ELSE NVL (t.BYTES / a.BYTES * 100, 0)
         END usedtotpct
    FROM dba_tablespaces d,
         (SELECT   tablespace_name, SUM (BYTES) BYTES
              FROM dba_temp_files
          GROUP BY tablespace_name) a,
         (SELECT   tablespace_name, SUM (bytes_used) BYTES
              FROM v$temp_extent_pool
          GROUP BY tablespace_name) t,
         (SELECT   tablespace_name,
                   SUM (CASE
                           WHEN (autoextensible = 'YES')
                              THEN maxbytes
                           ELSE BYTES
                        END
                       ) BYTES
              FROM dba_temp_files
          GROUP BY tablespace_name) w
   WHERE d.tablespace_name = a.tablespace_name(+)
     AND d.tablespace_name = t.tablespace_name(+)
     AND d.tablespace_name = w.tablespace_name(+)
     AND d.extent_management = 'LOCAL'
     AND d.CONTENTS = 'TEMPORARY'
ORDER BY 1 DESC, 2 ASC;

