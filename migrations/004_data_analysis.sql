-- Каждый пользователь имеет одинаковое количество измерений?
select t1.cnt as meas_count, string_agg(t1.soldier_id::text, ' ' order by t1.soldier_id) as soldiers from (
	select s.id as soldier_id, count(p.id) as cnt from soldiers s
	left join batch b on s.id = b.soldier_id
	left join parameters p on p.batch_id = b.id 
	group by s.id
)t1
group by t1.cnt
order by t1.cnt;

-- У нас нет пустых пачек измерения?
select b.soldier_id, string_agg(b.id::text, ' ') as empty_batches from batch b
left join parameters p on b.id = p.batch_id
where p.id is null
group by b.soldier_id; 

-- Каждая пачка измерений содержит полное количеситво параметров (5 шт)?
select b.id as batch_id, coalesce(count(distinct p.type_par_id), 0) as type_param_count from batch b
left join parameters p on b.id = p.batch_id
group by b.id
having coalesce(count(distinct p.type_par_id), 0) <> 5;

-- Все значения который сформировал корректны и в рамках нужного нам диаппазонов?
select p.id, p.batch_id, p.type_par_id, um.factor, p.value * um.factor as value_base
from parameters p
join unit_meas um on um.id = p.unit_meas_id
where p.value is null or
(p.type_par_id = 2 and not (p.value * um.factor between -58 and 58)) or
(p.type_par_id = 3 and not (p.value * um.factor between 500 and 900)) or
(p.type_par_id = 4 and not (p.value * um.factor between 0 and 59)) or
(p.type_par_id = 5 and not (p.value * um.factor between 0 and 15)) or
(p.type_par_id = 6 and not (p.value * um.factor between 0 and 150));

-- Все единицы измерения верны и корректны по отношению к указанным параметрам?
select p.id, p.batch_id, tp.name as param, um.name as unit, bum.name as base_unit
from parameters p
join type_parameter tp on tp.id = p.type_par_id
join unit_meas um on um.id = p.unit_meas_id
join base_unit_meas bum on bum.id = um.base_id
where (p.type_par_id = 1 and bum.id <> 1) or
(p.type_par_id = 2 and bum.id <> 2) or
(p.type_par_id = 3 and bum.id <> 3) or
(p.type_par_id = 4 and bum.id <> 4) or
(p.type_par_id = 5 and bum.id <> 5) or
(p.type_par_id = 6 and bum.id <> 1);