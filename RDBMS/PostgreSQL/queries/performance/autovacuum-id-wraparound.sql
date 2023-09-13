-- https://www.postgresql.org/docs/13/sql-vacuum.html

select relnamespace, relname, relfrozenxid
from pg_class
where relkind = 'r'
and relnamespace = 2200
--order by relfrozenxid::integer
;