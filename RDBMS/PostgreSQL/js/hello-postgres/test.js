const connectionPool = require('./connectionPool')

const chai = require('chai');
chai.should();


const recipe = {
    name: 'caramelized-garlic-tart',
    serving: 4,
    source: 'https://www.theguardian.com/lifeandstyle/2008/mar/01/foodanddrink.shopping1'
};

describe('connexion pool', async () => {

    it('should perform queries', async () => {
        const {rows} = await connectionPool.query('SELECT * FROM recipe WHERE name = $1', ['caramelized-garlic-tart'])
        rows[1].should.be.deep.equal(recipe);
    });

    it('should perform transaction', async () => {
        const insertQuery =  'BEGIN; INSERT INTO "recipe" ("name", "serving", "source") VALUES (\'caramelized-garlic-tart\',\'4\',\'http:\/\/www.theguardian.com/lifeandstyle/2008/mar/01/foodanddrink.shopping1\'); COMMIT;';
        await connectionPool.query(insertQuery);
    });

    it('should perform transaction quickly', async () => {

        const insertQuery =  'BEGIN; INSERT INTO "recipe" ("name", "serving", "source") VALUES (\'caramelized-garlic-tart\',\'4\',\'http:\/\/www.theguardian.com/lifeandstyle/2008/mar/01/foodanddrink.shopping1\'); COMMIT;';
        const MAX_ITERATIONS = 200;
        let currentIterationCount;

        const begin = Date.now();
        currentIterationCount = 0;
        while (currentIterationCount++ <= MAX_ITERATIONS) {
            await connectionPool.query(insertQuery);
        }
        const duration = Date.now() - begin;
        console.log('Duration (ms): ' + duration);
        duration.should.be.greaterThan(0);

    });

});