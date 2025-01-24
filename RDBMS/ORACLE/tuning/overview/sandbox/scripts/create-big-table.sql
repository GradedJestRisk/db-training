
SELECT distinct sid AS sessionId FROM v$mystat;

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE simple_table';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

CREATE TABLE simple_table (id INTEGER, text VARCHAR2(100));

SET timing ON

DECLARE
    random_string VARCHAR2(100) := 'TYsS5VzPsOFs9MB63KpD4O0KCJUjRmqyJchnxaPOxQokGqxYDcuh3K5VZ2sJC9sOJBoEdSJSR28wbxr71F1NfWQTKzetDa1RCo34';
BEGIN
    FOR i IN 1..10000000
        LOOP
--             INSERT INTO simple_table (id, text) VALUES(i, dbms_random.string('p',100));
            INSERT INTO simple_table (id, text) VALUES(i, random_string);
        END LOOP;
END;
/

SELECT prev_sql_id AS sqlId
FROM v$session
WHERE sid=sys_context('userenv','sid');

COMMIT;

CALL dbms_stats.gather_table_stats ( null, 'simple_table' );

SELECT TO_CHAR(bytes/1024/1024) || 'MB' AS table_size
FROM user_segments
WHERE segment_name = UPPER('simple_table');

SELECT num_rows
FROM user_tables
WHERE table_name = UPPER('simple_table');

EXIT;