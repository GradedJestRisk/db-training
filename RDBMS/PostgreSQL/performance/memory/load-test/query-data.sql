DO $$
BEGIN

    FOR i IN 1..100 LOOP
        EXECUTE 'SELECT id FROM table_' || i || ' WHERE id=42';
    END LOOP;

END $$;

