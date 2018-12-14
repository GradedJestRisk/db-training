

with identifiers as
( select name
  ,      type
  ,      usage
  ,      line
  ,      first_value(line) over (partition by name, usage order by line asc) first_line
  ,      first_value(line) over (partition by name, usage order by line desc) last_line
  from   all_identifiers
  where  1=1
     AND  owner = 'DBOFAP'
     AND object_name = UPPER('PKG_GEN_FILIERE')
 -- and    object_type = 'PROCEDURE'
  and    type        = 'VARIABLE'
)
, last_assignments -- the last assignment of every identifier
as
( select *
  from   identifiers
  where  usage = 'ASSIGNMENT'
  and    line = last_line
)
, last_references  -- the last reference of every identifier
as
( select *
  from   identifiers
  where  usage = 'REFERENCE'
  and    line = last_line
)
, first_references -- the first reference of every identifier
as
( select *
  from   identifiers
  where  usage = 'REFERENCE'
  and    line = first_line
)
, first_assignments -- the first assignment of every identifier
as
( select *
  from   identifiers
  where  usage = 'ASSIGNMENT'
  and    line = first_line
)
, declarations     -- the declaration for every identifier
as
( select *
  from   identifiers
  where  usage = 'DECLARATION'
)
-- now outer join last_assignments with last_references: when no ass, then warn ref but not ass;
-- when no ref the warn: ass but no ref;
-- when ass.line > ref.line then warn: assignment on line is never used
select case
       when la.line is null
       then name||': reference on line '||lr.line||' but variable may not be initialized (assigned a value)'
       when  lr.line is null
       then name||': a value is assigned, but there is no reference to the variable'
       when la.line > lr.line
       then name||': assignment on line '||la.line||' is never used. Last reference to the variable is on line '||lr.line
       end compiler_warning
from   last_assignments la
       full outer join
       last_references  lr
       using  (name)
union all
-- now outer join first_assignments with first_references:
-- when ass.line > ref.line then warn: reference before any assignment is done
select case
       when fa.line > fr.line
       then name||': reference to variable on line '||fr.line||' comes before the earliest assignment. Variable may not have been initialized on line '||fr.line
       end compiler_warning
from   first_assignments fa
       full outer join
       first_references  fr
       using  (name)
union all
-- now outer join delarations with last_references:
-- when no ref then warn: variable declared but never used;
-- when ref but no declaration should not occur ;(for local identifiers) nor should declaration.line > ref.line
select case
       when fr.line is null
       then name||': variable is declared but never used (line '||de.line||')'
       end compiler_warning
from   declarations de
       full outer join
       last_references  fr
       using  (name)
--order
--by     name
;
