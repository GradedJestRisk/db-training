-- INSERT
INSERT INTO users ( "firstName", "lastName", password)
SELECT  "firstName" || ' junior', "lastName", password
FROM users WHERE password IS NOT NULL
RETURNING *
;


-- UPDATE
UPDATE users
SET "firstName" = 'Juan'
WHERE 1=1
  AND id IN (1, 3)
--  AND email = 'user3pix@example.net'
RETURNING *
;

-- DELETE
DELETE FROM "knowledge-elements"
WHERE 1=1
  AND id IN (100497, 100495)
RETURNING *
;
