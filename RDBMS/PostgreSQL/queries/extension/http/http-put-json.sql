DROP FUNCTION IF EXISTS public.call_rpc();
CREATE OR REPLACE FUNCTION public.call_rpc(p_function TEXT, p_name TEXT, p_location TEXT)
    RETURNS TEXT
    LANGUAGE 'plpgsql'
AS
$BODY$
DECLARE

    -- request
    uri          TEXT;
    baseURL      CONSTANT TEXT := 'https://hello-scalingo.osc-fr1.scalingo.io';
    endpoint     TEXT := p_function;
    payload_json TEXT := '{ "name": "'|| p_name ||'", "location": "'|| p_location ||'" }';
    content_type CONSTANT TEXT := 'application/json';
    ok_status    CONSTANT INTEGER = 200;

    -- response
    response_payload   TEXT;
    response_status    INTEGER;

BEGIN

    uri := baseURL  || '/' || endpoint || '/' || p_name || '/' || p_location;

    SELECT
        status, content
    INTO
        response_status, response_payload
    FROM http_put(
        uri,
    payload_json,
content_type
        );

    IF response_status <> ok_status THEN
        RAISE EXCEPTION 'Call to %  failed with status code %', uri, response_status;
    END IF;

    RETURN response_payload;

END
$BODY$;
