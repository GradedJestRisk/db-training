DROP TABLE IF EXISTS "answers_bigint";
DROP TABLE "knowledge-elements_bigint";

SELECT MAX(id) FROM answers;
-- 100

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
    source character varying(255),
    status character varying(255),
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "answerId" integer,
    "assessmentId" integer,
    "skillId" character varying(255),
    "earnedPix" real DEFAULT '0'::real NOT NULL,
    "userId" integer,
    "competenceId" character varying(255),
    id bigint NOT NULL
);


-- Simulate activity
INSERT INTO answers (value, result, "assessmentId", "challengeId", timeout, "resultDetails", "timeSpent", "isFocusedOut")
SELECT a.value, a.result, a."assessmentId", a."challengeId", a.timeout, a."resultDetails", a."timeSpent", a."isFocusedOut"
FROM answers a
WHERE id = 100;

-- LOCK TABLE "answers" IN ACCESS EXCLUSIVE MODE;

SELECT MAX(id) FROM answers;
-- 101 - START_ID


-------------------------------------------------------------------------------------
-------- Load data --
-------------------------------------------------------------------------------------

-- Load data to perform BIGINT migration implicitly
-- estimated time :
INSERT INTO "answers_bigint"
SELECT * FROM "answers";


-- Load data to perform BIGINT migration implicitly
-- estimated time :
INSERT INTO "knowledge-elements_bigint"
SELECT * FROM "knowledge-elements";


-- COMMIT to release lock

-- Simulate activity
INSERT INTO answers (value, result, "assessmentId", "challengeId", timeout, "resultDetails", "timeSpent", "isFocusedOut")
SELECT a.value, a.result, a."assessmentId", a."challengeId", a.timeout, a."resultDetails", a."timeSpent", a."isFocusedOut"
FROM answers a
WHERE id = 100;

SELECT MAX(id) FROM answers;
-- 102

SELECT MAX(id) FROM answers_bigint;
-- 101


-------------------------------------------------------------------------------------
-------- Get inserted data since table creation ?--
-------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------
-------- CREATE CONSTRAINTS AND INDEXES --
-------------------------------------------------------------------------------------

-- answers
ALTER TABLE ONLY answers_bigint ADD CONSTRAINT answers_bigint_pkey PRIMARY KEY (id);
CREATE INDEX answers_bigint_assessmentid_index ON answers_bigint USING btree ("assessmentId");
ALTER TABLE ONLY answers_bigint  ADD CONSTRAINT answers_bigint_assessmentid_foreign FOREIGN KEY ("assessmentId") REFERENCES assessments(id);


-- KE
ALTER TABLE ONLY "knowledge-elements_bigint" ADD CONSTRAINT "knowledge-elements_bigint_pkey" PRIMARY KEY (id);
CREATE INDEX knowledge_elements_bigint_userid_index ON "knowledge-elements_bigint" USING btree ("userId");
ALTER TABLE ONLY "knowledge-elements_bigint" ADD CONSTRAINT knowledge_elements_bigint_answerid_foreign FOREIGN KEY ("answerId") REFERENCES "answers_bigint"(id);
ALTER TABLE ONLY "knowledge-elements_bigint" ADD CONSTRAINT knowledge_elements_bigint_assessmentid_foreign FOREIGN KEY ("assessmentId") REFERENCES assessments(id);
ALTER TABLE ONLY "knowledge-elements_bigint" ADD CONSTRAINT knowledge_elements_bigint_userid_foreign FOREIGN KEY ("userId") REFERENCES users(id);


-------------------------------------------------------------------------------------
-------- Get newly inserted data --
-------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION "insert_answers_in_answers_bigint"()
  RETURNS TRIGGER AS
  $$
  BEGIN
    INSERT INTO answers_bigint
        ("id", "value", "result", "assessmentId", "challengeId", timeout, "resultDetails", "timeSpent", "isFocusedOut")
    VALUES
        (NEW."id", NEW."value", NEW."result", NEW."assessmentId", NEW."challengeId", NEW."timeout", NEW."resultDetails", NEW."timeSpent", NEW."isFocusedOut");
    RETURN NEW;
  END
  $$ LANGUAGE plpgsql;


