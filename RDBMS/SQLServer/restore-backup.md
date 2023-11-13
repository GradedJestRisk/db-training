# Setup
https://learn.microsoft.com/fr-fr/sql/linux/quickstart-install-connect-docker?view=sql-server-ver16&pivots=cs1-bash

## Get image
```shell
sudo docker pull mcr.microsoft.com/mssql/server:2022-latest
```

## Start instance

Start
```
docker run \
   --env "ACCEPT_EULA=Y" --env "MSSQL_SA_PASSWORD=<YourStrong@Passw0rd>" \
   --publish 1433:1433 --name sqlserver --hostname sqlserver \
   --detach \
   mcr.microsoft.com/mssql/server:2022-latest
```

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

Enter <YourStrong@Passw0rd>

```sql
SELECT name FROM sys.databases;
```

Change password (must be 8 characters long, check logs)
=> Not working unfortunately
https://learn.microsoft.com/en-us/sql/t-sql/statements/alter-login-transact-sql?view=sql-server-ver16
```
ALTER LOGIN SA WITH PASSWORD = 'Password123';
GO
```

### Using sqlcmd

Install CLI

```
sqlcmd -S localhost -U SA -No
```

Enter <YourStrong@Passw0rd>

```sql
SELECT name FROM sys.databases;
GO
```


### Using another tool

User: SA
Port : 1433

## Create a database
```sql
CREATE DATABASE test;
USE test;
CREATE TABLE inventory (id INT, name NVARCHAR(50), quantity INT);
INSERT INTO inventory VALUES (1, 'banana', 150); INSERT INTO Inventory VALUES (2, 'orange', 154);
SELECT * FROM inventory WHERE quantity > 152;
GO
```

## Import data


### Copy dump to container

```shell
docker cp /tmp/test.bak sqlserver:/test.bak
```

### Restore using Azure Data Studio
Install GUI
https://learn.microsoft.com/en-us/azure-data-studio/download-azure-data-studio?tabs=linux-install

On database list on the left, right-click "Restore"

### Restore using command-line

https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-migrate-restore-database?view=sql-server-ver16

Check content
https://www.sqlshack.com/use-of-the-restore-filelistonly-command-in-sql-server/
```sql
RESTORE FILELISTONLY FROM DISK =  '/test.bak'
GO
```

Import
```sql
RESTORE DATABASE INT01_SAM_CONF FROM DISK = '/test.bak'
WITH MOVE 'INT01_SAM_CONF' TO '/var/opt/mssql/data/INT01_SAM_CONF.mdf',
MOVE 'INT01_SAM_CONF_Log' TO '/var/opt/mssql/data/INT01_SAM_CONF_Log.ldf'
GO
```

## Remove container

```shell
docker container stop sqlserver
docker container remove sqlserver
```