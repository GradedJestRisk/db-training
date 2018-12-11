-----------------------------------------------------------------------------
----------  Utilisateur -----------------
-----------------------------------------------------------------------------

SELECT * FROM 
   all_users tls
WHERE 1=1
   AND   tls.username   =   'FAP'
;

-- Changer mot de passe
ALTER USER 
   MLLA 
IDENTIFIED BY 
   MLLA
;


 SELECT USERNAME, PROFILE FROM DBA_USERS
    WHERE  USERNAME = 'SYSTEM' ;
    
-- password lock timeunit is days
SELECT RESOURCE_NAME, LIMIT FROM DBA_PROFILES
    WHERE  PROFILE = 'DEFAULT'
    
    ;