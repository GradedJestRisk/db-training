# MVCC

## Lexicon

https://www.postgresql.org/docs/current/datatype-oid.html

### Transaction ID (`xid`)
> Another identifier type used by the system is xid, or transaction (abbreviated xact) identifier. This is the data type of the system columns xmin and xmax. Transaction identifiers are 32-bit quantities.

### Tuple/row Id (`ctid`)
> A final identifier type used by the system is tid, or tuple identifier (row identifier). This is the data type of the system column ctid. A tuple ID is a pair (block number, tuple index within block) that identifies the physical location of the row within its table.

### Command Id (`cid`)
> A third identifier type used by the system is cid, or command identifier. This is the data type of the system columns cmin and cmax. Command identifiers are also 32-bit quantities.

## In a nutshell

In MVCC, each write operation (INSERT, UPDATE, DELETE) creates a new version of a data item while retaining the old version. When a transaction reads a data item, the system selects one of the versions to ensure isolation of the individual transaction.

The main advantage of MVCC is that 
> readers don’t block writers, and writers don’t block readers.

When writing a new version of a data item, PostgreSQL:
- add a new data item into the relevant table page;
- does NOT delete the previous versions.

When writing a new data item, Oracle:
- write the old version of the item to the rollback segment;
- overwrite the data item with new values in the data area.

https://www.interdb.jp/pg/pgsql05.html

