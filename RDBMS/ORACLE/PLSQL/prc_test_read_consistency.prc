CREATE OR REPLACE PROCEDURE prc_test_read_consistency IS

   -- Should     delete node 1, cause delete its 2 childrens
   -- Should NOT delete node 4, cause delete only 1 of its 2 childrens
   CURSOR cur_level_2 IS
      SELECT
         tst.id, tst.id_parent
      FROM
          test_read_consistency tst
      WHERE 1=1
         AND tst.node_level = 2
         AND tst.id         IN (2, 7, 5)
      ORDER BY 
         tst.id;

BEGIN

   --OPEN cur_level_2;

   FOR current_level_2 IN cur_level_2 LOOP

      EXIT WHEN cur_level_2%NOTFOUND;

      -- Delete level 2 node
      DELETE FROM test_read_consistency
      WHERE id = current_level_2.id;

      --COMMIT;

      -- Delete level 1 node if no more level 2 
      DELETE FROM 
         test_read_consistency level_1
      WHERE 1=1
         AND level_1.node_level  =   1
         AND level_1.id          =   current_level_2.id_parent
         AND NOT EXISTS (
            SELECT 1 FROM test_read_consistency level_2
            WHERE level_2.node_level = 2 AND level_2.id_parent = level_1.id);
           
   END LOOP;

	--CLOSE cur_level_2;
   
   COMMIT;

END prc_test_read_consistency;
/
