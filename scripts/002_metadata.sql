select row_number() over(order by obj_type, obj_name) as №, obj_name, obj_type from (
select table_name as obj_name, table_type as obj_type 
from information_schema.tables
where table_catalog = current_database() and 
table_schema = 'public'

union all

select sequence_name as obj_name, 'SEQUENCE' as obj_type 
from information_schema.sequences
where sequence_catalog = current_database() and 
sequence_schema = 'public'

union all

select constraint_name as obj_name, constraint_type as obj_type 
from information_schema.table_constraints
where constraint_catalog = current_database() and
constraint_schema = 'public'

)t;