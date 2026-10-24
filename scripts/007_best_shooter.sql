with batch_parameters as (
    -- Переворот из строк в столбцы
    select 
        b.id as batch_id,
        b.soldier_id,
        b.device_id,
        max(case when p.type_par_id = 1 then p.value end) as height,
        max(case when p.type_par_id = 2 then p.value end) as temp,
        max(case when p.type_par_id = 3 then p.value end) as atm_press,
        max(case when p.type_par_id = 4 then p.value end) as dir_wind,
        max(case when p.type_par_id = 5 then p.value end) as speed_wind,
        max(case when p.type_par_id = 6 then p.value end) as bullet_dist
    from batch b
    left join parameters p on p.batch_id = b.id
    group by b.id, b.soldier_id, b.device_id
),
batch_errors as (
    -- Проверяем каждую пачку
    select 
        bp.soldier_id,
        public.validate_parameters(
            row(bp.height, bp.temp, bp.atm_press, bp.dir_wind, bp.speed_wind, bp.bullet_dist, bp.device_id)::parameter_set
        ) as error_text
    from batch_parameters bp
),
soldier_stats as (
    -- Суммируем кол-во ошибок по стрелкам
    select 
        soldier_id,
        count(*) as total_batches,
        sum(
            case 
                when error_text is null then 0 
                -- Считаем кол-во ';' и прибавляем 1 потому что последня ; убирается
                else (length(error_text) - length(replace(error_text, ';', '')) + 1)
            end
        ) as total_errors
    from batch_errors
    group by soldier_id
)
-- Результат
select 
    s.personal_id as "Личный номер",
    st.total_errors as "Количество ошибок",
    st.total_batches as "Всего пачек",
    rank() over (order by st.total_errors asc) as "Место"
from soldier_stats st
join soldiers s on s.id = st.soldier_id
order by "Место", s.personal_id;