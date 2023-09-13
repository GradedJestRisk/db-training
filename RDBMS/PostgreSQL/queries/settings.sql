SELECT setting
FROM pg_settings stt
WHERE 1=1
    AND stt.name = 'server_version'
;

SELECT setting FROM pg_settings WHERE name = 'server_version'
;

SHOW server_version;
