
--
SELECT "current_user"()
;


SELECT * FROM pg_roles;

-- User
select oid userId, rolname userName from pg_authid usr where usr.oid = 10;
