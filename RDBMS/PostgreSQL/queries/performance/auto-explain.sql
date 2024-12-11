
-- Auto explain
-- https://www.postgresql.org/docs/13/auto-explain.html

-- session basis
LOAD 'auto_explain';
SET auto_explain.log_min_duration = 0;
SET auto_explain.log_min_duration = '3s';
SET auto_explain.log_analyze=true;

https://pganalyze.com/docs/explain/setup/amazon_rds/03_review_settings

-- instance basis, add SL 'auto_explain'
select
       setting
from
   pg_settings where name = 'shared_preload_libraries'
;
