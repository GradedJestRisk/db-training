DO $$
BEGIN
    FOR i IN 1..100 LOOP
        EXECUTE 'SELECT SUM(data::INTEGER) FROM temp_table_' || i;
    END LOOP;
END $$;

