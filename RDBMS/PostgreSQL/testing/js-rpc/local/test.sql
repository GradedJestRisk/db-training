SELECT call_rpc(p_function := 'hello', p_payload := '{ "name": "joe", "location" : "delaware" }');
SELECT hello(p_name := 'joe', p_location := 'delaware');
