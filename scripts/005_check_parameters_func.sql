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
    (2, 'Температура вне диапазона -58..58'),
    (3, 'Давление вне диапазона 500..900'),
    (4, 'Направление ветра вне диапазона 0..59'),
    (5, 'Скорость ветра вне диапазона 0..15'),
    (6, 'Дальность сноса пуль вне диапазона 0..150'),
    (7, 'Неверный тип параметра для данного оборудования'),
    (8, 'Неверная единица измерения');
commit;

create or replace function public.validate_parameters(
    p_set public.parameter_set
)
returns text
language plpgsql
as $func1$
declare
    v_errors text := '';
begin
    -- Проверка на null
    if p_set.height is null or p_set.temp is null or p_set.atm_press is null or 
       p_set.dir_wind is null or p_set.device_id is null then
        v_errors := v_errors || 'Значение NULL; ';
    end if;

    -- Проверка диапазонов
    if p_set.temp is not null and (p_set.temp < -58 or p_set.temp > 58) then
        v_errors := v_errors || 'Температура вне диапазона -58..58; ';
    end if;

    if p_set.atm_press is not null and (p_set.atm_press < 500 or p_set.atm_press > 900) then
        v_errors := v_errors || 'Давление вне диапазона 500..900; ';
    end if;

    if p_set.dir_wind is not null and (p_set.dir_wind < 0 or p_set.dir_wind > 59) then
        v_errors := v_errors || 'Направление ветра вне 0..59; ';
    end if;

    -- Проверка логики оборудования (ДМК/ВР)
    if p_set.device_id = 1 then
        if p_set.speed_wind is null then
            v_errors := v_errors || 'Отсутствует скорость ветра для ДМК; ';
        elsif p_set.speed_wind < 0 or p_set.speed_wind > 15 then
            v_errors := v_errors || 'Скорость ветра вне 0..15; ';
        end if;
        
        if p_set.bullet_dist is not null then
            v_errors := v_errors || 'Дальность не должна заполняться для ДМК; ';
        end if;

    elsif p_set.device_id = 2 then
        if p_set.bullet_dist is null then
            v_errors := v_errors || 'Отсутствует дальность для ВР; ';
        elsif p_set.bullet_dist < 0 or p_set.bullet_dist > 150 then
            v_errors := v_errors || 'Дальность вне 0..150; ';
        end if;

        if p_set.speed_wind is not null then
            v_errors := v_errors || 'Скорость не должна заполняться для ВР; ';
        end if;
    else
        v_errors := v_errors || 'Неизвестный тип оборудования; ';
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