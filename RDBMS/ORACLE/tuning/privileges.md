

Available (connect as SYS)
```oracle
select * from system_privilege_map
where 1=1
--     AND name LIKE '%ADM%'
--     AND name LIKE '%TUN%'
    AND name LIKE '%PROFILE%'
```