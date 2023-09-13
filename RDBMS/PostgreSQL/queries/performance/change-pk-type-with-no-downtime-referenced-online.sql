------------------------------------------------
-- Note: step A / B / C should not be delivered --
------------------------------------------------


-------------------------------------------------------------------------------------
-------- Step A: Cleanup                                                                   --
-------------------------------------------------------------------------------------
DROP TABLE IF EXISTS "knowledge-elements_bigint";
DROP TABLE IF EXISTS "answers_bigint";
DROP FUNCTION IF EXISTS "insert_answers_in_answers_bigint";
DROP FUNCTION IF EXISTS "insert_knowledge-elements_in_knowledge-elements_bigint";
DROP TRIGGER IF EXISTS "trg_answers" on "answers";
DROP TRIGGER IF EXISTS "trg_knowledge-elements" on "knowledge-elements";
DROP TABLE IF EXISTS "bigint-migration-settings";

-------------------------------------------------------------------------------------
-------- Step B: Setup local environment as production                             --
-------------------------------------------------------------------------------------

-- Seeds exhibit
-- - a sequence gap: this is akin to production, because of rollbacked transactions
-- - a max value of sequence, inferior to max(id): this is obviously invalid

SELECT MAX(id) FROM "answers";
-- 108 312

SELECT COUNT(1) FROM "answers";
-- 3 429

SELECT MAX(id) FROM "knowledge-elements";
-- 108 313

SELECT COUNT(1) FROM "knowledge-elements";
-- 2 931

-- We need to make local environment akin to production

-- npm run db:reset

-- Next sequence value will be MAX(id) + 1
ALTER SEQUENCE "answers_id_seq" RESTART WITH 108313;
ALTER SEQUENCE "knowledge-elements_id_seq" RESTART WITH 108314;

SELECT nextval('"answers_id_seq"');
-- 108 313
SELECT nextval('"knowledge-elements_id_seq"');
-- 108 314


-------------------------------------------------------------------------------------
-------- Step C: Simulate write activity                                          --
-------------------------------------------------------------------------------------

-- Answers
INSERT INTO answers (value, result, "assessmentId", "challengeId", timeout, "resultDetails", "timeSpent", "isFocusedOut")
SELECT a.value, a.result, a."assessmentId", a."challengeId", a.timeout, a."resultDetails", a."timeSpent", a."isFocusedOut"
FROM answers a,  generate_series(1, 5)
WHERE id = 108312;

SELECT id, "createdAt" FROM "answers" ORDER BY id DESC;

SELECT COUNT(1) FROM "answers";
-- 3 434 + 5  => 3 439 - OK

-- KE
-- It would be much better to insert KE on freshly created answers, how to do so ?
INSERT INTO "knowledge-elements"
    ( source, status, "createdAt", "answerId", "assessmentId", "skillId", "earnedPix", "userId", "competenceId")
SELECT ke.source, ke.status, ke."createdAt", ke."answerId", ke."assessmentId", ke."skillId", ke."earnedPix", ke."userId", ke."competenceId"
FROM  "knowledge-elements" ke, generate_series(1, 5)
WHERE id = 108313;

SELECT id, "createdAt" FROM "knowledge-elements" ORDER BY id DESC;

SELECT COUNT(1) FROM "knowledge-elements";
-- 2 931 + 5  => 2 936 - OK


------------------------
-- Here starts script --
------------------------


-------------------------------------------------------------------------------------
-------- Step 1: create temporary table                                            --
-------------------------------------------------------------------------------------

CREATE TABLE answers_bigint (
    id bigint NOT NULL,
    value text,
    result character varying(255),
    "assessmentId" integer,
    "challengeId" character varying(255) NOT NULL,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    timeout integer,
    "resultDetails" text,
    "timeSpent" integer,
    "isFocusedOut" boolean DEFAULT false NOT NULL
);

CREATE TABLE "knowledge-elements_bigint" (
    id bigint NOT NULL,
    source character varying(255),
    status character varying(255),
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "answerId" integer,
    "assessmentId" integer,
    "skillId" character varying(255),
    "earnedPix" real DEFAULT '0'::real NOT NULL,
    "userId" integer,
    "competenceId" character varying(255)
);

