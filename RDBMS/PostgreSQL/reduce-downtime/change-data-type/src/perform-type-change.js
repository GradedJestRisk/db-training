// https://tech.coffeemeetsbagel.com/reaching-the-max-limit-for-ids-in-postgres-6d6fa2b1c6ea
const { Client } = require('pg');

const connexion = {
  user: 'postgres',
  host: 'localhost',
  database: 'database',
  port: 5432,
};

const externalUserName = 'activity';

const CHUNK_SIZE = 100000;

const resetStatistics = async (client) => {
  await client.query('SELECT pg_stat_statements_reset()');
};

const getStatistics = async (client) => {
  const cumulatedQuery =
    'SELECT' +
    '    TRUNC(SUM(stt.total_exec_time))                  execution_time_ms ' +
    '   ,pg_size_pretty(SUM(wal_bytes))                   disk_wal_size ' +
    '   ,pg_size_pretty(SUM(temp_blks_written) * 8192)    disk_temp_size ' +
    'FROM pg_stat_statements stt ' +
    '    INNER JOIN pg_authid usr ON usr.oid = stt.userid ' +
    '    INNER JOIN pg_database db ON db.oid = stt.dbid ' +
    "WHERE db.datname = 'database' ";
  const result = await client.query(cumulatedQuery);
  return result.rows[0];
};

