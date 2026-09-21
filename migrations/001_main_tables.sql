create table if not exists ranks(
id int primary key,
rank text
);

comment on table ranks is 'Справочник военных званий';
comment on column ranks.rank is 'Название звания';

create table if not exists devices(
id int primary key,
name text
);

comment on table devices is 'Справочник типов оборудования для измерений';
comment on column devices.name is 'Название оборудования';

create table if not exists soldiers(
id int primary key,
personal_id int,
rank_id int
);

comment on table soldiers is 'Справочник военнослужащих';
comment on column soldiers.personal_id is 'Личный номер военнослужащего';
comment on column soldiers.rank_id is 'Звание военнослужащего из ranks';

create table if not exists parameters(
id int primary key,
device_id int,
height int,
temp numeric(3, 1) check (temp between -58.0 and 58.0),
atm_press int check (atm_press between 500 and 900),
dir_wind int check (dir_wind between 0 and 59),
speed_wind int check (speed_wind between 0 and 15),
bullet_dist int check (bullet_dist between 0 and 150),

check ((device_id = 1 and speed_wind is not null and bullet_dist is null) or
(device_id = 2 and speed_wind is null and bullet_dist is not null))
);

comment on table parameters is 'Параметры метеоизмерения для расчёта';
comment on column parameters.device_id is 'Тип оборудования для расчёта из devices';
comment on column parameters.height is 'Высота метеопоста над уровнем моря, м';
comment on column parameters.temp is 'Температура воздуха, (-58.0 … 58.0)';
comment on column parameters.atm_press is 'Атмосферное давление, мм рт.ст. (500 … 900)';
comment on column parameters.dir_wind is 'Направление ветра, деления угломера (0 … 59)';
comment on column parameters.speed_wind is 'Скорость ветра, м/с (0 … 15). Только для ДМК';
comment on column parameters.bullet_dist is 'Дальность сноса пуль, м (0 … 150). Только для ВР';

create table if not exists batch(
id int primary key,
soldier_id int,
parameter_id int,
measured_at timestamptz default now()
);

comment on table batch is 'История измерений(кто, параметры и дата)';
comment on column batch.soldier_id is 'Военнослужащий из soldiers';
comment on column batch.parameter_id is 'Параметры из parameters';
comment on column batch.measured_at is 'Дата и время измерения';

insert into ranks(id, rank) values
(1, 'рядовой'),
(2, 'ефрейтор'),
(3, 'младший сержант'),
(4, 'сержант'),
(5, 'старший сержант'),
(6, 'старшина'),
(7, 'прапорщик'),
(8, 'старший прапорщик'),
(9, 'младший лейтенант'),
(10, 'лейтенант'),
(11, 'старший лейтенант'),
(12, 'капитан')
on conflict (id) do nothing;

insert into soldiers(id, personal_id, rank_id) values
(1, 32589, 2),
(2, 59589, 5),
(3, 19589, 1),
(4, 92589, 7),
(5, 73589, 10)
on conflict (id) do nothing;

insert into devices(id, name) values
(1, 'ДМК'),
(2, 'ВР')
on conflict (id) do nothing;

insert into parameters(id, device_id, height, temp, atm_press, dir_wind, speed_wind, bullet_dist) values
(1, 1, 100, 15.0, 750, 0, 0, NULL),
(2, 1, 150, -10.5, 745, 12, 5, NULL),
(3, 2, 200, 25.0, 765, 15, NULL, 30),
(4, 2, 100, 15.0, 750, 0, NULL, 0),
(5, 1, 300, 30.5, 800, 45, 10, NULL)
on conflict (id) do nothing;

insert into batch(id, soldier_id, parameter_id, measured_at) values
(1, 1, 1, '2026-09-20 08:00:00+08'),
(2, 2, 2, '2026-09-21 08:00:00+08'),
(3, 3, 3, '2026-09-21 10:00:00+08'),
(4, 4, 4, '2026-09-21 12:00:00+08'),
(5, 5, 5, '2026-09-21 14:00:00+08')
on conflict (id) do nothing;