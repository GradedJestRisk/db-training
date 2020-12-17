DROP FUNCTION IF EXISTS public.put_query_param();
CREATE OR REPLACE FUNCTION public.put_query_param(p_name TEXT, p_location TEXT)
    RETURNS TEXT
    LANGUAGE 'plpgsql'
AS
$BODY$
DECLARE

    -- request
    uri          TEXT;
    baseURL      TEXT := 'https://hello-scalingo.osc-fr1.scalingo.io';
    endpoint     TEXT := 'hello';
    payload_json TEXT := '{ "name": "jim", "location": "nebraska" }';
    content_type TEXT := 'application/json';
    ok_status    INTEGER = 200;

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
