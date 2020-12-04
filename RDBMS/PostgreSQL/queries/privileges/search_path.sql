SHOW search_path;

SELECT *
FROM schema1.foo;

SELECT *
FROM foo;

-- Default value
SET search_path TO schema1, "$user", public;

SHOW search_path;

SELECT *
FROM foo;

-- Back to default value
SET search_path TO "$user", public;