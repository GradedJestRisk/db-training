// https://tech.coffeemeetsbagel.com/reaching-the-max-limit-for-ids-in-postgres-6d6fa2b1c6ea
const { Client } = require('pg');

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
  {
    label: 'CHANGE_IN_PLACE',
    perform: async (client) => {
      await client.query('ALTER TABLE foo ALTER COLUMN value TYPE BIGINT');
    },
    revert: async (client) => {
      await client.query('ALTER TABLE foo ALTER COLUMN value TYPE INTEGER');
    },
  },
  {
    label: 'CHANGE_IN_PLACE_PRIMARY_KEY',
    perform: async (client) => {
      // https://www.postgresql.org/docs/current/sql-altersequence.html
      await client.query('ALTER SEQUENCE foo_id_seq AS BIGINT');
      await client.query('ALTER TABLE foo ALTER COLUMN id TYPE BIGINT');
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
  {
    label: 'CHANGE_IN_PLACE_PRIMARY_KEY_CONSTRAINT',
    perform: async (client) => {
      await client.query('ALTER TABLE foo DROP CONSTRAINT foo_pkey');
      await client.query('ALTER SEQUENCE foo_id_seq AS BIGINT');
      await client.query('ALTER TABLE foo ALTER COLUMN id TYPE BIGINT');
      await client.query(
        'ALTER TABLE foo ADD CONSTRAINT foo_pkey PRIMARY KEY(id)'
      );
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
  {
    label: 'CHANGE_IN_PLACE_FOREIGN_KEY_REFERENCED',
    perform: async (client) => {
      await client.query(
        'ALTER TABLE foo ALTER COLUMN referenced_value TYPE BIGINT'
      );
    },
    revert: async (client) => {
      await client.query('ALTER TABLE bar ALTER COLUMN value_foo TYPE INTEGER');
    },
  },
  {
    label: 'CHANGE_IN_PLACE_FOREIGN_KEY_REFERENCING',
    perform: async (client) => {
      await client.query('ALTER TABLE bar ALTER COLUMN value_foo TYPE BIGINT');
    },
    revert: async (client) => {
      await client.query('ALTER TABLE bar ALTER COLUMN value_foo TYPE INTEGER');
    },
  },
];

const waitForThatMilliseconds = (delay) =>
  new Promise((resolve) => setTimeout(resolve, delay));

const allowSomeQueryToSlipIn = async () => {
  await waitForThatMilliseconds(1000);
};

(async () => {
  const client = new Client({
    user: 'postgres',
    host: 'localhost',
    database: 'database',
    port: 5432,
  });

  client.connect();

  await allowSomeQueryToSlipIn();
  const results = [];

  for (const change of changes) {
    console.log(`Changing type with ${change.label} 🕗`);
    await resetStatistics(client);

    await change.perform(client);

    console.log(`Type changed ✔`);
    const statistics = await getStatistics(client);
    results.push({
      label: change.label,
      ...statistics,
    });

    console.log('Reverting 🕗');
    await change.revert(client);
    console.log(`Reverted ✔`);
  }

  client.end();
  console.log(results);
})();
