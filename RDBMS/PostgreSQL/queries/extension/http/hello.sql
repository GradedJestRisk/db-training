DROP FUNCTION IF EXISTS hello();

CREATE OR REPLACE FUNCTION hello(p_name TEXT, p_location TEXT)
    RETURNS TEXT
    LANGUAGE 'plpgsql'
AS
$BODY$
DECLARE

    -- request
    payload TEXT;
    function_name CONSTANT TEXT := 'hello';

    -- response
    value TEXT;

BEGIN

    payload := '{ "name": "'|| p_name ||'", "location": "'|| p_location ||'" }';

    SELECT call_rpc(p_function := function_name, p_payload := payload)
    INTO value;

    RETURN value;

END
$BODY$;

