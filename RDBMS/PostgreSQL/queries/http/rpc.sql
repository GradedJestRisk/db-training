DROP FUNCTION IF EXISTS public.hello_over_network();
CREATE OR REPLACE FUNCTION public.hello_over_network(
    p_user_id INTEGER, p_email TEXT)
    RETURNS TEXT
    LANGUAGE 'plpgsql'
AS
$BODY$
DECLARE

    -- Variables --
    message_json                  TEXT;
    response_code                 INTEGER;
    response_data                 TEXT;

    -- Constants --

    -- Return messages
    CHANGE_PROPAGATED    CONSTANT TEXT := 'SUCCESS';
    MESSAGE_REJECTED     CONSTANT TEXT := 'FAILURE';

BEGIN

    message_json := '{ type: ''emailChangedEvent'', userId: ''' || p_user_id || ''', email: ''' || p_email || ''' }';

    SELECT status,
           content::json ->> 'data' AS data
    INTO
        response_code,
        response_data
    FROM
        http_put('http://localhost:3000/hello', message_json, 'application/json');

    RAISE NOTICE 'response code: %', response_code;
    RAISE NOTICE 'response data: %', response_data;

    IF response_code != 200 THEN
        RETURN MESSAGE_REJECTED;
    END IF;

    RETURN CHANGE_PROPAGATED;

END
$BODY$;
