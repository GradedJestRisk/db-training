SELECT * FROM
   knex_migrations
ORDER BY id DESC
;


INSERT INTO knex_migrations
    (name, batch, migration_time)
VALUES
    ('20210819161111_use-bigint-for-knowledge-elements-pk.js', 188,  NOW());
