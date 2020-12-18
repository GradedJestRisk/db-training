-- Build custom PL/SH + NodeJS docker image
curl --o Dockerfile https://github.com/GradedJestRisk/db-training/tree/master/RDBMS/PostgreSQL/extension/shell/Dockefile
docker build --tag gradedjestrisk/plsh-nodejs:13 .
docker push gradedjestrisk/plsh-nodejs:13

-- Use custom PL/SH + NodeJS docker image
docker rm plsh-nodejs
docker run --detach --env POSTGRES_HOST_AUTH_METHOD=trust --publish 5432:5432 --name plsh-nodejs gradedjestrisk/plsh-nodejs:13

-- From standard Pl/SH image
curl --o Dockerfile https://github.com/GradedJestRisk/db-training/tree/master/RDBMS/PostgreSQL/extension/shell/Dockefile
docker build --tag plsh:latest .
docker run --detach --env POSTGRES_HOST_AUTH_METHOD=trust --publish 5432:5432 --name postgres_sh plsh:latest
docker start postgres_sh
psql postgres://postgres@localhost


CREATE EXTENSION IF NOT EXISTS plsh;

-- List current directory
SELECT where_am_i();

-- Read arg, write in stdout
SELECT * FROM hello_shell(who:='world') value;

--SELECT split_part(value,'\n',1) FROM hello_shell(who:='world') value;

-- Node through shell

-- docker exec  -it postgres_sh  bash
-- docker cp execute.js postgres_sh:/tmp/execute.js
-- docker cp package.json postgres_sh:/tmp/package.json
-- apk add --update nodejs npm
-- npm install
-- ./execute.js --function hello --name john --location delaware


SELECT hello_shell_node( p_name:='bill', p_location:='masschussets' );