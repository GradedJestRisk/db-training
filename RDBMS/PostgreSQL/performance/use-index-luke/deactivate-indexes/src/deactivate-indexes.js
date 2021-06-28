const { Client } = require('pg');
const { performance } = require('perf_hooks');

const labels = {
  revert: 'REVERT',
  createTableWithoutIndex: 'CREATE_TABLE_WITHOUT_INDEX',
  createIndex: 'CREATE_INDEX',
  createTableWithIndex: 'CREATE_TABLE_WITH_INDEX',
  insertData: 'INSERT_DATA',
};

const revert = async (client) => {
  await client.query('DROP TABLE IF EXISTS foo', []);
};

let insertData = async (client) => {
  await client.query(
    'INSERT INTO foo (id) VALUES (generate_series( 1, 10000000))'
  );
};

const createTableWithoutIndex = async (client) => {
  await client.query('CREATE TABLE foo (id INTEGER)');
};

const createIndex = async (client) => {
  await client.query('ALTER TABLE foo ADD UNIQUE(id)');
};

const createTableWithIndex = async (client) => {
  await client.query('CREATE TABLE foo (id INTEGER UNIQUE)', []);
};

const getWalStart = async (client) => {
  return (await client.query('SELECT pg_current_wal_lsn() AS location')).rows[0]
    .location;
};

const getWalSize = async (client, walStart) => {
  return (
    await client.query(
      'SELECT pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), $1)) AS size',
      [walStart]
    )
  ).rows[0].size;
};

(async () => {
  const client = new Client({
    user: 'postgres',
    host: 'localhost',
    database: 'database',
    port: 5432,
  });

  client.connect();
  await revert(client);

  // Make measurement more accurate with async hooks
  // https://blog.logrocket.com/experimental-node-js-testing-the-new-performance-hooks-31fcdd2a747e/

  const afterwardsStart = performance.now();
  const walStart = await getWalStart(client);
  console.log('Creating table without index..');
  console.time(labels.createTableWithoutIndex);
  await createTableWithoutIndex(client);
  console.timeEnd(labels.createTableWithoutIndex);

  console.log('Inserting data..');
  console.time(labels.insertData);
  await insertData(client);
  console.timeEnd(labels.insertData);

  console.log('Creating index..');
  console.time(labels.createIndex);
  await createIndex(client);
  console.timeEnd(labels.createIndex);

  const walSize = await getWalSize(client, walStart);
  console.log(`WAL used: ${walSize}`);

  const elapsedTimeAfterwards = performance.now() - afterwardsStart;

  console.log('Reverting..');
  console.time(labels.revert);
  await revert(client);
  console.timeEnd(labels.revert);

  const simultaneouslyStart = performance.now();

  console.log('Creating table with index..');
  console.time(labels.createTableWithIndex);
  await createTableWithIndex(client);
  console.timeEnd(labels.createTableWithIndex);

  console.log('Inserting data..');
  console.time(labels.insertData);
  await insertData(client);
  console.timeEnd(labels.insertData);

  const elapsedTimeSimultaneously = performance.now() - simultaneouslyStart;

  console.log('Reverting..');
  console.time(labels.revert);
  await revert(client);
  console.timeEnd(labels.revert);

  console.log(
    `Total time when index is created after inserting data is ${Math.trunc(
      elapsedTimeAfterwards
    )} milliseconds`
  );
  console.log(
    `Total time when index is created before inserting data is ${Math.trunc(
      elapsedTimeSimultaneously
    )} milliseconds`
  );

  const gain =
    ((elapsedTimeSimultaneously - elapsedTimeAfterwards) /
      elapsedTimeAfterwards) *
    100;

  console.log(`Gain to create index afterwards is ${Math.trunc(gain)} %`);

  client.end();
})();
