SELECT * from route;

SELECT * from version;

SELECT * from request r
WHERE r.route_id = '3982a1986dfc13ab3afb61c9cd717dc86edae79a';

SELECT
    rt.text,
    rq.id,
    rq.correlation_id,
    rq.version_id,
--     rq.started_at,
--     rq.ended_at,
    ( rq.ended_at - rq.started_at) duration,
    TRUNC((extract('epoch' from rq.ended_at) - extract('epoch' from rq.started_at)) * 1000 ) duration_millis
FROM
request rq
    INNER JOIN route rt ON rt.id = rq.route_id
WHERE 1=1
-- r.route_id = '3982a1986dfc13ab3afb61c9cd717dc86edae79a';
;


SELECT * from correlation;

SELECT
   rq.id,
   rt.text,
   crr.id,
   v.id
FROM
   request rq
       INNER JOIN route rt ON rt.id = rq.route_id
       INNER JOIN correlation crr ON crr.id = rq.correlation_id
       INNER JOIN version v ON v.id = rq.version_id
WHERE 1=1
   --AND crr.id = '1'
;


SELECT
--   rq.id,
   cr.id   user_id,
   rt.text route,
   v.id    app_version,
   qr.text qry_txt,
   TO_CHAR(TIMESTAMP 'epoch' + qe.start_date * INTERVAL '1 millisecond', 'HH:MI:SS') started_at,
   qe.duration dur_millis
FROM
   request rq
       INNER JOIN route rt ON rt.id = rq.route_id
       INNER JOIN correlation cr ON cr.id = rq.correlation_id
       INNER JOIN version v ON v.id = rq.version_id
       INNER JOIN query_execution qe ON qe.request_id = rq.id
       INNER JOIN query qr ON qr.id = qe.query_id
WHERE 1=1
   AND cr.id = '1'
ORDER BY
   cr.id,
   rt.text,
   v.id,
   qr.text
;


SELECT
--   rq.id,
   cr.id   user_id,
   rt.text route,
   v.id,
   qr.text qry_txt,
   COUNT(1)
FROM
   request rq
       INNER JOIN version v ON v.id = rq.version_id
       INNER JOIN route rt ON rt.id = rq.route_id
       INNER JOIN correlation cr ON cr.id = rq.correlation_id
       INNER JOIN query_execution qe ON qe.request_id = rq.id
       INNER JOIN query qr ON qr.id = qe.query_id
WHERE 1=1
   --AND cr.id = '1'
GROUP BY
   cr.id, rt.text, v.id, qr.text
ORDER BY
   user_id ASC
;


SELECT *
FROM query;


SELECT *
FROM query_execution qe
WHERE 1=1
--AND qe.id = '8d940a02ac8bbd5074d23e2d8da4d37ab34ce836'
;


SELECT
       q.text query_source,
   --    MIN(start_date)
   TO_CHAR(TIMESTAMP 'epoch' + MIN(start_date) * INTERVAL '1 millisecond', 'HH:MI:SS')
   --     start_date
FROM query q
    INNER JOIN query_execution qe ON qe.query_id = q.id
WHERE 1=1
--    AND q.
GROUP BY q.text
;


SELECT
       c.id,
       q.text query_source,
   --    MIN(start_date)
   TO_CHAR(TIMESTAMP 'epoch' + start_date * INTERVAL '1 millisecond', 'HH:MI:SS')
   --     start_date
FROM query q
    INNER JOIN query_execution qe ON qe.query_id = q.id
    INNER JOIN correlation c ON c.id = qe.correlation_id
WHERE 1=1
  --  AND c.id = '2edb79fc-60a1-4da0-86da-66649d9fca0f'
;

SELECT
TIMESTAMP 'epoch' + start_date * INTERVAL '1 millisecond'
FROM query_execution;



-- Per query
SELECT
       q.text                  QUERY_SOURCE,
       COUNT(1)                COUNT,
       TO_CHAR(TIMESTAMP 'epoch' + MIN(start_date) * INTERVAL '1 millisecond', 'HH:MI:SS')      FIRST_EXECUTED,
       TO_CHAR(TIMESTAMP 'epoch' + MAX(start_date) * INTERVAL '1 millisecond', 'HH:MI:SS')      LAST_EXECUTED,
       MIN(qe.duration)        MIN_DURATION,
       MAX(qe.duration)        MAX_DURATION,
       TRUNC(AVG(qe.duration))        AVERAGE_DURATION,
       TRUNC(STDDEV_POP(qe.duration)) STANDARD_DEVIATION
FROM query q
    INNER JOIN query_execution qe ON qe.query_id = q.id
WHERE 1=1
GROUP BY q.text
ORDER BY
    q.text ASC
;

-- Per query, per version
SELECT
       q.text                  QUERY_SOURCE,
       v.id version_no,
       COUNT(1)                COUNT,
       TO_CHAR(TIMESTAMP 'epoch' + MIN(start_date) * INTERVAL '1 millisecond', 'HH:MI:SS')      FIRST_EXECUTED,
       TO_CHAR(TIMESTAMP 'epoch' + MAX(start_date) * INTERVAL '1 millisecond', 'HH:MI:SS')      LAST_EXECUTED,
       MIN(qe.duration)        MIN_DURATION,
       MAX(qe.duration)        MAX_DURATION,
       TRUNC(AVG(qe.duration))        AVERAGE_DURATION,
       TRUNC(STDDEV_POP(qe.duration)) STANDARD_DEVIATION
FROM query q
    INNER JOIN query_execution qe ON qe.query_id = q.id
    INNER JOIN request r on qe.request_id = r.id
    INNER JOIN version v on r.version_id = v.id
WHERE 1=1
GROUP BY
    q.text,
    v.id
ORDER BY
    q.text ASC
;



-- Per route, per version
SELECT
--   rq.id,
   rt.text route,
   v.id version_no,
   MIN(rq_dr.duration_millis),
   MAX(rq_dr.duration_millis),
   TRUNC(AVG(rq_dr.duration_millis)) average
FROM
   (SELECT rq.id, rq.version_id, rq.route_id,
           TRUNC((extract('epoch' from rq.ended_at) - extract('epoch' from rq.started_at)) * 1000 ) duration_millis
    FROM request rq) rq_dr
       INNER JOIN version v ON v.id = rq_dr.version_id
       INNER JOIN route rt ON rt.id = rq_dr.route_id
WHERE 1=1
   --AND cr.id = '1'
GROUP BY
   rt.text, v.id
ORDER BY
    rt.text ASC
;


SELECT *
FROM query_statistics;

SELECT *
FROM query_version_statistics;

SELECT *
FROM route_version_statistics;
