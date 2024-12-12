
## converting from bytea to integers

https://www.postgresql.org/message-id/22aeb499-b1bc-4ec9-9f3b-b9323ea27f92%40mm
```shell
psql 
```

```postgresql
\set e '\'\12\15\107\20\'::bytea'
SELECT
    get_byte(:e,0),
    get_byte(:e,1),
    get_byte(:e,2),
    get_byte(:e,3);
``````