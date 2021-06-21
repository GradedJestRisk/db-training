// https://tech.coffeemeetsbagel.com/reaching-the-max-limit-for-ids-in-postgres-6d6fa2b1c6ea
const { Client } = require("pg");

const labels = { inPlace: "CHANGE_IN_PLACE" };

const changeTypeInPlace = async (client) => {
  await client.query("ALTER TABLE foo ALTER COLUMN value TYPE BIGINT", []);
};

const waitForThatMilliseconds = (delay) =>
  new Promise((resolve) => setTimeout(resolve, delay));

(async () => {
  const client = new Client({
    user: "postgres",
    host: "localhost",
    database: "database",
    port: 5432,
  });

  client.connect();

  await waitForThatMilliseconds(1000);

  console.log("Change type in place");
  console.time(labels.inPlace);
  await changeTypeInPlace(client);
  console.timeEnd(labels.inPlace);

  client.end();
})();
