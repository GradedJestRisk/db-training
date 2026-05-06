# Copy

https://www.postgresql.org/docs/current/sql-copy.html

## Static

Create file
```shell
export DATA_FILE_PATH=/tmp/people.csv
vi $DATA_FILE_PATH
```

Feed it
```csv
first_name;last_name
john;ford
mary;shelley
```

Create target table
```postgresql
DROP TABLE people;
CREATE TABLE people (
    first_name TEXT,
    last_name TEXT
);
```

Load data from file
```
\COPY people FROM '/tmp/people.csv'
WITH (DELIMITER ';', FORMAT CSV, ENCODING 'UTF-8', HEADER ON);
```

## STDIN

Create file
```shell
export DATA_FILE_PATH=/tmp/people.csv
vi $DATA_FILE_PATH
```

Feed it
```csv
first_name;last_name
john;ford
mary;shelley
```

Create target table
```postgresql
DROP TABLE people;
CREATE TABLE people (
    first_name TEXT,
    last_name TEXT
);
```

Load data from stdin
```
cat  $DATA_FILE_PATH | \
psql --dbname "host=db-ptm-integration port=5497 dbname=postgres user=integration password=integration" --command="COPY people FROM STDIN WITH (DELIMITER ';', FORMAT CSV, ENCODING 'UTF-8', HEADER ON)"
```



## STDIN with UUID

### First try

Create file
```shell
export DATA_FILE_PATH=/tmp/people.csv
vi $DATA_FILE_PATH
```

Feed it
```csv
first_name;last_name
john;ford
mary;shelley
```

Create target table
```postgresql
DROP TABLE people;
CREATE TABLE people (
    id uuid,
    first_name TEXT,
    last_name TEXT
);
```

Load data from stdin
```shell
sed 's/$/;MD5(random()::text)::uuid/' $DATA_FILE_PATH | \
psql --dbname "host=db-ptm-integration port=5497 dbname=postgres user=integration password=integration" --command="COPY people(first_name,last_name, id) FROM STDIN WITH (DELIMITER ';', FORMAT CSV, ENCODING 'UTF-8', HEADER ON)"
```

It will fail
````shell
ERROR:  invalid input syntax for type uuid: "MD5(random()::text)::uuid"
CONTEXT:  COPY people, line 2, column id: "MD5(random()::text)::uuid"
````

### Second try

Generate UUIDs locally
```shell
export BUFFER_FILE_PATH=/tmp/people-without-header.csv
export TARGET_FILE_PATH=/tmp/people-with-ids.csv
tail -n +2 $DATA_FILE_PATH > $BUFFER_FILE_PATH
sed 's/.*/uuidgen/e' $BUFFER_FILE_PATH | paste -d ";" - $BUFFER_FILE_PATH > $TARGET_FILE_PATH
head $TARGET_FILE_PATH
```

You'll get
```shell
fb375783-d523-4778-912d-a7a842aca60d;john;ford
16c1b683-3599-4c2a-9690-ca7dd312e122;mary;shelley
```

You can now load it

Load data from stdin
```shell
cat $TARGET_FILE_PATH | \
psql --dbname "host=db-ptm-integration port=5497 dbname=postgres user=integration password=integration" --command="COPY people FROM STDIN WITH (DELIMITER ';', FORMAT CSV, ENCODING 'UTF-8', HEADER OFF)"
```

## STDIN with default

Create target table
```postgresql
DROP TABLE people;
CREATE TABLE people (
    id uuid,
    first_name TEXT,
    last_name TEXT
);
```

Add UUID
```postgresql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
ALTER TABLE people ALTER COLUMN id SET DEFAULT uuid_generate_v1()
```

Load data from stdin
```shell
cat $DATA_FILE_PATH | \
psql --dbname "host=localhost port=5432 user=postgres password=password123" --command="COPY people(first_name,last_name) FROM STDIN WITH (DELIMITER ';', FORMAT CSV, ENCODING 'UTF-8', HEADER ON)"
```

Then drop
```postgresql
ALTER TABLE people ALTER COLUMN id DROP DEFAULT;
```

Then drop
```postgresql
SELECT * FROM people;
```

## Binary

The following will not work. 

It is designed do read data written by PG in its custom format.
https://www.postgresql.org/docs/current/sql-copy.html#SQL-COPY-FILE-FORMATS

You should use `lo_import` functions, which are cumbersome. 
[Reference](https://postgis.us/presentations/PGOpen2018_data_loading.pdf)


Create target table
```postgresql
DROP TABLE file;

CREATE TABLE file (
    content BYTEA
);
```

Create file
```shell
export DATA_FILE_PATH="./hello-world.jpg"
curl --output $DATA_FILE_PATH "https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/Hello_World_Brian_Kernighan_1978.jpg/330px-Hello_World_Brian_Kernighan_1978.jpg"
```

Import it 
```shell
cat $DATA_FILE_PATH | \
psql --dbname $CONNECTION_STRING  \ 
     --command="COPY file(content) FROM STDIN WITH (FORMAT BINARY)"
```

You will get an error
```text
ERROR:  invalid byte sequence for encoding "UTF8": 0xff
invalid command \���v���:Na8���
invalid command \A�
ERROR:  invalid byte sequence for encoding "UTF8": 0xed 0x9b 0x70
zsh: command not found: --command=COPY file(content) FROM STDIN WITH (FORMAT BINARY)
```
