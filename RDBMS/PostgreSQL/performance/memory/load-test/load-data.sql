DO $$
BEGIN

    FOR i IN 1..100 LOOP
            EXECUTE 'DROP TABLE IF EXISTS table_' || i;
            EXECUTE 'CREATE TABLE table_' || i || ' (id INTEGER PRIMARY KEY, code INTEGER)';
            EXECUTE 'INSERT INTO table_' || i || ' (id,code) SELECT id,id FROM GENERATE_SERIES(1, 100000) AS id;';
        END LOOP;

END $$;