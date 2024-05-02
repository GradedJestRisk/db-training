DO $$
DECLARE
 random_value INTEGER;
 sum BIGINT;
BEGIN

--    SET client_min_messages TO NOTICE;

WHILE TRUE LOOP
   SELECT ROUND(random() * 1000000 + 1)
   INTO random_value;

   SELECT SUM(t.code) FROM big_table t WHERE t.id < random_value
   INTO sum;

   END LOOP;

--    RAISE NOTICE 'Sum is %', sum;

END $$;