CREATE TABLE "bigint-migration-settings" (
    "tableName" character varying(255) PRIMARY KEY CHECK ("tableName" IN ('answers', 'knowledge-elements')),
    "startsAtId" integer,
    "endsAtId" integer
);

INSERT INTO "bigint-migration-settings" ("tableName")
VALUES ('answers');

INSERT INTO "bigint-migration-settings" ("tableName")
VALUES ('knowledge-elements');

-------------------------------------------------------------------------------------
-------- Step 2: Load temporary table                                             ---
-------------------------------------------------------------------------------------

-- If we're in a transaction, we might avoid getting KE created after answers has been copied
-- If not so, we should delete KE with no matching answers

-- If restoring from a dump, we will get no such trouble
-- Check '--serializable-deferrable' from  https://www.postgresql.org/docs/13/app-pgdump.html

BEGIN TRANSACTION;

-- Load data to perform BIGINT migration implicitly
-- estimated time :
INSERT INTO "answers_bigint"
    (id, value, result, "assessmentId", "challengeId", timeout, "resultDetails", "timeSpent", "isFocusedOut")
SELECT
    a.id, a.value, a.result, a."assessmentId", a."challengeId", a.timeout, a."resultDetails", a."timeSpent", a."isFocusedOut"
FROM "answers" a;

-- *** Execute Step C: Simulate write activity *** --

-- Load data to perform BIGINT migration implicitly
-- estimated time :
INSERT INTO "knowledge-elements_bigint"
    ( id, source, status, "createdAt", "answerId", "assessmentId", "skillId", "earnedPix", "userId", "competenceId")
SELECT
    ke.id, ke.source, ke.status, ke."createdAt", ke."answerId", ke."assessmentId", ke."skillId", ke."earnedPix", ke."userId", ke."competenceId"
FROM "knowledge-elements" ke;


COMMIT;

-------------------------------------------------------------------------------------
-------- Step 3: Create constraints and indexes                                    --
-------------------------------------------------------------------------------------

-- Index creation is time-consuming and thus can be executed :
--  - in a low-activity period
--  - one index each day
--  - possibly allowing more resources : check maintenance_work_mem and maintenance_workers

-- answers
-- estimated time :
ALTER TABLE ONLY answers_bigint ADD CONSTRAINT answers_bigint_pkey PRIMARY KEY (id);
ALTER TABLE ONLY answers_bigint  ADD CONSTRAINT answers_bigint_assessmentid_foreign FOREIGN KEY ("assessmentId") REFERENCES assessments(id);
CREATE INDEX answers_bigint_assessmentid_index ON answers_bigint USING btree ("assessmentId");

-- KE
-- estimated time :
ALTER TABLE ONLY "knowledge-elements_bigint" ADD CONSTRAINT "knowledge-elements_bigint_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY "knowledge-elements_bigint" ADD CONSTRAINT knowledge_elements_bigint_answerid_foreign FOREIGN KEY ("answerId") REFERENCES "answers_bigint"(id);
ALTER TABLE ONLY "knowledge-elements_bigint" ADD CONSTRAINT knowledge_elements_bigint_assessmentid_foreign FOREIGN KEY ("assessmentId") REFERENCES assessments(id);
ALTER TABLE ONLY "knowledge-elements_bigint" ADD CONSTRAINT knowledge_elements_bigint_userid_foreign FOREIGN KEY ("userId") REFERENCES users(id);
CREATE INDEX knowledge_elements_bigint_userid_index ON "knowledge-elements_bigint" USING btree ("userId");

-------------------------------------------------------------------------------------
-------- Step 4 : Get all data inserted onward starting from now                   --
-------------------------------------------------------------------------------------

-- Table are out of sync since the very beginning
SELECT COUNT(1) FROM "answers";
SELECT COUNT(1) FROM "answers_bigint";
SELECT COUNT(1) FROM "knowledge-elements";
SELECT COUNT(1) FROM "knowledge-elements_bigint";

