-- Local
curl --header "Content-Type: application/json" \
  --request PUT \
  --data '{"name":"john","location":"delaware"}' \
  localhost:3000/hello

-- Remote
curl --header "Content-Type: application/json" \
  --request PUT \
  --data '{"name":"john","location":"delaware"}' \
  https://hello-scalingo.osc-fr1.scalingo.io/hello

-- Remote
SELECT call_rpc(p_function := 'hello', p_payload := '{ "name": "joe", "location" : "delaware" }');
SELECT hello(p_name := 'joe', p_location := 'delaware');
