# Install Postgres psql-http
Install using;
- official instructions [here](https://github.com/pramsey/pgsql-http) 
- or detailed instructions leveraging Docker [here](http://github.com/GradedJestRisk/db-training/blob/master/RDBMS/PostgreSQL/queries/extension/http/http.sql)

# Compile local pg-psql source
Compile:
- the [wrapper](http://github.com/GradedJestRisk/db-training/blob/master/RDBMS/PostgreSQL/testing/js-rpc/local/hello.sql)
- the [RPC bridge](http://github.com/GradedJestRisk/db-training/blob/master/RDBMS/PostgreSQL/testing/js-rpc/local/rpc.sql)

# Start remote server
I've not been able to connect to local API [ (unsolved issue) ](https://github.com/pramsey/pgsql-http/issues/117).
So I used a [PaaS](https://scalingo.com/), as Procfile suggests, but can you can try it locally.

## Check local
```` shell
-- Local
curl --header "Content-Type: application/json" \
     --request PUT \
     --data '{"name":"john","location":"delaware"}' \
    localhost:3000/hello
````

## Check remote
```` shell
curl --header "Content-Type: application/json" \
     --request PUT \
     --data '{"name":"john","location":"delaware"}' \
    https://hello-scalingo.osc-fr1.scalingo.io/hello
```` 

# Test
```` sql
SELECT call_rpc(p_function := 'hello', p_payload := '{ "name": "joe", "location" : "delaware" }');
SELECT hello(p_name := 'joe', p_location := 'delaware');
```` 