UPDATE "bigint-migration-settings" bms
SET "startsAtId" = (SELECT MAX(id) + 1 FROM "answers_bigint")
WHERE bms."tableName" = 'answers';

UPDATE "bigint-migration-settings" bms
SET "startsAtId" = (SELECT MAX(id) + 1 FROM "knowledge-elements_bigint")
WHERE bms."tableName" = 'knowledge-elements';


-- MAINTENANCE WINDOW / START
BEGIN TRANSACTION;

-- Beware of deadlocks !
LOCK TABLE "answers" IN ACCESS EXCLUSIVE MODE;
LOCK TABLE "knowledge-elements" IN ACCESS EXCLUSIVE MODE;

UPDATE "bigint-migration-settings" bms
SET "endsAtId" = (SELECT MAX(id) FROM "answers")
WHERE bms."tableName" = 'answers';

UPDATE "bigint-migration-settings" bms
SET "endsAtId" = (SELECT MAX(id) FROM "knowledge-elements")
WHERE bms."tableName" = 'knowledge-elements';

SELECT * FROM "bigint-migration-settings";

CREATE OR REPLACE FUNCTION "insert_answers_in_answers_bigint"()
  RETURNS TRIGGER AS
  $$
  BEGIN
    INSERT INTO "answers_bigint"
        ("id", "value", "result", "assessmentId", "challengeId", timeout, "resultDetails", "timeSpent", "isFocusedOut")
    VALUES
        (NEW."id"::BIGINT, NEW."value", NEW."result", NEW."assessmentId", NEW."challengeId", NEW."timeout", NEW."resultDetails", NEW."timeSpent", NEW."isFocusedOut");
    RETURN NEW;
  END
  $$ LANGUAGE plpgsql;

CREATE TRIGGER "trg_answers"
AFTER INSERT ON "answers"
FOR EACH ROW
EXECUTE FUNCTION "insert_answers_in_answers_bigint"();


CREATE OR REPLACE FUNCTION "insert_knowledge-elements_in_knowledge-elements_bigint"()
  RETURNS TRIGGER AS
  $$
  BEGIN
    INSERT INTO "knowledge-elements_bigint"
       ( id, source, status, "createdAt", "answerId", "assessmentId", "skillId", "earnedPix", "userId", "competenceId")
    VALUES
        ( NEW.id::BIGINT, NEW.source, NEW.status, NEW."createdAt", NEW."answerId", NEW."assessmentId", NEW."skillId", NEW."earnedPix", NEW."userId", NEW."competenceId");
    RETURN NEW;
  END
  $$ LANGUAGE plpgsql;

CREATE TRIGGER "trg_knowledge-elements"
AFTER INSERT ON "knowledge-elements"
FOR EACH ROW
EXECUTE FUNCTION "insert_knowledge-elements_in_knowledge-elements_bigint"();

-- Release lock
COMMIT;

-- MAINTENANCE WINDOW / END

-- *** Execute Step C: Simulate write activity *** --

-------------------------------------------------------------------------------------------------------
-------- Step 5 : Insert all data inserted since temporary table load (and before trigger creation)  --
-------------------------------------------------------------------------------------------------------

SELECT * FROM "bigint-migration-settings";

WITH range AS (
    SELECT bms."startsAtId", bms."endsAtId" FROM "bigint-migration-settings" bms
    WHERE bms."tableName" = 'answers'
)
INSERT INTO "answers_bigint"
    ("id", "value", "result", "assessmentId", "challengeId", timeout, "resultDetails", "timeSpent", "isFocusedOut")
SELECT
    a_source."id"::BIGINT, a_source."value", a_source."result", a_source."assessmentId", a_source."challengeId", a_source."timeout", a_source."resultDetails", a_source."timeSpent", a_source."isFocusedOut"
FROM
   "answers" a_source, range
WHERE a_source.id BETWEEN range."startsAtId" AND range."endsAtId"
;

WITH range AS (
    SELECT bms."startsAtId", bms."endsAtId" FROM "bigint-migration-settings" bms
    WHERE bms."tableName" = 'knowledge-elements'
)
INSERT INTO "knowledge-elements_bigint"
    ("id", "source", "status", "createdAt", "answerId", "assessmentId", "skillId", "earnedPix", "userId", "competenceId")
