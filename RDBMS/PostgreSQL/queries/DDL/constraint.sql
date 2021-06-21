ALTER TABLE users_pix_roles
ADD CONSTRAINT UNIQUE (user_id, pix_role_id);

ALTER TABLE users_pix_roles
DROP CONSTRAINT test
;

