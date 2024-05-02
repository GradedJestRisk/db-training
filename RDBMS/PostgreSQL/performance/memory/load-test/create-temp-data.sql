DO $$
BEGIN

    FOR i IN 1..100 LOOP
            EXECUTE 'CREATE TEMPORARY TABLE temp_table_' || i || ' (id INTEGER PRIMARY KEY, data TEXT)';
            EXECUTE 'INSERT INTO temp_table_' || i || ' (id, data) VALUES ( generate_series(1,1000000,1), generate_series(1,1000000,1)::TEXT);';
        END LOOP;

END $$;