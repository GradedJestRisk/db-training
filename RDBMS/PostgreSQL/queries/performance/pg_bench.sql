-- sudo apt-get install postgresql-contrib

-- Crate sample table
-- pgbench -i -h localhost -U postgres -d database

-- Launch test
-- pgbench -h localhost -U postgres -d database -c10 -t300


-- Get results
select *
from pgbench_history
;

select *
from pgbench_accounts
;

select *
from pgbench_branches
;

select *
from pgbench_tellers
;


