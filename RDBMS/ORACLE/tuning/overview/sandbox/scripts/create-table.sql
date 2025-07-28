BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE simple_table';
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE != -942 THEN
                RAISE;
            END IF;
    END;
    /

    CREATE TABLE simple_table (id INTEGER);
    -- CREATE TABLE simple_table (id INTEGER, text VARCHAR2(100));

    INSERT INTO simple_table VALUES(1);

    BEGIN
        FOR i IN 1..2000000
        LOOP
            INSERT INTO simple_table VALUES(i);
        END LOOP;
    END;
    /

    COMMIT;

    CALL dbms_stats.gather_table_stats ( null, 'simple_table' );

    SELECT TO_CHAR(bytes/1024/1024) || 'MB' AS table_size
    FROM user_segments
    WHERE segment_name = UPPER('simple_table');

EXIT;