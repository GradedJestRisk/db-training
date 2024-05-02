DO $$
BEGIN
    FOR i IN 1..100 LOOP
        EXECUTE 'SELECT SUM(code) FROM table_' || i;
    END LOOP;
END $$;

