-- A
-- Session / By status
--active: executing a query.
--idle: waiting for a new client command.
--idle in transaction: The backend is in a transaction, but is not currently executing a query.

SELECT
  ssn.state,
  COUNT(1)
FROM pg_stat_activity ssn
WHERE 1=1
  AND ssn.backend_type = 'client backend'
GROUP BY ssn.state
;




-- If there is some active session, are they long running ?
-- Session / Active
SELECT
   'session=>'
  ,ssn.pid     session_id
  ,SUBSTRING(ssn.query from 1 for 30) query
  ,TO_CHAR(ssn.query_start,'HH24:MI:SS') query_started_at
  ,TO_CHAR(NOW() - ssn.query_start,'HH24:MI:SS') query_duration
FROM pg_stat_activity ssn
WHERE 1=1
  --AND ssn.pid = 12768
  AND ssn.backend_type = 'client backend'
  AND ssn.state = 'active'
  AND ssn.wait_event IS NULL
  AND pid <> pg_backend_pid() -- Not me
;


-- If there is some waiting session, check for what

-- https://www.postgresql.org/docs/current/monitoring-stats.html#WAIT-EVENT-ACTIVITY-TABLE
-- Session / Waiting
SELECT
   'session=>'
  ,ssn.pid     session_id
  ,SUBSTRING(ssn.query from 1 for 30) query
  ,TO_CHAR(ssn.query_start,'HH24:MI:SS') query_started_at
  ,TO_CHAR(NOW() - ssn.query_start,'HH24:MI:SS') query_duration
  ,ssn.wait_event
  ,ssn.wait_event_type
FROM pg_stat_activity ssn
WHERE 1=1
  --AND ssn.pid = 12768
  AND ssn.backend_type = 'client backend'
  AND ssn.state = 'active'
  AND ssn.wait_event IS NOT NULL
  AND ssn.wait_event_type NOT IN ('IO')
  AND ssn.wait_event_type IN ('Lock', 'LWLock')
  AND pid <> pg_backend_pid() -- Not me
;


Aller-retour en train ou avion

Paris - Bordeaux : 300 € TTC
France – Bordeaux : 350 € TTC
Repas

Midi : pendant la formation, repas pris en charge par Lectra dans notre restaurant d’entreprise.
Soir : 35 € TTC
Hôtels : par nuitée petit-déjeuner compris

Bordeaux/Cestas 100€ TTC

Lectra a négocié des tarifs avec les hôtels suivants :

Holiday Inn Pessac	Quality Suite Bordeaux Mérignac	Quality & Comfort Hotel Bordeaux Gradignan	Le Chalet Lyrique
12bis avenue Antoine Becquerel 33608 Pessac cedex	83 avenue JF Kennedy 33700 Mérignac	Avenue de l'Europe 33170 Gradignan	196 cours du Général de Gaulle 33170 Gradignan
contact@hi-pessac.com	reservation@qualitybordeaux.com	direction.chbg@orange.fr	info@chalet-lyrique.fr
556075959	557532122	556752000	556891159
