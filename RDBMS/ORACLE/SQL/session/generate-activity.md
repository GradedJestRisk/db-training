# Generate activity

30 s
```oracle
with /* slow */ rws as (
        select rownum x from dual connect by level <= 1000
   )
        select count(*) from rws, rws, rws;
```