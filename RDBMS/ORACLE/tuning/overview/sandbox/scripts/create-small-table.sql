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

INSERT INTO simple_table VALUES(1);

BEGIN
    FOR i IN 1..1000
    LOOP
        INSERT INTO simple_table VALUES(i);
    END LOOP;
END;
/

COMMIT;

EXIT;