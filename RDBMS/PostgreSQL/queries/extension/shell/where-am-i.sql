CREATE EXTENSION IF NOT EXISTS plsh;

CREATE OR REPLACE FUNCTION where_am_i()
RETURNS text
LANGUAGE plsh
AS $$
#!/bin/sh
echo "current directory"
pwd
echo "content"
ls -la
echo "container id:"
head -1 /proc/self/cgroup | cut -d/ -f3
$$;
