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
-- INSERT INTO simple_table VALUES(1);

INSERT INTO simple_table
SELECT  level
FROM    dual
CONNECT BY LEVEL <= 1000000 ;

COMMIT;

EXIT;