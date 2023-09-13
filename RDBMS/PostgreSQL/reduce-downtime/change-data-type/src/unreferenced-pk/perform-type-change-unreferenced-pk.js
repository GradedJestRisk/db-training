// https://tech.coffeemeetsbagel.com/reaching-the-max-limit-for-ids-in-postgres-6d6fa2b1c6ea
const { Pool } = require('pg');

// const readline = require('readline');

const migrateRows = require('./migrate-rows');

const MAX_INTEGER = 2147483627;
const idThatWouldBeRejectedWithInteger = MAX_INTEGER + 1;

const connexion = {
  user: 'postgres',
  host: 'localhost',
  database: 'database',
  port: 5432,
};

const poolConfiguration = {
  ...connexion,
  min: 5,
  max: 10,
  // idleTimeoutMillis: 30000,
  // connectionTimeoutMillis: 20000,
  // keepAlive: true,
  // keepAliveInitialDelayMillis: 1000,
};

const externalUserName = 'activity';

const million = 1000000;
const CHUNK_SIZE = million;

const resetStatistics = async (client) => {
  await client.query('SELECT pg_stat_statements_reset()');
};

const getStatistics = async (client) => {
  const result = await client.query('SELECT * FROM cumulated_statistics');
  return result.rows[0];
};

// function askQuestion(query) {
//   const rl = readline.createInterface({
//     input: process.stdin,
//     output: process.stdout,
//   });
//
//   return new Promise((resolve) =>
//     rl.question(query, (ans) => {
//       rl.close();
//       resolve(ans);
//     })
//   );
// }

