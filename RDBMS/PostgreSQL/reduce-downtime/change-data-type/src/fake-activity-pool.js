const { Pool } = require('pg');

const connexion = {
  user: 'activity',
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

const waitForThatMilliseconds = (delay) =>
  new Promise((resolve) => setTimeout(resolve, delay));

const queryAgainstTableWhoseDataTypeIsToBeChanged = async (pool) => {
  const queries = [
    // Read
    // Short living query
    'SELECT * FROM foo LIMIT 1',
    'SELECT * FROM foobar LIMIT 1',
    // Long-living query
    'SELECT * FROM foo ORDER BY RANDOM() LIMIT 1',
    'SELECT * FROM foobar ORDER BY RANDOM() LIMIT 1',
    // Write
    'INSERT INTO foo(value, referenced_value) VALUES( 1, floor(random() * 2147483627 + 1)::int ) ON CONFLICT ON CONSTRAINT referenced_value_unique DO NOTHING',
    'INSERT INTO foobar(foo_id) VALUES(1)',
  ];

  while (true) {
    await Promise.all(
      queries.map((query) => {
        return pool.query(query);
      })
    );
    process.stdout.write('.');
    await waitForThatMilliseconds(10);
  }
};

(async () => {
  const pool = new Pool(poolConfiguration);

  pool.on('error', (error) => {
    // console.log('error event on pool');
    // console.error(error);
    process.stdout.write('x');
  });

  pool.on('connect', (client) => {
    client.on('error', (error) => {
      // console.log('error event on connect');
      // console.error(error);
    });
  });

  pool.connect();
  //console.log('Reading and writing in table foo..');
  await queryAgainstTableWhoseDataTypeIsToBeChanged(pool);

  pool.end();
})();
