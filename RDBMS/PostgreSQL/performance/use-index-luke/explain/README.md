# Gimme the explain plan !

You won't have to ask for it.

Include: 
- auto-explain PG library
- a parser on top of logs

Setup
- clone this repository
- clone that [repository](https://github.com/maahl/pg_explain_lexer)
- [install click](https://github.com/maahl/pg_explain_lexer/blob/master/README.md#colorize-auto_explain-output-in-logs)  
- update npm task [database:peek-last-logs](package.json) to mention script location
  
Use
- start database: `docker-compose up -d`
- connect to database: `npm run database:connect`
- in a separate window, open logs: `npm run database:peek-last-logs`
- issue some queries, eg `SELECT * FROM pg_class LIMIT 1`
- you'll the following output, colorized 

```shell
2021-07-20 16:21:54.997 UTC [59] LOG:  statement: select * from pg_class LIMIT 1;
2021-07-20 16:21:54.997 UTC [59] LOG:  duration: 0.056 ms  plan:
Query Text: select * from pg_class LIMIT 1;
Limit  (cost=0.00..0.04 rows=1 width=265) (actual time=0.010..0.011 rows=1 loops=1)
```
