# Restore backup


### Copy dump to container fs

```shell
export DUMP_FILE_PATH=<PATH/FILE_NAME.bak>
docker cp $DUMP_FILE_PATH sqlserver:/dump.bak
# Successfully copied 1.68GB to sqlserver:/dump.bak
```

### Restore dump

#### Using Azure Data Studio

Install GUI
https://learn.microsoft.com/en-us/azure-data-studio/download-azure-data-studio?tabs=linux-install

On database list on the left, right-click "Restore"

### Using command-line

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

### Remove dump from container