SELECT
    ke_source.id::BIGINT, ke_source.source, ke_source.status, ke_source."createdAt", ke_source."answerId", ke_source."assessmentId", ke_source."skillId", ke_source."earnedPix", ke_source."userId", ke_source."competenceId"
FROM
   "knowledge-elements" ke_source, range
WHERE ke_source.id BETWEEN range."startsAtId" AND range."endsAtId"
;


SELECT
    COUNT(1)
FROM
	"answers" a FULL OUTER JOIN "answers_bigint" a_tmp USING (id)
WHERE 1=1
    AND (a.id IS NULL OR a_tmp.id IS NULL)
;


-------------------------------------------------------------------------------------
-------- Step 6 - Expose changes                                                   --
-------------------------------------------------------------------------------------


-- MAINTENANCE WINDOW / START

BEGIN TRANSACTION;
LOCK TABLE "answers" IN ACCESS EXCLUSIVE MODE;
LOCK TABLE "knowledge-elements" IN ACCESS EXCLUSIVE MODE;


DROP TRIGGER IF EXISTS "trg_answers" on "answers";
DROP TRIGGER IF EXISTS "trg_knowledge-elements" on "knowledge-elements";
DROP FUNCTION "insert_answers_in_answers_bigint";
DROP FUNCTION "insert_knowledge-elements_in_knowledge-elements_bigint";

ALTER SEQUENCE "answers_id_seq" OWNED BY "answers_bigint"."id";
ALTER SEQUENCE "answers_id_seq" AS bigint;
ALTER TABLE "answers_bigint" ALTER COLUMN "id" SET DEFAULT nextval('"answers_id_seq"');


ALTER SEQUENCE "knowledge-elements_id_seq" OWNED BY "knowledge-elements_bigint"."id";
ALTER SEQUENCE "knowledge-elements_id_seq" AS bigint;
ALTER TABLE "knowledge-elements_bigint" ALTER COLUMN "id" SET DEFAULT nextval('"knowledge-elements_id_seq"');


-- Rename or drop for backup plan ?
DROP TABLE "knowledge-elements";
ALTER TABLE "knowledge-elements_bigint" RENAME TO "knowledge-elements";

-- Rename or drop for backup plan ?
DROP TABLE answers;
ALTER TABLE "answers_bigint" RENAME TO "answers";
ALTER INDEX "answers_bigint_assessmentid_index" RENAME TO "answers_assessmentid_index";


ALTER TABLE "answers" RENAME CONSTRAINT "answers_bigint_pkey" TO "answers_pkey";
ALTER TABLE "answers" RENAME CONSTRAINT "answers_bigint_assessmentid_foreign" TO "answers_assessmentid_foreign";

ALTER TABLE "knowledge-elements" RENAME CONSTRAINT "knowledge-elements_bigint_pkey" TO "knowledge-elements_pkey";
ALTER TABLE "knowledge-elements" RENAME CONSTRAINT "knowledge_elements_bigint_assessmentid_foreign" TO "knowledge_elements_assessmentid_foreign";
ALTER TABLE "knowledge-elements" RENAME CONSTRAINT "knowledge_elements_bigint_userid_foreign" TO "knowledge_elements_userid_foreign";
ALTER TABLE "knowledge-elements" RENAME CONSTRAINT "knowledge_elements_bigint_answerid_foreign" TO "knowledge_elements_answerid_foreign";
ALTER INDEX "knowledge_elements_bigint_userid_index" RENAME TO "knowledge_elements_userid_index";

-- Release lock
COMMIT;

-- MAINTENANCE WINDOW / END

-------------------------------------------------------------------------------------
-------- Step 7 - Business comes as as usual                                       --
-------------------------------------------------------------------------------------


-- *** Execute Step C: Simulate write activity *** --

SELECT id, "createdAt", 'answers=>', a.*
FROM answers a
ORDER BY a.id DESC;

SELECT id, "createdAt", 'knowledge-elements=>', ke.*
FROM "knowledge-elements" ke
ORDER BY ke.id DESC;