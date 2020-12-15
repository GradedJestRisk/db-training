--complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION nvlfunc" to load this file. \quit
 
CREATE OR REPLACE FUNCTION public.NVL(SMALLINT,SMALLINT)
RETURNS SMALLINT AS $$
SELECT COALESCE($1,$2);
$$ LANGUAGE SQL IMMUTABLE;
