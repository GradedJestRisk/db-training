const { Pool } = require('pg');

const pool = new Pool({
    database: 'cooking_db',
    user:     'postgres',
    port:      7432,
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
})

module.exports = {
    query: (text, params) => pool.query(text, params),
}