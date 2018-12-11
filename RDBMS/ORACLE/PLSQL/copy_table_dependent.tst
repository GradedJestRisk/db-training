PL/SQL Developer Test script 3.0
6
begin
  -- Call the procedure
  pkg_ddl_tools.copy_table_dependent(from_table => :from_table,
                                     from_schema => :from_schema,
                                     to_table => :to_table);
end;
3
from_table
1
tbl_test
5
from_schema
1
fap
5
to_table
1
tbl_test_cible
5
0
