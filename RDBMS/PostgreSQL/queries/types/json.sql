-- https://clarkdave.net/2013/06/what-can-you-do-with-postgresql-and-json/

-- Insert
CREATE TABLE books (
  id   SERIAL NOT NULL,
  data JSON
);

INSERT INTO books VALUES (1, '{"title": "Sleeping Beauties", "genres": ["Fiction", "Thriller", "Horror"], "published": false}');
INSERT INTO books VALUES (2, '{"title": "Influence", "genres": ["Marketing & Sales", "Self-Help ", "Psychology"], "published": true}');


-- Display
SELECT
    data->'title' AS title,
    data
FROM books;

-- Output (multiple lines)
SELECT b.* FROM books b;

-- Output (single line)
SELECT json_agg(b.*) FROM books b;