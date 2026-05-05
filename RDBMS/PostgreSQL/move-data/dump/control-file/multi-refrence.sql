CREATE TABLE test (id int NOT NULL PRIMARY KEY);
INSERT INTO test (id) VALUES (1);
INSERT INTO test (id) VALUES (2);
CREATE TABLE referencing (id INTEGER PRIMARY KEY REFERENCES TEST);
INSERT INTO referencing (id) VALUES (1);
INSERT INTO referencing (id) VALUES (2);
CREATE TABLE referencing_referencing (id INTEGER PRIMARY KEY REFERENCES referencing);
INSERT INTO referencing_referencing (id) VALUES (1)');
