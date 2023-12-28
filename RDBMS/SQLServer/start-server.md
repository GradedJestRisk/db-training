# Start server
https://learn.microsoft.com/fr-fr/sql/linux/quickstart-install-connect-docker?view=sql-server-ver16&pivots=cs1-bash

## Start container

### Quick : without compose (docker run)

Start
```
docker run \
   --env "ACCEPT_EULA=Y" --env "MSSQL_SA_PASSWORD=<YourStrong@Passw0rd>" \
   --publish 1433:1433 --name sqlserver --hostname sqlserver \
   --detach \
   mcr.microsoft.com/mssql/server:2022-latest
```

### Longer: with compose and persist data

We need to run the container as root to define custom volumes.
Other solutions [here](https://stackoverflow.com/questions/65601077/unable-to-run-sql-server-2019-docker-with-volumes-and-get-error-setup-failed-co.

Create folder to store data
```shell
mkdir --parents ~/.docker-data/sqlserver
```
If you use another path, update this line [compose](./compose.yaml) file.
```shell
device: ~/.docker-data/sqlserver
```

Start the container
```
docker compose up --detach
```
Connect and [create data](#create-a-database)

Stop the container, remove container and volume
```
docker compose down
docker remove sqlserver
docker volume remove sqlserver_db_data
```

Check files are still there
```shell
ls ~/.docker-data/sqlserver
```

Start it up again
```
docker compose up --detach
```

Check the data is still here
```sql
SELECT * FROM test;
```


## Check it is alive
Check it is running
```
docker container ps
docker container logs sqlserver
```

## Connect to instance
https://stackoverflow.com/questions/4944165/can-you-make-sqlcmd-immediately-run-each-statement-in-a-script-without-the-use-o

### Using docker
```
docker exec --interactive --tty sqlserver "bash"
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA
```

Enter `<YourStrong@Passw0rd>`

You'll get a prompt
```shell
1>
```

### Using sqlcmd

Install CLI
```
sqlcmd -S localhost -U SA -No
```

Enter `<YourStrong@Passw0rd>`

You'll get a prompt
```shell
1>
```

Get the current database
```sql
SELECT name FROM sys.databases;
GO
```

### Using another tool

Connection string is
```
jdbc:sqlserver://localhost:1433;database=master
```

| Property | Value     |
|:---------|-----------|
| user     | SA        |
| port     | 1433      |
| host     | localhost |
| database | master    |


## Create a database, table and records

```sql
CREATE DATABASE test;
USE test;
CREATE TABLE inventory (id INT, name NVARCHAR(50), quantity INT);
INSERT INTO inventory VALUES (1, 'banana', 150); INSERT INTO Inventory VALUES (2, 'orange', 154);
SELECT * FROM inventory WHERE quantity > 152;
GO
```

## Remove container

```shell
docker container stop sqlserver
docker container remove sqlserver
``