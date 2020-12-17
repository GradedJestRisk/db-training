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
   -- FROM http_get('https://hello-scalingo.osc-fr1.scalingo.io');
    FROM http_put('https://hello-scalingo.osc-fr1.scalingo.io/hello');
--    FROM http_get('http://httpbin.org/get');

    RETURN response;

END
$BODY$;
