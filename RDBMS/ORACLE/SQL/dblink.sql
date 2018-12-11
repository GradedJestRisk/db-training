---------------------------------------------------------------------------
--------------      Rights              -------------
---------------------------------------------------------------------------
SELECT
   DISTINCT PRIVILEGE AS "Database Link Privileges"
FROM ROLE_SYS_PRIVS
WHERE 1=1
   AND PRIVILEGE IN ( 
      'CREATE SESSION',
      'CREATE DATABASE LINK',
      'CREATE PUBLIC DATABASE LINK'
   )
;

GRANT CREATE DATABASE LINK TO fap
;

---------------------------------------------------------------------------
--------------      Usage                   -------------
---------------------------------------------------------------------------



SELECT  * FROM 
   all_db_links
;


SELECT  * 
FROM 
   all_db_links
WHERE 1=1
   AND db_link LIKE upper('dblk') || '%'
;


DROP DATABASE LINK 
   dblk
;


CREATE DATABASE LINK dblk
CONNECT TO fap IDENTIFIED BY FAP
USING '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=lnxfrh099700850.enterprise.horsprod.lan)(PORT=1521)) (CONNECT_DATA=(SID=FAP)(SERVER=DEDICATED)))'
;


SELECT 
   *
FROM 
   param@dblk
;

SELECT * FROM v$database
;

SELECT 'local: ' || instance_name || '@' ||host_name FROM v$instance
UNION
SELECT 'remote: ' || instance_name || '@' ||host_name FROM v$instance@dblk
;

DROP DATABASE LINK 
   dblk
;
