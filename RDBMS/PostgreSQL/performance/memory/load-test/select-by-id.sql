WITH t AS
    (SELECT floor(random()*(10000-+1))+ 1 AS id)
SELECT * FROM cacheme c,t WHERE c.id = t.id;