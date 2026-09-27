drop table if exists unit_meas;
drop table if exists base_unit_meas;
drop table if exists type_parameter;
drop table if exists parameters_new;

-- базовые единиц
create table base_unit_meas (
id int primary key,
name text
);
comment on table base_unit_meas is 'Справочник базовых единиц измерения';
comment on column base_unit_meas.id is 'Уникальный код ед. измерения';
comment on column base_unit_meas.name is 'Единица измерения';

insert into base_unit_meas (id, name) values 
(1, 'Длина'),
(2, 'Температура'),
(3, 'Давление'),
(4, 'Угол'),
(5, 'Скорость');

-- все единицы измерения
create table unit_meas (
id int primary key,
base_id int,
name text,
factor numeric
);

comment on table unit_meas is 'Справочник всех единиц измерения';
comment on column unit_meas.id is 'Уникальный код ед. измерения';
comment on column unit_meas.name is 'Единица измерения';
comment on column unit_meas.base_id is 'Уникальный код базовой единицы';
comment on column unit_meas.factor is 'Коэфицент от базовой единицы';

insert into unit_meas (id, name, base_id, factor) values 
(1, 'м', 1, 1),
(2, 'цельсия', 2, 1),
(3, 'мм рт. ст.', 3, 1),
(4, 'деления угломера', 4, 1),
(5, 'м/c', 5, 1);

-- тип параметра
create table type_parameter (
id int primary key,
name text
);

comment on table type_parameter is 'Справочник типов параметров для измерения';
comment on column type_parameter.id is 'Уникальный код типа параметра';
comment on column type_parameter.name is 'Тип параметра';

insert into type_parameter (id, name) values
(1, 'Высота'),
(2, 'Температура'),
(3, 'Атмосферное давление'),
(4, 'Направление ветра'),
(5, 'Скорость ветра'),
(6, 'Дальность сноса пуль');

-- новая таблица параметров для переноса
create table parameters_new (
id serial primary key,
batch_id int,
type_par_id int,
unit_meas_id int,
value numeric
);

comment on table parameters_new is 'Параметры метоизмерения для расчёта';
comment on column parameters_new.id is 'Уникальный код параметра';
comment on column parameters_new.batch_id is 'Уникальный код пачка';
comment on column parameters_new.type_par_id is 'Уникальный код типа параметра';
comment on column parameters_new.unit_meas_id is 'Уникальный код ед. измерения';
comment on column parameters_new.value is 'Значение параметра';

-- перенос параметров из старой таблицы
insert into parameters_new (batch_id, type_par_id, unit_meas_id, value)
select id, 1, 1, height from parameters where height is not null
union all
select id, 2, 2, temp from parameters where temp is not null
union all
select id, 3, 3, atm_press from parameters where atm_press is not null
union all
select id, 4, 4, dir_wind from parameters where dir_wind is not null
union all
select id, 5, 5, speed_wind from parameters where speed_wind is not null
union all
select id, 6, 1, bullet_dist from parameters where bullet_dist is not null;

-- добавление девайса колонки в кучу
alter table batch add column device_id int;
comment on column batch.device_id is 'Уникальный код устройства';
-- перенос девайса в кучу
update batch set device_id = parameters.device_id
from parameters where parameters.id = batch.parameter_id;

-- удаление старой таблицы и столбца
drop table parameters;
alter table batch drop column parameter_id;

-- переименование таблицы в параметра после переноса
alter table parameters_new rename to parameters;

-- итоговый запрос
select batch.measured_at, batch.id, soldiers.personal_id, 
type_parameter.name || ' и ' || unit_meas.name , parameters.value
from parameters
join batch on parameters.batch_id = batch.id
join soldiers on batch.soldier_id = soldiers.id
join type_parameter on parameters.type_par_id = type_parameter.id
join unit_meas on parameters.unit_meas_id = unit_meas.id