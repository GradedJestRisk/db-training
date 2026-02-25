--
\set sample_data_path `echo "$SAMPLE_DATA_PATH"`

DO $$ begin RAISE NOTICE '=> Create database'; end; $$;
create database bootstrap;

DO $$ begin RAISE NOTICE '=> Connect to database'; end; $$;
\connect bootstrap;

DO $$ begin RAISE NOTICE '=> Create table land_registry_price_paid_uk'; end; $$;
CREATE TABLE land_registry_price_paid_uk(
  transaction uuid,
  price numeric,
  transfer_date date,
  postcode text,
  property_type char(1),
  newly_built boolean,
  duration char(1),
  paon text,
  saon text,
  street text,
  locality text,
  city text,
  district text,
  county text,
  ppd_category_type char(1),
  record_status char(1));

DO $$ begin RAISE NOTICE 'Loading data into land_registry_price_paid_uk'; end; $$;

DO $$ begin RAISE NOTICE 'Starting at %',now(); end; $$;
COPY land_registry_price_paid_uk FROM  :'sample_data_path' WITH (format csv, encoding 'win1252', header false, null '', quote '"', force_null (postcode, saon, paon, street, locality, city, district));
DO $$ begin RAISE NOTICE 'Finished at %',now(); end; $$;

DO $$ begin RAISE NOTICE 'Table record count is:'; end; $$;
SELECT TO_CHAR(COUNT(1), '999 999 999D') records_in_table FROM land_registry_price_paid_uk;

DO $$ begin RAISE NOTICE 'First 5 record are:'; end; $$;
SELECT TO_CHAR(price, '999 999 999D'), transfer_date, postcode FROM land_registry_price_paid_uk LIMIT 5;

DO $$ begin RAISE NOTICE 'Disconnecting..'; end; $$;
\q
