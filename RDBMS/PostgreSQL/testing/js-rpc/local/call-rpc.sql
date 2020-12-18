DROP FUNCTION IF EXISTS call_rpc();

CREATE OR REPLACE FUNCTION call_rpc(p_function TEXT, p_payload TEXT)
    RETURNS TEXT
    LANGUAGE 'plpgsql'
AS
$BODY$
DECLARE

    -- request
    baseURL      CONSTANT TEXT := 'https://hello-scalingo.osc-fr1.scalingo.io';
    content_type CONSTANT TEXT := 'application/json';
    ok_status    CONSTANT INTEGER = 200;

    uri          TEXT;
    endpoint     TEXT := p_function;
    payload      TEXT := p_payload;

    -- response
    response_payload   TEXT;
    response_status    INTEGER;

BEGIN

    uri := baseURL  || '/' || endpoint;

    SELECT
        status, content
    INTO
        response_status, response_payload
    FROM http_put(
        uri,
        payload,
        content_type
        );

    IF response_status <> ok_status THEN
        RAISE EXCEPTION 'Call to %  failed with status code %', uri, response_status;
    END IF;

    RETURN response_payload;

END
$BODY$;
