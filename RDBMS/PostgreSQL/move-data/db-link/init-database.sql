CREATE DATABASE source_database;
CREATE USER source_user PASSWORD 'source_user_password';
GRANT ALL PRIVILEGES ON DATABASE source_database TO source_user;

CREATE DATABASE target_database;
CREATE USER target_user PASSWORD 'target_user_password'';
GRANT ALL PRIVILEGES ON DATABASE target_database TO target_user;
