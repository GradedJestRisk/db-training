# Install 

## Install Postgres pl-sh and NodeJS

Hard way
- install using official instructions [here](https://github.com/petere/plsh)
- install NodeJS

Easy way: leverage Docker and use a custom image
````shell
docker run --detach --env POSTGRES_HOST_AUTH_METHOD=trust --publish 5432:5432 --name plsh_nodejs gradedjestrisk/plsh-nodejs:13
````
## Compile pg-psql source
Compile the [wrapper](https://github.com/GradedJestRisk/db-training/tree/master/RDBMS/PostgreSQL/testing/js-shell/pl-pgsql/hello_shell_node.sql)

## Install nodeJs component 

Copy the component
````shell
docker cp execute.js postgres_sh:/tmp/execute.js
docker cp package.json postgres_sh:/tmp/package.json
````

Install dependencies
````
docker exec  -it plsh_nodejs  bash
cd /tmp
npm install
````

# Test
```` shell
SELECT hello_shell_node( p_name:='bill', p_location:='masschussets' );
```` 


