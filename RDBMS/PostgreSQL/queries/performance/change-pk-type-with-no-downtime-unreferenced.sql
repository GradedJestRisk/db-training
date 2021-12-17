DROP TABLE IF EXISTS answers_bigint;

-- Remove when KE is properly handled
DROP TABLE "knowledge-elements";

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

-- Simulate activity
INSERT INTO answers (value, result, "assessmentId", "challengeId", timeout, "resultDetails", "timeSpent", "isFocusedOut")
SELECT a.value, a.result, a."assessmentId", a."challengeId", a.timeout, a."resultDetails", a."timeSpent", a."isFocusedOut"
FROM answers a
WHERE id = 100;

-- LOCK TABLE "answers" IN ACCESS EXCLUSIVE MODE;

SELECT MAX(id) FROM answers;
-- 101 - START_ID


-- Load data to perform BIGINT migration implicitly
INSERT INTO answers_bigint
SELECT * FROM answers;

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

ALTER TABLE ONLY answers_bigint ADD CONSTRAINT answers_bigint_pkey PRIMARY KEY (id);
CREATE INDEX answers_bigint_assessmentid_index ON answers_bigint USING btree ("assessmentId");
ALTER TABLE ONLY answers_bigint  ADD CONSTRAINT answers_bigint_assessmentid_foreign FOREIGN KEY ("assessmentId") REFERENCES assessments(id);


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

-- LOCK TABLE "answers" IN ACCESS EXCLUSIVE MODE;

ALTER SEQUENCE "answers_id_seq" OWNED BY "answers_bigint"."id";
ALTER SEQUENCE "answers_id_seq" AS bigint;
ALTER TABLE "answers_bigint" ALTER COLUMN "id" SET DEFAULT nextval('answers_id_seq');

DROP TABLE answers;
ALTER TABLE "answers_bigint" RENAME TO "answers";

-- COMMIT to release lock

-- Simulate activity
INSERT INTO answers (value, result, "assessmentId", "challengeId", timeout, "resultDetails", "timeSpent", "isFocusedOut")
SELECT a.value, a.result, a."assessmentId", a."challengeId", a.timeout, a."resultDetails", a."timeSpent", a."isFocusedOut"
FROM answers a
WHERE id = 100;

SELECT id, value, "createdAt"
FROM answers
ORDER BY id DESC;
