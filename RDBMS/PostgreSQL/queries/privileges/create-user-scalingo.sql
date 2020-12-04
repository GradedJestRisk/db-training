-- https://doc.scalingo.com/databases/postgresql/start#database-users

-- Read and write
CREATE USER <username>;
GRANT CREATE ON SCHEMA public TO <username>;
GRANT ALL PRIVILEGES ON DATABASE <database> TO <username>;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO <username>;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO <username>;
ALTER DEFAULT PRIVILEGES FOR USER <database> IN SCHEMA public GRANT ALL ON TABLES TO <username>;
ALTER DEFAULT PRIVILEGES FOR USER <database> IN SCHEMA public GRANT ALL ON SEQUENCES TO <username>;


-- Read only
CREATE USER <username>;
GRANT USAGE ON SCHEMA public TO <username>;
GRANT CONNECT ON DATABASE <database> TO <username>;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO <username>;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO <username>;
ALTER DEFAULT PRIVILEGES FOR USER <database> IN SCHEMA public GRANT SELECT ON TABLES TO <username>;
ALTER DEFAULT PRIVILEGES FOR USER <database> IN SCHEMA public GRANT SELECT ON SEQUENCES TO <username>;
