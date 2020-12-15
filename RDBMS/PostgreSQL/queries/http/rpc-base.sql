DROP FUNCTION IF EXISTS public.hello_over_network();
CREATE OR REPLACE FUNCTION public.hello_over_network()
    RETURNS TEXT
    LANGUAGE 'plpgsql'
AS
$BODY$
DECLARE
    response  TEXT;
BEGIN

    SELECT content INTO response
    FROM http_get('http://localhost:3000');
--    FROM http_get('http://httpbin.org/get');

    RETURN response;

END
$BODY$;
