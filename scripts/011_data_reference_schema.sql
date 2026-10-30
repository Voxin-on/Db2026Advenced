do $$
begin


-- Справочник: Средние отклонения температуры воздуха Таблица 2

-- удаляем счётчик и таблицу если уже существуют
drop table if exists mn_temp_deviations cascade;
drop sequence if exists seq_mn_temp_deviations;

-- создание счётчика и таблицы 2 
create sequence seq_mn_temp_deviations;
create table mn_temp_deviations (
    id int primary key default nextval('seq_mn_temp_deviations'),
    y_height int not null,
    delta_temp int not null,
    val_neg int not null,
    val_pos int not null
);

-- комментарии к таблицы 2
comment on table mn_temp_deviations is 'Справочник средних отклонений температур воздуха';
comment on column mn_temp_deviations.id is 'Уникальный номер среднего отклонения температуры';
comment on column mn_temp_deviations.y_height is 'Стандартные высоты бюллетеня';
comment on column mn_temp_deviations.delta_temp is 'Отклонение приземной виртуальной температуры';
comment on column mn_temp_deviations.val_neg is 'Среднее отклонение температуры для отрицательных значений';
comment on column mn_temp_deviations.val_pos is 'Среднее отклонение температуры для положительных значений';


-- Справочник: Скорость среднего ветра Таблица 3 

-- удаляем счётчик и таблицу если уже существуют
drop table if exists mn_wind_speed cascade;
drop sequence if exists seq_mn_wind_speed;

-- создание счётчика и таблицы 3
create sequence seq_mn_wind_speed;
create table mn_wind_speed (
    id int primary key default nextval('seq_mn_wind_speed'),
    device_id int not null,
    y_height int not null,
    val int not null,
    angle_increment int not null
);

-- комментарии к таблицы 3
comment on table mn_wind_speed is 'Справочник средней скорости ветра';
comment on column mn_wind_speed.id is 'Уникальный номер средней скорости ветра';
comment on column mn_wind_speed.device_id is 'Уникальный номер устройства для проверки значения';
comment on column mn_wind_speed.y_height is 'Стандартные высоты бюллетеня';
comment on column mn_wind_speed.val is 'Значения для расчёта приращения';
comment on column mn_wind_speed.angle_increment is 'Приращение среднего ветра относительно направления приземного ветра';

-- связь с устройством чтобы не дать записать не существующее устройство
alter table mn_wind_speed 
add constraint fk_mn_wind_speed_devices
foreign key (device_id) references devices(id);

end $$;