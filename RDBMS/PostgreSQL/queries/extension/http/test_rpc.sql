SELECT hello_over_network();


----- URL

-- curl --request PUT localhost:3000/hello/foo/bar
-- curl --request PUT https://hello-scalingo.osc-fr1.scalingo.io/hello/foo/bar

----- Payload

curl --header "Content-Type: application/json" \
  --request PUT \
  --data '{"name":"john","location":"delaware"}' \
  localhost:3000/hello

curl --header "Content-Type: application/json" \
  --request PUT \
  --data '{"name":"john","location":"delaware"}' \
  https://hello-scalingo.osc-fr1.scalingo.io/hello

SELECT call_rpc(p_function := 'hello', p_payload := '{ "name": "joe", "location" : "delaware" }');
SELECT hello(p_name := 'joe', p_location := 'delaware');


SELECT put_query_param(p_name := 'joe', p_location := 'delaware');

--SELECT put_query_param();


SELECT hello_over_network(p_user_id := 1, p_email := 'foo@bar.com');

--SELECT jsonb_pretty(hello_over_network()::jsonb);