const changes = [
  {
    label: 'CHANGE_UNREFERENCED_PK_WITH_TEMPORARY_COLUMN',
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
      console.log('- starting building index concurrently on new_id');
      await client.query('CREATE UNIQUE INDEX CONCURRENTLY idx ON foo(new_id)');
      console.log('- index on new_id has been build concurrently');

      // Feed new_id for each existing row
      console.log(
        `- feeding new_id on existing rows (using ${CHUNK_SIZE}-record size chunks)`
      );

      await migrateRows.migrateFooId(client, CHUNK_SIZE);
      console.log(`- finished feeding new_id on existing rows`);

      // Disable next login
      await client.query(`ALTER USER "${externalUserName}" WITH NOLOGIN`);
      console.log('- user login has been disabled');

      // Terminate established connexion
      await client.query(`SELECT
                            pg_terminate_backend(pid)
                          FROM pg_stat_activity
                          WHERE 1=1
                          AND datname = 'database'
                          AND usename = '${externalUserName}'
                          AND pid <> pg_backend_pid()`);
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

      // TODO: move single client
      // https://node-postgres.com/features/transactions
      // You must use the same client instance for all statements within a transaction.
      // PostgreSQL isolates a transaction to individual clients.
      // This means if you initialize or use transactions with the pool.query method you will have problems.
      // Do not use transactions with the pool.query method.

      await client.query('BEGIN TRANSACTION');
      console.log('- transaction started');

      // Disable migration
      await client.query('DROP TRIGGER trg_foo ON foo');
      await client.query('DROP FUNCTION migrate_id_concurrently');
      console.log('- triggers have been dropped');

      // Migrate remaining rows
      const resultFoo = await client.query(`
        UPDATE foo
        SET new_id = id
        WHERE new_id IS NULL`);

      console.log(
        `- ${resultFoo.rowCount} remaining rows on foo have been migrated`
      );

      // https://stackoverflow.com/questions/9490014/adding-serial-to-existing-column-in-postgres
      await client.query('ALTER SEQUENCE foo_id_seq OWNED BY foo.new_id');
      await client.query('ALTER SEQUENCE foo_id_seq AS BIGINT');
      console.log('- sequence type is now BIGINT');

      await client.query(
        `ALTER TABLE foo ALTER COLUMN new_id SET DEFAULT nextval('foo_id_seq')`
      );
      await client.query('ALTER TABLE foo ALTER COLUMN id DROP DEFAULT');
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

      await client.query(
        `INSERT INTO foo(id) VALUES (${idThatWouldBeRejectedWithInteger})`
      );

      console.log(
        `- INSERT has succeeded with id ${idThatWouldBeRejectedWithInteger}`
      );

      await client.query('COMMIT TRANSACTION');
      console.log('- transaction committed');

      console.log('Closing maintenance window...');
      console.timeEnd();

      ////////// MAINTENANCE WINDOW STOPS HERE ////////////////////////////////
      const statisticsDowntime = await getStatistics(client);
      await resetStatistics(client);

      results.push({
        phase: 'downtime',
        ...statisticsDowntime,
      });

      // await askQuestion(
      //   'Changes are to be reverted, and maintenance window to be closed. You can peek on database, then press Enter to proceed'
      // );
      // await resetStatistics(client);

      // Re-enable login
      await client.query(`ALTER USER "${externalUserName}" WITH LOGIN`);
    },
    revert: async (client) => {
      await client.query(
        `DELETE FROM foo WHERE id = ${idThatWouldBeRejectedWithInteger}`
      );
      await client.query('ALTER TABLE foo DROP CONSTRAINT foo_pkey');
      await client.query('ALTER SEQUENCE foo_id_seq AS INTEGER');
      await client.query('ALTER TABLE foo ALTER COLUMN id TYPE INTEGER');
      await client.query(
        'ALTER TABLE foo ADD CONSTRAINT foo_pkey PRIMARY KEY(id)'
      );
    },
  },
  {
    label: 'CHANGE_UNREFERENCED_PK_IN_PLACE',
    perform: async (client, results) => {
      // Disable next login
      await client.query(`ALTER USER "${externalUserName}" WITH NOLOGIN`);
      console.log('- user login has been disabled');

      // Terminate established connexion
      await client.query(`SELECT
                            pg_terminate_backend(pid)
                          FROM pg_stat_activity
                          WHERE 1=1
                          AND datname = 'database'
                          AND usename = '${externalUserName}'
                          AND pid <> pg_backend_pid()`);

      console.log('- all connexions have been terminated');

      ////////// MAINTENANCE WINDOW STARTS HERE ////////////////////////////////
      console.log('Opening maintenance window...');
      console.time();

      await client.query('BEGIN TRANSACTION');
      console.log('- transaction started');

      await client.query('ALTER TABLE foo ALTER COLUMN id TYPE BIGINT;');
      console.log('- column foo.id has been changed to type BIGINT');

      await client.query('ALTER SEQUENCE foo_id_seq AS BIGINT');
      console.log(
        '- sequence for foo.id table has been changed to type BIGINT'
      );

      await client.query(
        `INSERT INTO foo(id)  VALUES (${idThatWouldBeRejectedWithInteger})`
      );
      console.log(
        `- INSERT has succeeded with id ${idThatWouldBeRejectedWithInteger}`
      );

      await client.query('COMMIT TRANSACTION');
      console.log('- transaction committed');

      console.log('Closing maintenance window...');
      console.timeEnd();

      ////////// MAINTENANCE WINDOW STOPS HERE ////////////////////////////////
      const statisticsDowntime = await getStatistics(client);
      await resetStatistics(client);

      results.push({
        phase: 'downtime',
        ...statisticsDowntime,
      });

      // await askQuestion(
      //   'Changes are to be reverted, and maintenance window to be closed. You can peek on database, then press Enter to proceed'
      // );

      // Re-enable login
      await client.query(`ALTER USER "${externalUserName}" WITH LOGIN`);
    },
    revert: async (client) => {
      await client.query(
        `DELETE FROM foo WHERE id = ${idThatWouldBeRejectedWithInteger}`
      );

      await client.query('ALTER TABLE foo DROP CONSTRAINT foo_pkey');
      await client.query('ALTER SEQUENCE foo_id_seq AS INTEGER');
      await client.query('ALTER TABLE foo ALTER COLUMN id TYPE INTEGER');
      await client.query(
        'ALTER TABLE foo ADD CONSTRAINT foo_pkey PRIMARY KEY(id)'
      );
    },
  },
];

const waitForThatMilliseconds = (delay) =>
  new Promise((resolve) => setTimeout(resolve, delay));

const allowSomeQueryToSlipIn = async () => {
  await waitForThatMilliseconds(1000);
};

(async () => {
  const client = new Pool(poolConfiguration);

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
