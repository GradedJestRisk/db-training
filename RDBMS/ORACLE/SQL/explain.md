# Execution plan

Create plan
```oracle
EXPLAIN PLAN FOR SELECT * FROM dual;
```

Display all
```oracle
SELECT * FROM PLAN_TABLE;
```

Display last
```oracle
SELECT * FROM table(dbms_xplan.display);
```