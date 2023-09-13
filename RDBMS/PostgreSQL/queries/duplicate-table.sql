-----------------------------------
-- Duplicate table               --
-----------------------------------

DROP TABLE new_foo;

-- Structure
CREATE TABLE new_foo AS TABLE foo WITH NO DATA;

CREATE TABLE new_foo (
    LIKE foo
--     INCLUDING DEFAULTS
--     INCLUDING CONSTRAINTS
--     INCLUDING INDEXES
    INCLUDING ALL
);


-- Structure and data
CREATE TABLE new_foo AS TABLE foo;


SELECT * FROM new_foo
;

-- Copy data manually
INSERT INTO new_foo SELECT * FROM foo
;
