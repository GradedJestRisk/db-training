// https://tech.coffeemeetsbagel.com/reaching-the-max-limit-for-ids-in-postgres-6d6fa2b1c6ea
const { Client } = require('pg');

const labels = {
  inPlace: 'CHANGE_IN_PLACE',
  revert: 'REVERT',
  inPlacePrimaryKey: 'CHANGE_IN_PLACE_PRIMARY_KEY',
  inPlacePrimaryKeyDropCreateConstraint:
    'CHANGE_IN_PLACE_PRIMARY_KEY_CONSTRAINT',
  revertPrimaryKeyType: 'REVERT_PRIMARY_KEY',
  inPlaceReferencedFK: 'CHANGE_IN_PLACE_FOREIGN_KEY_REFERENCED',
  inPlaceReferencingFK: 'CHANGE_IN_PLACE_FOREIGN_KEY_REFERENCING',
  revertForeignKeyType: 'REVERT_REFERENCED_FK',
};

const changeTypeInPlace = async (client) => {
  await client.query('ALTER TABLE foo ALTER COLUMN value TYPE BIGINT', []);
};

const revertType = async (client) => {
  await client.query('ALTER TABLE foo ALTER COLUMN value TYPE INTEGER', []);
};

const changeTypeInPlaceReferencedFK = async (client) => {
  await client.query(
    'ALTER TABLE foo ALTER COLUMN referenced_value TYPE BIGINT',
    []
  );
};

const revertTypeReferencedFK = async (client) => {
  await client.query('ALTER TABLE bar ALTER COLUMN value_foo TYPE INTEGER', []);
};

const changeTypeInPlaceReferencingFK = async (client) => {
  await client.query('ALTER TABLE bar ALTER COLUMN value_foo TYPE BIGINT', []);
};

const revertTypeInPlaceReferencingFK = async (client) => {
  await client.query('ALTER TABLE bar ALTER COLUMN value_foo TYPE INTEGER', []);
};

// https://www.postgresql.org/docs/current/sql-altersequence.html
const changeTypeInPlacePrimaryKey = async (client) => {
  await client.query('ALTER SEQUENCE foo_id_seq AS BIGINT', []);
  await client.query('ALTER TABLE foo ALTER COLUMN id TYPE BIGINT', []);
};

const changeTypeInPlacePrimaryKeyWithDropCreate = async (client) => {
  await client.query('ALTER TABLE foo DROP CONSTRAINT foo_pkey');
  await client.query('ALTER SEQUENCE foo_id_seq AS BIGINT');
  await client.query('ALTER TABLE foo ALTER COLUMN id TYPE BIGINT');
  await client.query('ALTER TABLE foo ADD CONSTRAINT foo_pkey PRIMARY KEY(id)');
};

const revertPrimaryKeyType = async (client) => {
  await client.query('ALTER TABLE foo DROP CONSTRAINT foo_pkey');
  await client.query('ALTER SEQUENCE foo_id_seq AS INTEGER');
  await client.query('ALTER TABLE foo ALTER COLUMN id TYPE INTEGER');
  await client.query('ALTER TABLE foo ADD CONSTRAINT foo_pkey PRIMARY KEY(id)');
};

const waitForThatMilliseconds = (delay) =>
  new Promise((resolve) => setTimeout(resolve, delay));

(async () => {
  const client = new Client({
    user: 'postgres',
    host: 'localhost',
    database: 'database',
    port: 5432,
  });

  client.connect();

  await waitForThatMilliseconds(1000);

  const walStart = (
    await client.query('SELECT pg_current_wal_lsn() AS location')
  ).rows[0].location;

  console.log('Change type in place');
  console.time(labels.inPlace);
  await changeTypeInPlace(client);
  console.timeEnd(labels.inPlace);

  const walSize = (
    await client.query(
      'SELECT pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), $1)) AS size',
      [walStart]
    )
  ).rows[0].size;

  console.log(`WAL used : ${walSize}`);

  await waitForThatMilliseconds(1000);

  console.log('Revert type change..');
  console.time(labels.revert);
  await revertType(client);
  console.timeEnd(labels.revert);

  await waitForThatMilliseconds(1000);

  console.log('Change type on PK in place');
  console.time(labels.inPlacePrimaryKey);
  await changeTypeInPlacePrimaryKey(client);
  console.timeEnd(labels.inPlacePrimaryKey);

  await waitForThatMilliseconds(1000);

  console.log('Revert type change..');
  console.time(labels.revertPrimaryKeyType);
  await revertPrimaryKeyType(client);
  console.timeEnd(labels.revertPrimaryKeyType);

  await waitForThatMilliseconds(1000);

  console.log('Change type on PK in place DROP/CREATE constraint');
  console.time(labels.inPlacePrimaryKeyDropCreateConstraint);
  await changeTypeInPlacePrimaryKeyWithDropCreate(client);
  console.timeEnd(labels.inPlacePrimaryKeyDropCreateConstraint);

  await waitForThatMilliseconds(1000);

  console.log('Revert type change..');
  console.time(labels.revertPrimaryKeyType);
  await revertPrimaryKeyType(client);
  console.timeEnd(labels.revertPrimaryKeyType);

  console.log('Change type on referenced FK in place');
  console.time(labels.inPlaceReferencedFK);
  await changeTypeInPlaceReferencedFK(client);
  console.timeEnd(labels.inPlaceReferencedFK);

  await waitForThatMilliseconds(1000);

  console.log('Revert type change..');
  console.time(labels.revertForeignKeyType);
  await revertTypeReferencedFK(client);
  console.timeEnd(labels.revertForeignKeyType);

  console.log('Change type on referencing FK in place');
  console.time(labels.inPlaceReferencingFK);
  await changeTypeInPlaceReferencingFK(client);
  console.timeEnd(labels.inPlaceReferencingFK);

  await waitForThatMilliseconds(1000);

  console.log('Revert type change..');
  console.time(labels.revertForeignKeyType);
  await revertTypeInPlaceReferencingFK(client);
  console.timeEnd(labels.revertForeignKeyType);

  client.end();
})();
