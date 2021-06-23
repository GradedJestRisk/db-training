// https://stackoverflow.com/questions/54795701/migrating-int-to-bigint-in-postgressql-without-any-downtime
const { Client } = require("pg");

const waitForThatMilliseconds = (delay) =>
  new Promise((resolve) => setTimeout(resolve, delay));

const queryAgainstTableWhoseDataTypeIsToBeChanged = async (client) => {
  while (true) {
    console.log(".");
    await client.query("SELECT COUNT(1) FROM foo");
    await client.query("INSERT INTO foo(value) VALUES(0)");
    //await waitForThatMilliseconds(1);
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
