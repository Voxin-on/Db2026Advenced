with batch_parameters as (
    -- Переворот из строк в столбцы
    select 
        b.id as batch_id,
        b.device_id,
        max(case when p.type_par_id = 1 then p.value end) as height,
        max(case when p.type_par_id = 2 then p.value end) as temp,
        max(case when p.type_par_id = 3 then p.value end) as atm_press,
        max(case when p.type_par_id = 4 then p.value end) as dir_wind,
        max(case when p.type_par_id = 5 then p.value end) as speed_wind,
        max(case when p.type_par_id = 6 then p.value end) as bullet_dist
    from batch b
    left join parameters p on p.batch_id = b.id
    group by b.id, b.device_id
),
validated_data as (
    -- Передача параметров в функцию
    select 
        batch_id,
        device_id,
        height,
        temp,
        atm_press,
        dir_wind,
        speed_wind,
        bullet_dist,
        row(height, temp, atm_press, dir_wind, speed_wind, bullet_dist, device_id)::parameter_set as p_set,
        public.validate_parameters(
            row(height, temp, atm_press, dir_wind, speed_wind, bullet_dist, device_id)::parameter_set
        ) as error_desc
    from batch_parameters
)
-- Результат
select 
    row_number() over (order by v.batch_id) as "№",
    d.name as "Тип оборудования",
    v.height as "Высота метеопоста",
    v.temp as "Температура",
    v.atm_press as "Давление",
    v.dir_wind as "Направление ветра",
    v.speed_wind as "Скорость ветра",
    v.bullet_dist as "Дальность сноса пуль",
    case when v.error_desc is not null then 'Да' else 'Нет' end as "Флаг: Есть ошибка",
    coalesce(v.error_desc, '') as "Описание ошибки"
from validated_data v
join devices d on d.id = v.device_id
order by v.batch_id;