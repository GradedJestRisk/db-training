CREATE OR REPLACE PROCEDURE prc_test_bulk_limit IS

   TYPE typ_tab_object IS TABLE OF all_objects%ROWTYPE;

   tab_object typ_tab_object;

   CURSOR cur_objects IS
      SELECT 
         *
      FROM
          all_objects;

   fetch_count          BINARY_INTEGER;
   fetch_size  CONSTANT BINARY_INTEGER := 1000;

   table_truncate CONSTANT VARCHAR2(2000) := 'TRUNCATE TABLE test_objects';

   source_table_count  BINARY_INTEGER;
   target_table_count  BINARY_INTEGER;

   start_date           DATE;
   max_duration_minutes BINARY_INTEGER;
   max_end_date         DATE;

   actual_duration DATE;

   PROCEDURE print_hour_from_date (
                  content         VARCHAR2,   
                  date_to_convert DATE) 
   IS
   BEGIN
     dbms_output.put_line( content || ' ' ||  TO_CHAR(date_to_convert,'HH24:MI-SS') );
   END;
   
BEGIN

   start_date           := SYSDATE;
   max_duration_minutes := '1';
   max_end_date         := start_date + NUMTODSINTERVAL(max_duration_minutes, 'MINUTE');

   print_hour_from_date('Start time: ',        start_date);
   print_hour_from_date('Expected end time: ', max_end_date);

   -- 'CREATE TABLE test_objects AS SELECT * FROM all_objects WHERE 1=0';

   EXECUTE IMMEDIATE(table_truncate);

   fetch_count := 0;

   OPEN cur_objects;

   <<FETCH_OBJECTS_LOOP>>
   LOOP

      fetch_count := fetch_count + 1;
      dbms_output.put_line('fetch count: ' || fetch_count);
      print_hour_from_date('Actual time in fetch: ', SYSDATE);
      
      FETCH cur_objects BULK COLLECT INTO tab_object LIMIT fetch_size;

      -- No action before leaving LOOP 
      -- EXIT WHEN (tab_object.COUNT = 0 OR SYSDATE > max_end_date);   

      -- Some action before leaving LOOP 
      IF tab_object.COUNT = 0 OR SYSDATE > max_end_date THEN
         dbms_output.put_line('Go out of the loop');
         EXIT;
      END IF;

      dbms_output.put_line('Copy one time');
      -- If exception is raised, stop FORALL and raise
      FORALL indx IN tab_object.FIRST .. tab_object.LAST

         INSERT INTO 
            test_objects
          VALUES
            tab_object (indx);

      dbms_output.put_line('Copy another time');
      -- If exception is raised, stop FORALL and raise
      FORALL indx IN tab_object.FIRST .. tab_object.LAST

         INSERT INTO 
            test_objects
          VALUES
            tab_object (indx);

     -- Time-consuming query her
     SELECT COUNT(1) INTO source_table_count FROM filiere; 

     dbms_output.put_line('committing...');
     dbms_output.put_line('');
     COMMIT;
           
   END LOOP;

	CLOSE cur_objects;

   dbms_output.put_line('');

   SELECT COUNT(1) INTO source_table_count FROM all_objects ;
   dbms_output.put_line('Source table count: ' || source_table_count);

   SELECT COUNT(1) INTO target_table_count FROM test_objects ;
   dbms_output.put_line('Target table count: ' || target_table_count);

   IF target_table_count = 2 * source_table_count THEN
      dbms_output.put_line('Copy OK');
   ELSE
      dbms_output.put_line('Copy KO');
   END IF;


   print_hour_from_date('Actual end time: ', SYSDATE);
   
   dbms_output.put_line('Actual duration (s): '  || ( SYSDATE - start_date) * 1440 * 60);
   dbms_output.put_line(NUMTODSINTERVAL( SYSDATE - start_date, 'DAY'));
--   print_hour_from_date('Actual duration: ', actual_duration);



      -- If exception is raised, go trough
      /*
      BEGIN

         FORALL indx IN 1 .. tab_object.COUNT SAVE EXCEPTIONS

            INSERT INTO test_objects
            VALUES
                tab_object (indx);

      EXCEPTION

         WHEN OTHERS THEN

            IF SQLCODE = -24381
            THEN

               FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT
               LOOP
                  DBMS_OUTPUT.put_line (
                        SQL%BULK_EXCEPTIONS (indx).ERROR_INDEX 
                     || ': '
                     || SQL%BULK_EXCEPTIONS (indx).ERROR_CODE);
               END LOOP;

            ELSE
               RAISE;
            END IF;
      END;
      */


END prc_test_bulk_limit;
/
