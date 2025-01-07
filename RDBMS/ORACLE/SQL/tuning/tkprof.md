
```oracle
BEGIN
    dbms_session.session_trace_enable(waits     => TRUE,
                                      binds     => TRUE,
                                      plan_stat => 'all_executions');
END;
/
```