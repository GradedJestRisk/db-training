var knex = require('knex')({
  client: 'pg',
  connection: {
    host : 'localhost',
    user : 'postgres',
    password : 'password',
    database : 'testdb'
  }
});


knex.from('people').select('name').where('type', '<>', 'human')
    .then((rows) => {
        for (row of rows) {
            console.log(`${row['name']} ${row['type']}`);
        }
    })
    .catch((err) => { console.log( err); throw err })
    .finally(() => {
        knex.destroy();
    });
