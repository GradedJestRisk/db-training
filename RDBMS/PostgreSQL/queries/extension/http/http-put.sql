DROP FUNCTION IF EXISTS public.put_query_param();
CREATE OR REPLACE FUNCTION public.put_query_param(p_name TEXT, p_location TEXT)
    RETURNS TEXT
    LANGUAGE 'plpgsql'
AS
$BODY$
DECLARE

    -- request
    query TEXT;
    baseURL TEXT := 'https://hello-scalingo.osc-fr1.scalingo.io';
    endpoint TEXT := 'hello';
    payload JSON :=  { name: 'bar', location: 'foo' };

    -- response
    response  TEXT;
    status TEXT;

BEGIN

    query := baseURL  || '/' || endpoint || '/' || p_name || '/' || p_location;

    SELECT
        content, status
    INTO
        response, status
    FROM http_put(
        query,
   payload,
'text/plain'
        );

    RAISE NOTICE 'response code: %', status;
    RETURN response;

END
$BODY$;
