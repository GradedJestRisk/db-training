
select 
   a.index_owner, 
   a.table_name,
   a.column_name, 
   a.index_name index_name1, 
   b.index_name index_name2, 
   a.column_position position,

  (select 
      'YES' 
   from 
      dba_ind_columns x, 
      dba_ind_columns y 
   where 
      x.index_owner = a.index_owner 
   and 
      y.index_owner = b.index_owner

   and 
      x.index_name = a.index_name 
   and 
      y.index_name = b.index_name 
   and 
      x.column_position = 2 
   and 
      y.column_position = 2

   and 
      x.column_name = y.column_name) nextcol

from 
   dba_ind_columns a,

   dba_ind_columns b

where 
   a.index_owner not in ('SYS', 'SYSMAN', 'SYSTEM', 'MDSYS', 'WMSYS', 'TSMSYS', 'DBSNMP')

and 
   a.index_owner = b.index_owner

and 
   a.column_name = b.column_name

and 
   a.table_name = b.table_name

and 
   a.index_name != b.index_name

and 
   a.column_position = 1

and 
   b.column_position = 1
;
select /*+ rule */ 
   a.table_owner, 
   a.table_name, 
   a.index_owner, 
   a.index_name, 
   column_name_list, 
   column_name_list_dup, 
   dup duplicate_indexes, 
   i.uniqueness, 
   i.partitioned, 
   i.leaf_blocks, 
   i.distinct_keys, 
   i.num_rows, 
   i.clustering_factor 
from 
  ( 
   select 
      table_owner, 
      table_name, 
      index_owner, 
      index_name, 
      column_name_list_dup, 
      dup, 
      max(dup) OVER 
       (partition by table_owner, table_name, index_name) dup_mx 
   from 
      ( 
       select 
          table_owner, 
          table_name, 
          index_owner, 
          index_name, 
          substr(SYS_CONNECT_BY_PATH(column_name, ','),2)   
          column_name_list_dup, 
          dup 
       from 
          ( 
          select 
            index_owner, 
            index_name, 
            table_owner, 
            table_name, 
            column_name, 
            count(1) OVER 
             (partition by 
                 index_owner, 
                 index_name) cnt, 
             ROW_NUMBER () OVER 
               (partition by 
                  index_owner, 
                  index_name 
                order by column_position) as seq, 
             count(1) OVER 
               (partition by 
                  table_owner, 
                  table_name, 
                  column_name, 
                  column_position) as dup 
   from 
      sys.dba_ind_columns 
   where 
      index_owner not in ('SYS', 'SYSTEM')) 
where 
   dup!=1 
start with seq=1 
connect by prior seq+1=seq 
and prior index_owner=index_owner 
and prior index_name=index_name 
)) a, 
( 
select 
   table_owner, 
   table_name, 
   index_owner, 
   index_name, 
   substr(SYS_CONNECT_BY_PATH(column_name, ','),2) column_name_list 
from 
( 
select index_owner, index_name, table_owner, table_name, column_name, 
count(1) OVER ( partition by index_owner, index_name) cnt, 
ROW_NUMBER () OVER ( partition by index_owner, index_name order by column_position) as seq 
from sys.dba_ind_columns 
where index_owner not in ('SYS', 'SYSTEM')) 
where seq=cnt 
start with seq=1 
connect by prior seq+1=seq 
and prior index_owner=index_owner 
and prior index_name=index_name 
) b, dba_indexes i 
where 
    a.dup=a.dup_mx 
and a.index_owner=b.index_owner 
and a.index_name=b.index_name 
and a.index_owner=i.owner 
and a.index_name=i.index_name 
order by 
   a.table_owner, a.table_name, column_name_list_dup;