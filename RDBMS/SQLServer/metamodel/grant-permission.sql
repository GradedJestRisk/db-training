
DROP TABLE test;

CREATE TABLE test
(
  id   INT NOT NULL PRIMARY KEY ,
  name      CHAR(10),
  firstname VARCHAR(10),
  lastname  VARCHAR(MAX)
);

INSERT INTO test VALUES (1, 'foo', 'bar', 'foobar')
;


SELECT * FROM dbo.test
;


CREATE LOGIN loginTest WITH PASSWORD = 'Password123';
CREATE USER userTest FOR LOGIN loginTest;

USE INT01_SAM_ODS
GO

-- Revoke
REVOKE SELECT TO userTest;
REVOKE CONTROL TO userTest;

-- Grant access to a table
GRANT SELECT ON dbo.test TO userTest;

-- Grant access to all tables
GRANT SELECT TO userTest;

-- Grant access to everything
GRANT CONTROL TO userTest;

-- Unrestricted SELECT permissions (all tables)
SELECT
    princ.name, princ.[name],
    [PermissionType] = perm.[permission_name],
    [PermissionState] = perm.[state_desc],
    perm.major_id
FROM
    --database user
    sys.database_principals princ
    LEFT JOIN
        --Login accounts
        sys.login_token ulogin on princ.[sid] = ulogin.[sid]
    LEFT JOIN
        --Permissions
        sys.database_permissions perm ON perm.[grantee_principal_id] = princ.[principal_id]
WHERE 1=1
    AND princ.type = 'S'
    AND princ.name = 'userTest'
    --AND perm.permission_name = 'SELECT'
    AND perm.major_id = 0
;


SELECT *
From test;

-- sqlcmd -S localhost -U loginTest -No
USE INT01_SAM_ODS
GO
SELECT * FROM test;