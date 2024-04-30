CREATE TABLE cacheme(
                        id integer
) WITH (autovacuum_enabled = off);

INSERT INTO cacheme (id)
SELECT id FROM GENERATE_SERIES(1, 10000000) AS id;

INSERT INTO cacheme (id) VALUES(1);

COMMIT;

with recursive chain as (
    select classid, objid, objsubid, conrelid, array[objid] as ids
    from pg_depend d
             join pg_constraint c on c.oid = objid
    where refobjid = ''::regclass and deptype = 'n'
    union all
    select d.classid, d.objid, d.objsubid, c.conrelid, ids || d.objid
    from pg_depend d
             join pg_constraint c on c.oid = objid
             join chain on d.refobjid = chain.conrelid and d.deptype = 'n'
    where d.objid <> all(ids)
)
select pg_describe_object(classid, objid, objsubid), pg_get_constraintdef(objid)
from chain;

