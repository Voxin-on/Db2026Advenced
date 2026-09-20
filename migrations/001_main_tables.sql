create table if not exists ranks(
id int primary key,
rank text
);

create table if not exists devices(
id int primary key,
name text
);

create table if not exists soldiers(
id int primary key,
personal_id int,
rank_id int
);

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

create table if not exists batch(
id int primary key,
soldier_id int,
parameter_id int
);

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

insert into batch(id, soldier_id, parameter_id) values
(1, 1, 1),
(2, 2, 2),
(3, 3, 3),
(4, 4, 4),
(5, 5, 5)
on conflict (id) do nothing;