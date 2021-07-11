-- Language
SELECT
  l.*
FROM language l
;

-- Author
SELECT
  a.*
FROM author a
;

-- Book
SELECT
  b.*
FROM book b
;

-- Book-store
SELECT
  bs.*
FROM book_store bs
;

--
SELECT t.*
FROM book_to_book_store t
;