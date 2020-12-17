CREATE EXTENSION IF NOT EXISTS plsh;

CREATE OR REPLACE FUNCTION hello_shell_node (p_name TEXT, p_location TEXT)
RETURNS text
LANGUAGE plsh
AS $$
#!/bin/sh
BASE_DIR="/tmp"
cd $BASE_DIR
./execute.js --function hello --name $1 --location $2
$$;