const changes = [
  // {
  //   label: 'CHANGE_IN_PLACE',
  //   perform: async (client) => {
  //     await client.query('ALTER TABLE foo ALTER COLUMN value TYPE BIGINT');
  //   },
  //   revert: async (client) => {
  //     await client.query('ALTER TABLE foo ALTER COLUMN value TYPE INTEGER');
  //   },
  // },
  // {
  //   label: 'CHANGE_IN_PLACE_PRIMARY_KEY',
  //   perform: async (client) => {
  //     // https://www.postgresql.org/docs/current/sql-altersequence.html
  //     await client.query('ALTER SEQUENCE foo_id_seq AS BIGINT');
  //     await client.query('ALTER TABLE foo ALTER COLUMN id TYPE BIGINT');
  //   },
  //   revert: async (client) => {
  //     await client.query('ALTER TABLE foo DROP CONSTRAINT foo_pkey');
  //     await client.query('ALTER SEQUENCE foo_id_seq AS INTEGER');
  //     await client.query('ALTER TABLE foo ALTER COLUMN id TYPE INTEGER');
  //     await client.query(
  //       'ALTER TABLE foo ADD CONSTRAINT foo_pkey PRIMARY KEY(id)'
  //     );
  //   },
  // },
  // {
  //   label: 'CHANGE_IN_PLACE_PRIMARY_KEY_CONSTRAINT',
  //   perform: async (client) => {
  //     await client.query('ALTER TABLE foo DROP CONSTRAINT foo_pkey');
  //     await client.query('ALTER SEQUENCE foo_id_seq AS BIGINT');
  //     await client.query('ALTER TABLE foo ALTER COLUMN id TYPE BIGINT');
  //     await client.query(
  //       'ALTER TABLE foo ADD CONSTRAINT foo_pkey PRIMARY KEY(id)'
  //     );
  //   },
  //   revert: async (client) => {
  //     await client.query('ALTER TABLE foo DROP CONSTRAINT foo_pkey');
  //     await client.query('ALTER SEQUENCE foo_id_seq AS INTEGER');
  //     await client.query('ALTER TABLE foo ALTER COLUMN id TYPE INTEGER');
  //     await client.query(
  //       'ALTER TABLE foo ADD CONSTRAINT foo_pkey PRIMARY KEY(id)'
  //     );
  //   },
  // },
  {
    label: 'CHANGE_WITH_TEMPORARY_COLUMN_PRIMARY_KEY_CONSTRAINT',
    perform: async (client, results) => {
      await resetStatistics(client);

      console.log('Preparing for maintenance window:');

      await client.query('ALTER TABLE foo ADD COLUMN new_id BIGINT');
      console.log('- new_id column has ben created');

      // Feed new_id for each new inserted row
      await client.query(`CREATE OR REPLACE FUNCTION migrate_id_concurrently()
                          RETURNS TRIGGER AS
                          $$
                          BEGIN
                              NEW.new_id = NEW.id::BIGINT;
                              RETURN NEW;
                          END
                          $$ LANGUAGE plpgsql;`);

      await client.query(`CREATE TRIGGER trg_foo
                          BEFORE INSERT ON foo
                          FOR EACH ROW
                          EXECUTE PROCEDURE migrate_id_concurrently();`);
      console.log(
        '- trigger has been created, so that each new record in table will have new_id filled'
      );

      // Prepare Primary key unique constraint
      // https://www.2ndquadrant.com/en/blog/create-index-concurrently/
      // https://dba.stackexchange.com/questions/131945/detect-when-a-create-index-concurrently-is-finished-in-postgresql
      await client.query('CREATE UNIQUE INDEX CONCURRENTLY idx ON foo(new_id)');
      console.log('- index on new_id has been build concurrently');

      let rowsUpdatedCount = 0;

      // Feed new_id for each existing row
      console.log(
        `- feeding new_id on existing rows (using ${CHUNK_SIZE}-record size chunks)`
      );

      do {
        // https://blog.pilosus.org/posts/2019/12/07/postgresql-update-rows-in-chunks/
        const result = await client.query(`WITH rows AS (
          SELECT id
          FROM foo
          WHERE new_id IS NULL
          ORDER BY id
          LIMIT ${CHUNK_SIZE}
        )
        UPDATE foo
        SET new_id = id
        WHERE EXISTS (SELECT * FROM rows WHERE foo.id = rows.id)`);

        rowsUpdatedCount = result.rowCount;
        process.stdout.write('.');
      } while (rowsUpdatedCount >= CHUNK_SIZE);

      // Disable next login
      await client.query(`ALTER USER "${externalUserName}" WITH NOLOGIN`);
      console.log('- user login has been disabled');

      // Terminate established connexion
      await client.query(`SELECT pg_terminate_backend(pid) FROM pg_stat_activity
                          WHERE datname = 'database' AND pid <> pg_backend_pid()`);
      console.log('- all connexions have been terminated');

      const statisticsBeforeDowntime = await getStatistics(client);
      await resetStatistics(client);

      results.push({
        phase: 'beforeDowntime',
        ...statisticsBeforeDowntime,
      });

      ////////// MAINTENANCE WINDOW STARTS HERE ////////////////////////////////
      console.log('Opening maintenance window...');
      console.time();

      // Disable migration
      await client.query('DROP TRIGGER trg_foo ON foo');
      await client.query('DROP FUNCTION migrate_id_concurrently');
      console.log('- trigger has been dropped');

      // Migrate remaining rows
      const result = await client.query(`
        UPDATE foo
        SET new_id = id
        WHERE new_id IS NULL`);

      console.log(`- ${result.rowCount} remaining rows have been migrated`);

      // https://stackoverflow.com/questions/9490014/adding-serial-to-existing-column-in-postgres
      await client.query('ALTER SEQUENCE foo_id_seq OWNED BY foo.new_id');
      await client.query('ALTER SEQUENCE foo_id_seq AS BIGINT');
      console.log('- sequence type is now BIGINT');

      await client.query(
        `ALTER TABLE foo ALTER COLUMN new_id SET DEFAULT nextval('foo_id_seq')`
      );
      await client.query('ALTER TABLE foo ALTER COLUMN id DROP DEFAULT');
      // check with \d foo_id_seq;
      console.log('- sequence is now used by new_id');

      await client.query('ALTER TABLE foo DROP CONSTRAINT foo_pkey');
      // Enable PK on new_id before dropping id, in case something is wrong
      console.log('- primary key on id has been dropped');
      await client.query(
        'ALTER TABLE foo ADD CONSTRAINT foo_pkey PRIMARY KEY USING INDEX idx'
      );
      console.log('- primary key on new_id has been created');

      await client.query('ALTER TABLE foo DROP COLUMN id');
      console.log('- column id has been dropped');

      await client.query('ALTER TABLE foo RENAME COLUMN new_id TO id');
      console.log('- column new_id has been renamed to id');

      console.log('Closing maintenance window...');
      console.timeEnd();

      ////////// MAINTENANCE WINDOW STOPS HERE ////////////////////////////////
      const statisticsDowntime = await getStatistics(client);
      await resetStatistics(client);

      results.push({
        phase: 'downtime',
        ...statisticsDowntime,
      });

      // Re-enable login
      await client.query(`ALTER USER "${externalUserName}" WITH LOGIN`);
    },
    revert: async (client) => {
      await client.query('ALTER TABLE foo DROP CONSTRAINT foo_pkey');
      await client.query('ALTER SEQUENCE foo_id_seq AS INTEGER');
      await client.query('ALTER TABLE foo ALTER COLUMN id TYPE INTEGER');
      await client.query(
        'ALTER TABLE foo ADD CONSTRAINT foo_pkey PRIMARY KEY(id)'
      );
    },
  },
  // {
  //   label: 'CHANGE_IN_PLACE_FOREIGN_KEY_REFERENCED',
  //   perform: async (client) => {
  //     await client.query(
  //       'ALTER TABLE foo ALTER COLUMN referenced_value TYPE BIGINT'
  //     );
  //   },
  //   revert: async (client) => {
  //     await client.query('ALTER TABLE bar ALTER COLUMN value_foo TYPE INTEGER');
  //   },
  // },
  // {
  //   label: 'CHANGE_IN_PLACE_FOREIGN_KEY_REFERENCING',
  //   perform: async (client) => {
  //     await client.query('ALTER TABLE bar ALTER COLUMN value_foo TYPE BIGINT');
  //   },
  //   revert: async (client) => {
  //     await client.query('ALTER TABLE bar ALTER COLUMN value_foo TYPE INTEGER');
  //   },
  // },
];

const waitForThatMilliseconds = (delay) =>
  new Promise((resolve) => setTimeout(resolve, delay));

const allowSomeQueryToSlipIn = async () => {
  await waitForThatMilliseconds(1000);
};

(async () => {
  const client = new Client(connexion);

  client.connect();

  await allowSomeQueryToSlipIn();

  for (const change of changes) {
    const results = [];

    console.log(`👷 Changing type with ${change.label} 🕗`);
    await change.perform(client, results);
    console.log(`Type changed ✔`);

    console.log(`⚖ Statistics:`);
    console.log(results);

    console.log('Reverting 🕗');
    await change.revert(client);
    console.log(`Reverted ✔`);
  }

  client.end();
})();
