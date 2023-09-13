-- Alpine
CREATE EXTENSION IF NOT EXISTS plsh;

CREATE OR REPLACE FUNCTION get_pg_processes()
RETURNS text
LANGUAGE plsh
AS $$
#!/bin/sh
ps
$$;
SELECT get_pg_processes();


-- Ubuntu
CREATE EXTENSION IF NOT EXISTS plsh;
CREATE OR REPLACE FUNCTION get_pg_processes_io()
RETURNS text
LANGUAGE plsh
AS $$
#!/bin/sh
iotop --user=postgres --batch --iter=1 --quiet
$$;

SELECT get_pg_processes_io();

