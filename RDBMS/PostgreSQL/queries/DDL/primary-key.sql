
-- Primary key is
-- - UNIQUE
-- - NOT NULL


----------------- 1 step ------------------------

scalingo -a pix-int-to-bigint-test run "bash -c 'dbclient-fetcher pgsql 12 && psql \$SCALINGO_POSTGRESQL_URL -c \"SELECT current_user\"'"


ALTER TABLE "knowledge-elements" ADD CONSTRAINT "knowledge-elements_pkey" PRIMARY KEY (id);

pix_api_prod_4785=> \d "knowledge-elements"
                                         Table "public.knowledge-elements"
    Column    |           Type           | Collation | Nullable |                     Default
--------------+--------------------------+-----------+----------+--------------------------------------------------
 id           | integer                  |           | not null | nextval('"knowledge-elements_id_seq"'::regclass)
 source       | character varying(255)   |           |          |
 status       | character varying(255)   |           |          |
 answerId     | integer                  |           |          |
 assessmentId | integer                  |           |          |
 skillId      | character varying(255)   |           |          |
 createdAt    | timestamp with time zone |           | not null | CURRENT_TIMESTAMP
 earnedPix    | real                     |           | not null | '0'::real
 userId       | integer                  |           |          |
 competenceId | character varying(255)   |           |          |
Indexes:
    "knowledge-elements_pkey" PRIMARY KEY, btree (id)
    "knowledge-elements_assessmentId_idx" btree ("assessmentId")
    "knowledge_elements_userid_index" btree ("userId")
Foreign-key constraints:
    "knowledge_elements_answerid_foreign" FOREIGN KEY ("answerId") REFERENCES answers(id)
    "knowledge_elements_assessmentid_foreign" FOREIGN KEY ("assessmentId") REFERENCES assessments(id)
    "knowledge_elements_userid_foreign" FOREIGN KEY ("userId") REFERENCES users(id)



DROP TABLE IF EXISTS foo CASCADE;
CREATE TABLE foo (id INTEGER);
INSERT INTO foo (id) VALUES (0);
INSERT INTO foo (id) VALUES (NULL);

ALTER TABLE foo
ADD CONSTRAINT foo_pkey PRIMARY KEY (id);
-- [23502] ERROR: column "id" of relation "foo" contains null values

DELETE FROM foo WHERE id IS NULL;

ALTER TABLE foo
ADD CONSTRAINT foo_pkey PRIMARY KEY (id);

INSERT INTO foo (id) VALUES (0);
-- [23505] ERROR: duplicate key value violates unique constraint "foo_pkey"
ALTER TABLE "answers" ADD CONSTRAINT "answers_pkey" PRIMARY KEY(id);  ALTER TABLE "users" ADD CONSTRAINT "users_pkey" PRIMARY KEY(id);


ALTER TABLE "knowledge-elements" ADD CONSTRAINT "knowledge_elements_fk_answers" FOREIGN KEY ("answerId") REFERENCES answers (id);
ALTER TABLE "knowledge-elements" ADD CONSTRAINT "knowledge_elements_fk_users" FOREIGN KEY ("userId") REFERENCES users (id);
ALTER TABLE "knowledge-elements" ADD CONSTRAINT "knowledge_elements_fk_assessments" FOREIGN KEY ("assessmentId") REFERENCES assessments (id);

----------------- 2 steps ------------------------

DROP TABLE IF EXISTS foo CASCADE;
CREATE TABLE foo (id INTEGER);
INSERT INTO foo (id) VALUES (0);
INSERT INTO foo (id) VALUES (NULL);

CREATE UNIQUE INDEX idx ON foo(id);

ALTER TABLE foo
ADD CONSTRAINT foo_pkey PRIMARY KEY
USING INDEX idx;

-- [23502] ERROR: column "id" of relation "foo" contains null values

DELETE FROM foo WHERE id IS NULL;

ALTER TABLE foo
ADD CONSTRAINT foo_pkey PRIMARY KEY
USING INDEX idx;
-- [00000] ALTER TABLE / ADD CONSTRAINT USING INDEX will rename index "idx" to "foo_pkey"
-- completed in 8 ms

INSERT INTO foo (id) VALUES (1);
INSERT INTO foo (id) VALUES (NULL);
-- [23502] ERROR: null value in column "id" of relation "foo" violates not-null constraint