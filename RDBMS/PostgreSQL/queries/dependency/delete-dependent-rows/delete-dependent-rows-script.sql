-- Originally from Joe Love -  https://stackoverflow.com/questions/129265/cascade-delete-just-once
create or replace function delete_dependent_rows(p_schema varchar, p_table varchar, p_key varchar,
                                                 p_recursion varchar[] default null)
    returns integer as
$$
declare
    rx              record;
    rd              record;
    v_sql           varchar;
    v_recursion_key varchar;
    recnum          integer;
    v_primary_key   varchar;
    v_rows          integer;
begin
    recnum := 0;
    select
        ccu.column_name
    into v_primary_key
    from information_schema.table_constraints tc
             join information_schema.constraint_column_usage AS ccu
                  ON ccu.constraint_name = tc.constraint_name and ccu.constraint_schema = tc.constraint_schema
                      and tc.constraint_type = 'PRIMARY KEY'
                      and tc.table_name = p_table
                      and tc.table_schema = p_schema;

    for rx in (
        select
            kcu.table_name   as foreign_table_name,
            kcu.column_name  as foreign_column_name,
            kcu.table_schema    foreign_table_schema,
            kcu2.column_name as foreign_table_primary_key
        from information_schema.constraint_column_usage ccu
                 join information_schema.table_constraints tc
                      on tc.constraint_name = ccu.constraint_name and tc.constraint_catalog = ccu.constraint_catalog and
                         ccu.constraint_schema = ccu.constraint_schema
                 join information_schema.key_column_usage kcu on kcu.constraint_name = ccu.constraint_name and
                                                                 kcu.constraint_catalog = ccu.constraint_catalog and
                                                                 kcu.constraint_schema = ccu.constraint_schema
                 join information_schema.table_constraints tc2
                      on tc2.table_name = kcu.table_name and tc2.table_schema = kcu.table_schema
                 join information_schema.key_column_usage kcu2 on kcu2.constraint_name = tc2.constraint_name and
                                                                  kcu2.constraint_catalog = tc2.constraint_catalog and
                                                                  kcu2.constraint_schema = tc2.constraint_schema
        where ccu.table_name = p_table
          and ccu.table_schema = p_schema
          and TC.CONSTRAINT_TYPE = 'FOREIGN KEY'
          and tc2.constraint_type = 'PRIMARY KEY'
    )
        loop
            v_sql := 'select "' || rx.foreign_table_primary_key || '" as key from "' || rx.foreign_table_schema ||
                     '"."' || rx.foreign_table_name || '"
            where "' || rx.foreign_column_name || '"=' || quote_literal(p_key) || ' for update';
            raise notice '%',v_sql;
            --found a foreign key, now find the primary keys for any data that exists in any of those tables.
            for rd in execute v_sql
                loop
                    v_recursion_key = rx.foreign_table_schema || '.' || rx.foreign_table_name || '.' ||
                                      rx.foreign_column_name || '=' || rd.key;
                    if (v_recursion_key = any (p_recursion)) then
                        raise notice 'Avoiding infinite loop';
                    else
                        raise notice 'Recursing to %,%',rx.foreign_table_name, rd.key;
                        recnum := recnum + delete_dependent_rows(rx.foreign_table_schema::varchar,
                                                          rx.foreign_table_name::varchar, rd.key::varchar,
                                                          p_recursion || v_recursion_key);
                    end if;
                end loop;
        end loop;
    begin
        --actually delete original record.
        v_sql := 'delete from ' || p_schema || '."' || p_table || '" where ' || v_primary_key || '=' ||
                 quote_literal(p_key);
        execute v_sql;
        get diagnostics v_rows= row_count;
        raise notice 'Deleting %.% %=%',p_schema,p_table,v_primary_key,p_key;
        recnum := recnum + v_rows;
    exception
        when others then recnum = 0;
    end;

    return recnum;
end;
$$
    language PLPGSQL;

