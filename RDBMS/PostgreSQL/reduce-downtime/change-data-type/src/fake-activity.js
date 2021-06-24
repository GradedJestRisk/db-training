// https://stackoverflow.com/questions/54795701/migrating-int-to-bigint-in-postgressql-without-any-downtime
const { Client } = require("pg");

const waitForThatMilliseconds = (delay) =>
  new Promise((resolve) => setTimeout(resolve, delay));

const queryAgainstTableWhoseDataTypeIsToBeChanged = async (client) => {
  while (true) {
    process.stdout.write(".");

    // Read
    // Short living query
    await client.query("SELECT * FROM foo LIMIT 1");
    // Long-living query
    // await client.query("SELECT COUNT(1) FROM foo");
    // await client.query("SELECT * FROM foo ORDER BY RANDOM() LIMIT 1");

    // Write
    await client.query("INSERT INTO foo(value) VALUES(1)");

    await waitForThatMilliseconds(10);
  }
};

(async () => {
  const client = new Client({
    user: "postgres",
    host: "localhost",
    database: "database",
    port: 5432,
  });

  client.connect();

  console.log("Reading and writing in table foo..");
  await queryAgainstTableWhoseDataTypeIsToBeChanged(client);

  client.end();
})();
