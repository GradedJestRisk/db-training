# Visibility map (VM)

> Each heap relation has a Visibility Map (VM) to keep track of which pages contain only tuples that are known to be visible to all active transactions; it also keeps track of which pages contain only frozen tuples.

> It's stored alongside the main relation data in a separate relation fork, named after the filenode number of the relation, plus a _vm suffix. For example, if the filenode of a relation is 12345, the VM is stored in a file called 12345_vm, in the same directory as the main relation file.

https://www.postgresql.org/docs/current/storage-vm.html


## Peek with pg_visibility

```postgresql
CREATE EXTENSION pg_visibility;
```

Get VM or relation
```postgresql
SELECT
   pg_visibility_map.*    
FROM
    pg_visibility_map('versions') 
```