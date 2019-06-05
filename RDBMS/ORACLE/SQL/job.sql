-- Jobs
-- All
SELECT 
    'Jobs=>'      qry_cnt
    ,jb.job       jb_dtf
    ,jb.what      jb_cmm
    ,DECODE( jb.broken, 'N', 'ACTIVE', 'INACTIVE') stt        
    ,jb.interval  periodicity
    ,jb.last_date xct_prv_scc_date
    ,jb.this_date xct_crr_dt
    ,jb.next_date xct_nxt_dt
    ,'all_jobs=>' x
    ,jb.*
FROM 
    dba_jobs jb
WHERE 1=1
--    AND jb.job = 
ORDER BY
    jb.job DESC
;


-- Jobs
-- Given a command (like)
-- All
SELECT 
    'Jobs=>'      qry_cnt
    ,jb.job       jb_dtf
    ,jb.what      jb_cmm
    ,DECODE( jb.broken, 'N', 'ACTIVE', 'INACTIVE') stt        
    ,jb.interval  periodicity
    ,jb.last_date xct_prv_scc_date
    ,jb.this_date xct_crr_dt
    ,jb.next_date xct_nxt_dt
    ,'all_jobs=>' x
    ,jb.*
FROM 
    dba_jobs jb
WHERE 1=1
    AND LOWER(jb.what) LIKE '%p_execute%'
ORDER BY
    jb.job DESC
;
select * from dba_SCHEDULER_JOBS  
;

select * from dba_SCHEDULER_JOB_RUN_DETAILS 
where TRUNC(log_date) = TRUNC(SYSDATE)
;

select * from DBA_SCHEDULER_JOB_RUN_DETAILS 
where TO_CHAR(log_date, 'YYYYMMDD') = TRUNC(SYSDATE)
;
