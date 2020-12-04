
--
SELECT "current_user"()
;

-- User
select oid userId, rolname userName from pg_authid usr where usr.oid = 10;