-- LOCK TABLE "answers" IN ACCESS EXCLUSIVE MODE;
SELECT MAX(id) FROM answers;
-- 102 - END_ID

DROP TRIGGER IF EXISTS "trg_answers" on answers;
CREATE TRIGGER "trg_answers"
AFTER INSERT ON "answers"
FOR EACH ROW
EXECUTE FUNCTION "insert_answers_in_answers_bigint"();

-- COMMIT to release lock

-- Simulate activity
INSERT INTO answers (value, result, "assessmentId", "challengeId", timeout, "resultDetails", "timeSpent", "isFocusedOut")
SELECT a.value, a.result, a."assessmentId", a."challengeId", a.timeout, a."resultDetails", a."timeSpent", a."isFocusedOut"
FROM answers a
WHERE id = 100;

SELECT id, value, "createdAt"
FROM answers a
WHERE id >= 100
ORDER BY id DESC;

SELECT id, value, "createdAt"
FROM answers_bigint
WHERE id >= 100
ORDER BY id DESC;

-- Missing 102

INSERT INTO answers_bigint
SELECT * FROM answers WHERE id > 101 AND id <= 102;
-- START_ID and END_ID


SELECT id, value, "createdAt"
FROM answers
ORDER BY id DESC;

SELECT id, value, "createdAt"
FROM answers_bigint
ORDER BY id DESC;

-- MAINTENANCE WINDOW

-------------------------------------------------------------------------------------
-------- Expose changes
-------------------------------------------------------------------------------------

-- LOCK TABLE "answers" IN ACCESS EXCLUSIVE MODE;

ALTER SEQUENCE "answers_id_seq" OWNED BY "answers_bigint"."id";
ALTER SEQUENCE "answers_id_seq" AS bigint;
ALTER TABLE "answers_bigint" ALTER COLUMN "id" SET DEFAULT nextval('answers_id_seq');

DROP TABLE answers;
ALTER TABLE "answers_bigint" RENAME TO "answers";


DROP TABLE "knowledge-elements";
ALTER TABLE "knowledge-elements_bigint" RENAME TO "knowledge-elements";

-- COMMIT to release lock

-- Simulate activity
INSERT INTO answers (value, result, "assessmentId", "challengeId", timeout, "resultDetails", "timeSpent", "isFocusedOut")
SELECT a.value, a.result, a."assessmentId", a."challengeId", a.timeout, a."resultDetails", a."timeSpent", a."isFocusedOut"
FROM answers a
WHERE id = 100;

SELECT id, value, "createdAt"
FROM answers
ORDER BY id DESC;

-- rename constraints and indexes ?
-- Indexes:
--     "answers_bigint_pkey" PRIMARY KEY, btree (id)
--     "answers_bigint_assessmentid_index" btree ("assessmentId")
-- Foreign-key constraints:
--     "answers_bigint_assessmentid_foreign" FOREIGN KEY ("assessmentId") REFERENCES assessments(id)
-- Referenced by:
--     TABLE ""knowledge-elements"" CONSTRAINT "knowledge_elements_bigint_answerid_foreign" FOREIGN KEY ("answerId") REFERENCES answers(id)


ALTER TABLE "answers" RENAME CONSTRAINT "answers_bigint_assessmentid_foreign" TO "answers_assessmentid_foreign";
ALTER TABLE "answers" RENAME CONSTRAINT "answers_bigint_pkey" TO "answers_pkey";

ALTER TABLE "knowledge-elements" RENAME CONSTRAINT "knowledge_elements_bigint_answerid_foreign" TO "knowledge_elements_answerid_foreign";