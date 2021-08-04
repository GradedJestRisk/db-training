// https://stackoverflow.com/questions/54795701/migrating-int-to-bigint-in-postgressql-without-any-downtime
const { Client } = require('pg');

const { Pool } = require('pg');

const connexion = {
  user: 'activity',
  host: 'localhost',
  database: 'database',
  port: 5432,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
};

const waitForThatMilliseconds = (delay) =>
  new Promise((resolve) => setTimeout(resolve, delay));

const queryAgainstTableWhoseDataTypeIsToBeChanged = async (pool) => {
  while (true) {
    process.stdout.write('.');

    // Read
    // Short living query
    await pool.query('SELECT * FROM foo LIMIT 1');
    // Long-living query
    // await client.query("SELECT COUNT(1) FROM foo");
    // await client.query("SELECT * FROM foo ORDER BY RANDOM() LIMIT 1");

    // Write
    await pool.query(
      'INSERT INTO foo(value, referenced_value) ' +
        'VALUES( 1, floor(random() * 2147483627 + 1)::int ) ON CONFLICT ON CONSTRAINT referenced_value_unique DO NOTHING'
    );

    await waitForThatMilliseconds(10);
  }
};

(async () => {
  const pool = new Pool(connexion);

  pool.connect();
  console.log('Reading and writing in table foo..');
  await queryAgainstTableWhoseDataTypeIsToBeChanged(pool);

  pool.end();
})();
