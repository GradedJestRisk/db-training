SHOW max_connections;

 SELECT version();

 SHOW server_version;

-- Variable

WITH myconstants (foo, bar) AS (
   values (5, 'foobar')
)
SELECT *
FROM myconstants
;

SELECT
       'foo' AS bar,
       10    AS foobar
 \gset
;

\echo :bar :foobar
;

SELECT :bar, :foobar
;

\prompt 'Value? ' var
;