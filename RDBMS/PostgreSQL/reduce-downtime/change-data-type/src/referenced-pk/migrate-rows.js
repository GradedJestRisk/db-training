// https://blog.pilosus.org/posts/2019/12/07/postgresql-update-rows-in-chunks/
const migrateFooId = async (client, chunk_size) => {
  let rowsUpdatedCount = 0;

  do {
    // Removed ORDER BY ID
    const result = await client.query(`WITH rows AS (
          SELECT id
          FROM foo
          WHERE new_id IS NULL
          LIMIT ${chunk_size}
        )
        UPDATE foo
        SET new_id = id
        WHERE EXISTS (SELECT * FROM rows WHERE foo.id = rows.id)`);

    rowsUpdatedCount = result.rowCount;
    process.stdout.write('.');
  } while (rowsUpdatedCount >= chunk_size);
};

const migrateFoobarFooId = async (client, chunk_size) => {
  let rowsUpdatedCount = 0;

  do {
    const result = await client.query(`WITH rows AS (
          SELECT foo_id
          FROM foobar
          WHERE new_foo_id IS NULL
          ORDER BY foo_id
          LIMIT ${chunk_size}
        )
        UPDATE foobar
        SET new_foo_id = foo_id
        WHERE EXISTS (SELECT * FROM rows WHERE foobar.foo_id = rows.foo_id)`);

    rowsUpdatedCount = result.rowCount;
    process.stdout.write('-');
  } while (rowsUpdatedCount >= chunk_size);
};

module.exports = { migrateFooId, migrateFoobarFooId };
