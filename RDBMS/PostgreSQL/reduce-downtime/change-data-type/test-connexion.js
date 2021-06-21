const { Client } = require("pg");

(async () => {
  const client = new Client({
    user: "postgres",
    host: "localhost",
    database: "database",
    port: 5432,
  });

  client.connect();

  const text = "SELECT current_database()";
  const values = [];
  let databaseName;

  const res = await client.query(text, values);
  databaseName = res.rows[0].current_database;

  console.log(`Database name is ${databaseName}`);

  client.end();
})();
