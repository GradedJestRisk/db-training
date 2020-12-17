CREATE EXTENSION IF NOT EXISTS plsh;

CREATE OR REPLACE FUNCTION hello_shell (who TEXT) RETURNS text
LANGUAGE plsh
AS $$
#!/bin/sh
echo "Waking up.."
echo "Hello, $1 !"
return 0;
$$;
