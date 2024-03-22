## UUID

If you want to include timestamp, check ULID
https://blog.tericcabrel.com/discover-ulid-the-sortable-version-of-uuid/
https://github.com/ulid/spec

## gen_random_uuid (default)

```postgresql
CREATE EXTENSION pgcrypto;
```

```postgresql
SELECT gen_random_uuid();
```


### uuid_generate_v1

````postgresql
CREATE EXTENSION "uuid-ossp";
````

https://dba.stackexchange.com/questions/122623/default-value-for-uuid-column-in-postgres

```postgresql
SELECT uuid_generate_v1()
FROM GENERATE_SERIES(1, 100000) AS id;
```

### Performance

100 000: < 1 seconde
1 million: < 10 secondes
3 million: < 30 secondes

````shell
> \time -f "%E" psql --dbname "host=localhost port=5432 user=postgres password=password123" -c "SELECT uuid_generate_v1() FROM GENERATE_SERIES(1, 100000)" > test.csv
0:00.65
> \time -f "%E" psql --dbname "host=localhost port=5432 user=postgres password=password123" -c "SELECT uuid_generate_v1() FROM GENERATE_SERIES(1, 1000000)" > test.csv
0:06.22
> \time -f "%E" psql --dbname "host=localhost port=5432 user=postgres password=password123" -c "SELECT uuid_generate_v1() FROM GENERATE_SERIES(1, 3000000)" > test.csv
0:18.61
````

### random


```postgresql
SELECT MD5(random()::text)::uuid
```

```postgresql
SELECT MD5(random()::text)::uuid
FROM GENERATE_SERIES(1, 100000) AS id;
```