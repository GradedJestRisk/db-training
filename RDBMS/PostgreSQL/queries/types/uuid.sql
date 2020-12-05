CREATE EXTENSION "uuid-ossp";

SELECT uuid_generate_v4();

SELECT random() * 100;

SELECT
       generate_series( 1, 100)
;


CREATE EXTENSION IF NOT EXISTS pgcrypto;

SELECT
  encode(sha256('FOO'), 'hex')
;
