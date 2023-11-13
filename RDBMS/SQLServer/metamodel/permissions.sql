

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
    --AND princ.name = 'userTest'
    AND perm.permission_name = 'SELECT'
    AND perm.major_id = 0
;
-- None


-- Nominative grant
-- List all access provisioned to a sql user or windows user/group directly
SELECT
     princ.name usr
    ,perm.permission_name prm
    ,perm.class_desc
    ,obj.type_desc bjc_typ
    ,OBJECT_NAME(perm.major_id) bjc_name
FROM
    --database user
    sys.database_principals princ
    LEFT JOIN
        --Login accounts
        sys.login_token ulogin on princ.sid = ulogin.sid
    LEFT JOIN
        --Permissions
        sys.database_permissions perm ON perm.grantee_principal_id = princ.principal_id
    LEFT JOIN
        sys.objects obj ON perm.major_id = obj.object_id
WHERE 1=1
    AND princ.type = 'S'
    AND perm.state_desc = 'GRANT'
--     AND princ.name <> 'usr_sam'
    AND princ.name = 'usr_sam'
--     AND OBJECT_NAME(perm.major_id) = 'test'
ORDER BY
    princ.name,
        perm.permission_name,
    perm.class_desc,
    obj.type_desc,
    bjc_name
;

-- Grouped
SELECT
    usr.name usr
    ,prm.permission_name prm
    ,prm.class_desc class
    ,obj.type_desc bjc_typ
    ,count(1) count
FROM
    sys.database_principals usr
    LEFT JOIN   sys.login_token ulogin on usr.sid = ulogin.sid
    LEFT JOIN   sys.database_permissions prm ON prm.grantee_principal_id = usr.principal_id
    LEFT JOIN  sys.objects obj ON prm.major_id = obj.object_id
WHERE 1=1
    AND usr.type = 'S'
    AND prm.state_desc = 'GRANT'
    AND prm.permission_name <> 'CONNECT'
--     AND UserName <> 'usr_sam'
--     AND OBJECT_NAME(prm.major_id) = 'test'
GROUP BY
    usr.name
    ,prm.permission_name
    ,prm.class_desc
    ,obj.type_desc
;


-- Control at the database level lets you do anything to the database you want, incuding dropping it!, but you can’t add someone to the db_owner role or make them the dbo of the database.

SELECT
    princ.name usr
    ,perm.permission_name prm
     ,perm.class_desc
    ,perm.major_id
    ,'database_permissions=>'
    ,perm.*
FROM
    --database user
    sys.database_principals princ
    LEFT JOIN
        --Permissions
        sys.database_permissions perm ON perm.grantee_principal_id = princ.principal_id
WHERE 1=1
    AND princ.type = 'S'
    AND perm.state_desc = 'GRANT'
    AND perm.permission_name = 'CONTROL'
    AND perm.class_desc = 'DATABASE'
ORDER BY princ.name
;
-- CONTROL on TYPE
--
SELECT
    typ.name
    ,'sys.types=>'
    ,typ.*
FROM sys.types typ
WHERE 1=1
    AND typ.is_user_defined = 1
    AND typ.user_type_id IN (257, 258, 259,260)
;