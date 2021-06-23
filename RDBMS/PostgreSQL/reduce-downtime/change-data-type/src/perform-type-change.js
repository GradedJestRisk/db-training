// https://tech.coffeemeetsbagel.com/reaching-the-max-limit-for-ids-in-postgres-6d6fa2b1c6ea
const { Client } = require("pg");

const labels = {
  revert: "REVERT",
  revertPrimaryKeyType: "REVERT_PRIMARY_KEY",
  inPlace: "CHANGE_IN_PLACE",
  inPlacePrimaryKey: "CHANGE_IN_PLACE_PRIMARY_KEY",
  inPlacePrimaryKeyDropCreateConstraint:
    "CHANGE_IN_PLACE_PRIMARY_KEY_CONSTRAINT",
};

const changeTypeInPlace = async (client) => {
  await client.query("ALTER TABLE foo ALTER COLUMN value TYPE BIGINT", []);
};

const revertType = async (client) => {
  await client.query("ALTER TABLE foo ALTER COLUMN value TYPE INTEGER", []);
};

// https://www.postgresql.org/docs/current/sql-altersequence.html
const changeTypeInPlacePrimaryKey = async (client) => {
  await client.query("ALTER SEQUENCE foo_id_seq AS BIGINT", []);
  await client.query("ALTER TABLE foo ALTER COLUMN id TYPE BIGINT", []);
};

const changeTypeInPlacePrimaryKeyWithDropCreate = async (client) => {
  await client.query("ALTER TABLE foo DROP CONSTRAINT foo_pkey");
  await client.query("ALTER SEQUENCE foo_id_seq AS BIGINT");
  await client.query("ALTER TABLE foo ALTER COLUMN id TYPE BIGINT");
  await client.query("ALTER TABLE foo ADD CONSTRAINT foo_pkey PRIMARY KEY(id)");
};

const revertPrimaryKeyType = async (client) => {
  await client.query("ALTER TABLE foo DROP CONSTRAINT foo_pkey");
  await client.query("ALTER SEQUENCE foo_id_seq AS INTEGER");
  await client.query("ALTER TABLE foo ALTER COLUMN id TYPE INTEGER");
  await client.query("ALTER TABLE foo ADD CONSTRAINT foo_pkey PRIMARY KEY(id)");
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

  await waitForThatMilliseconds(1000);

  console.log("Revert type change..");
  console.time(labels.revert);
  await revertType(client);
  console.timeEnd(labels.revert);

  await waitForThatMilliseconds(1000);

  console.log("Change type on PK in place");
  console.time(labels.inPlacePrimaryKey);
  await changeTypeInPlacePrimaryKey(client);
  console.timeEnd(labels.inPlacePrimaryKey);

  await waitForThatMilliseconds(1000);

  console.log("Revert type change..");
  console.time(labels.revertPrimaryKeyType);
  await revertPrimaryKeyType(client);
  console.timeEnd(labels.revertPrimaryKeyType);

  await waitForThatMilliseconds(1000);

  console.log("Change type on PK in place DROP/CREATE constraint");
  console.time(labels.inPlacePrimaryKeyDropCreateConstraint);
  await changeTypeInPlacePrimaryKeyWithDropCreate(client);
  console.timeEnd(labels.inPlacePrimaryKeyDropCreateConstraint);

  await waitForThatMilliseconds(1000);

  console.log("Revert type change..");
  console.time(labels.revertPrimaryKeyType);
  await revertPrimaryKeyType(client);
  console.timeEnd(labels.revertPrimaryKeyType);

  client.end();
})();
