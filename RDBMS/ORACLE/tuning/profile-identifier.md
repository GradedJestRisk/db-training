# Profile identifier 

You need these privileges first.
```oracle
GRANT execute ON sys.dbms_session TO USERNAME;
GRANT execute ON sys.dbms_monitor TO USERNAME;
```

Create trace.
```oracle
CALL dbms_session.set_identifier('identifier');

CALL DBMS_MONITOR.CLIENT_ID_TRACE_ENABLE(
        client_id => 'identifier' ,
        waits     => TRUE,
        binds     => TRUE,
        plan_stat => 'all_executions');

INSERT INTO simple_table VALUES(5);

CALL dbms_monitor.client_id_trace_disable(client_id => 'identifier');
```

Then run profiler on generated trace.