# Roles


All roles
```postgresql
SELECT *
FROM
     pg_roles rl
WHERE 1=1
--    AND rl.rolcanlogin IS TRUE
;
```
