SET LINESIZE 200;

SELECT distinct sid FROM v$mystat;

DECLARE
    throwaway INTEGER;
BEGIN
    FOR i IN 1..2000
    LOOP
        SELECT MAX(id)
        INTO throwaway
        FROM simple_table
        WHERE id > i;
    END LOOP;
END;
/

EXIT;