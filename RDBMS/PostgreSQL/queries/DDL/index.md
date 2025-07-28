# Index

## covering

`name` fiels will not be used as an index key for search, but its value will be stored in the index for index-only scan
```postgresql
CREATE INDEX covering_index ON table(id) INCLUDE (name);
```

## rename

```postgresql
ALTER INDEX IF EXISTS "answers_bigint_assessmentid_index" RENAME TO "answers_assessmentid_index";
```


