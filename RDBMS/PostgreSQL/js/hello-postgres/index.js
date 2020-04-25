const { Client } = require('pg');

const client = new Client({
    user: 'postgres',
    host: 'localhost',
    database: 'testdb',
    password: 'password',
    port: 5432,
});

client.connect();

const query = ` 
SELECT *
FROM people
`;

client.query(query, (err, res) => {
    if (err) {
        console.error(err);
        return;
    }
    for (let row of res.rows) {
        console.log(row);
    }
    client.end();
});


