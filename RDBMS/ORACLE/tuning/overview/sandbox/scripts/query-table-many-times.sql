SET LINESIZE 200;

SELECT distinct sid FROM v$mystat;
CALL dbms_session.set_identifier('query-table-many-times');

DECLARE
    throwaway INTEGER;
BEGIN
    FOR i IN 1..200
    LOOP
        SELECT MAX(id)
        INTO throwaway
        FROM simple_table
        WHERE id > i;
    END LOOP;
END;
/

EXIT;