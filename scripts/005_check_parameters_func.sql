do $$
begin
    drop table if exists parameter_errors cascade;
    drop sequence if exists seq_parameter_errors;

    create sequence seq_parameter_errors;

    -- Справочник возможных ошибок
    create table parameter_errors (
        id int primary key default nextval('seq_parameter_errors'),
        description text not null
    );

    comment on table parameter_errors is 'Справочник ошибок валидации параметров';
    comment on column parameter_errors.id is 'Уникальный номер ошибки параметра';
    comment on column parameter_errors.description is 'Описание ошибки параметра';

    drop table if exists parameter_limits cascade;

    create table parameter_limits (
        type_par_id int primary key,
        min_value numeric,
        max_value numeric
    );

    comment on table parameter_limits is 'Допустимые границы значений для параметров';
    comment on column parameter_limits.type_par_id is 'Уникальный номер параметра';
    comment on column parameter_limits.min_value is 'Минимальное допустимое значение параметра';
    comment on column parameter_limits.max_value is 'Максимальное допустимое значение параметра';

    drop type if exists parameter_set cascade;

    create type parameter_set as (
        height numeric,
        temp numeric,
        atm_press numeric,
        dir_wind numeric,
        speed_wind numeric,
        bullet_dist numeric,
        device_id int
    );

commit;

    insert into parameter_errors (id, description) values
    (1, 'Значение NULL'),
    (2, 'Температура вне диапазона'),
    (3, 'Давление вне диапазона'),
    (4, 'Направление ветра вне диапазона'),
    (5, 'Скорость ветра вне диапазона'),
    (6, 'Дальность сноса пуль вне диапазона'),
    (7, 'Неверный тип параметра для данного оборудования'),
    (8, 'Неверная единица измерения'),
    (9, 'Отсутствует скорость ветра для ДМК'),
    (10, 'Дальность не должна заполняться для ДМК'),
    (11, 'Отсутствует дальность для ВР'),
    (12, 'Скорость не должна заполняться для ВР');

    insert into parameter_limits (type_par_id, min_value, max_value) values
    (2, -58, 58),
    (3, 500, 900),
    (4, 0, 59),
    (5, 0, 15),
    (6, 0, 150);
commit;

create or replace function public.validate_parameters(
    p_set public.parameter_set
)
returns text
language plpgsql
as $func1$
declare
    v_errors text := '';
    v_min numeric;
    v_max numeric;
    v_err_text text;
begin
    -- Проверка на null
    if p_set.height is null or p_set.temp is null or p_set.atm_press is null or 
       p_set.dir_wind is null or p_set.device_id is null then
        select description into v_err_text from parameter_errors where id = 1;
        v_errors := v_errors || v_err_text || '; ';
    end if;

    -- Проверка диапазонов
    
    -- Температура
    select min_value, max_value into v_min, v_max from parameter_limits where type_par_id = 2;
    if p_set.temp < v_min or p_set.temp > v_max then
        select description into v_err_text from parameter_errors where id = 2;
        v_errors := v_errors || v_err_text || ' (' || v_min || '..' || v_max || '); ';
    end if;

    -- Давление
    select min_value, max_value into v_min, v_max from parameter_limits where type_par_id = 3;
    if p_set.atm_press < v_min or p_set.atm_press > v_max then
        select description into v_err_text from parameter_errors where id = 3;
        v_errors := v_errors || v_err_text || ' (' || v_min || '..' || v_max || '); ';
    end if;

    -- Направление ветра
    select min_value, max_value into v_min, v_max from parameter_limits where type_par_id = 4;
    if p_set.dir_wind < v_min or p_set.dir_wind > v_max then
        select description into v_err_text from parameter_errors where id = 4;
        v_errors := v_errors || v_err_text || ' (' || v_min || '..' || v_max || '); ';
    end if;

    -- Проверка логики оборудования (ДМК/ВР)
    if p_set.device_id = 1 then
        if p_set.speed_wind is null then
            select description into v_err_text from parameter_errors where id = 9;
            v_errors := v_errors || v_err_text || '; ';
        else
            select min_value, max_value into v_min, v_max from parameter_limits where type_par_id = 5;
            if p_set.speed_wind < v_min or p_set.speed_wind > v_max then
                select description into v_err_text from parameter_errors where id = 5;
                v_errors := v_errors || v_err_text || ' (' || v_min || '..' || v_max || '); ';
            end if;
        end if;
        
        if p_set.bullet_dist is not null then
            select description into v_err_text from parameter_errors where id = 10;
            v_errors := v_errors || v_err_text || '; ';
        end if;

    elsif p_set.device_id = 2 then
        if p_set.bullet_dist is null then
            select description into v_err_text from parameter_errors where id = 11;
            v_errors := v_errors || v_err_text || '; ';
        else
            select min_value, max_value into v_min, v_max from parameter_limits where type_par_id = 6;
            if p_set.bullet_dist < v_min or p_set.bullet_dist > v_max then
                select description into v_err_text from parameter_errors where id = 6;
                v_errors := v_errors || v_err_text || ' (' || v_min || '..' || v_max || '); ';
            end if;
        end if;

        if p_set.speed_wind is not null then
            select description into v_err_text from parameter_errors where id = 12;
            v_errors := v_errors || v_err_text || '; ';
        end if;
    else
        select description into v_err_text from parameter_errors where id = 7;
        v_errors := v_errors || v_err_text || '; ';
    end if;

    -- Если нет ошибок вернем null
    if v_errors = '' then
        return null;
    else
        -- Убираем последний символы у последней ошибки
        return rtrim(v_errors, ' ;');
    end if;
end;
$func1$;

end $$;