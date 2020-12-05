-- Connect

-- Connect to database POSTGRES with user POSTGRES (or any user having CREATE DATABASE and CREATE SCHEMA privilege)
DROP DATABASE IF EXISTS database1;
CREATE DATABASE database1;
CREATE USER user1;
GRANT CONNECT ON DATABASE database1 TO user1;
GRANT USAGE ON SCHEMA schema1 TO user1;

\c database1
\connect database1;
\connect database1 user1;
\connect database1 user1 localhost 5432;
