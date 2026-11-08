do $$
begin
    -- строка корректировок по типу таблицы и высоте
    create or replace function public.fn_get_calc_row(
        p_type_id integer,
        p_height_id integer
    )
    returns integer[]
    language plpgsql
    as $f1$
    declare
        v_row integer[];
    begin
        select c.row_values
        into v_row
        from public.calc_correction c
        where c.type_id = p_type_id
        and c.height_id = p_height_id;

        if v_row is null then
            raise exception 'Нет данных в calc_correction: type_id = %, height_id = %',
            p_type_id, p_height_id;
        end if;

        return v_row;
    end;
    $f1$;


    -- код таблицы корректировок по коду и оборудованию
    create or replace function public.fn_get_type_id(
        p_code text,
        p_device_id integer default null
    )
    returns integer
    language plpgsql
    as $f2$
    declare
        v_id integer;
    begin
        select t.id
        into v_id
        from public.calc_correction_types t
        where t.code = p_code
        and (p_device_id is null or t.measurment_equipment_id = p_device_id);

        if v_id is null then
            raise exception 'Не найден тип таблицы корректировок: %', p_code;
        end if;

        return v_id;
    end;
    $f2$;


    -- отклонение температуры по таблице 2
    create or replace function public.fn_calc_temp_correction(
        p_params public.parameter_set,
        p_height_id integer,
        out p_value integer,
        out p_code integer
    )
    language plpgsql
    as $f3$
    declare
        v_table_temp numeric;
        v_neg_sign numeric;
        v_delta_tv numeric;
        v_t0 numeric;
        v_dt integer;
        v_type_id integer;
        v_row integer[];
        v_rem integer;
        v_part integer;
        v_col integer;
        v_sum integer := 0;
    begin
        select value into v_table_temp from public.meteorology_constants where name = 'table_temp';
        select value into v_neg_sign from public.meteorology_constants where name = 'negative_sign';

        v_delta_tv := public.interpolate_value(
            p_params.temp,
            public.get_temperature_interpolation(p_params.temp)
        );

        v_t0 := p_params.temp + v_delta_tv;
        v_dt := round(v_t0 - v_table_temp)::integer;

        v_type_id := public.fn_get_type_id(
            case
                when v_dt < 0 then 'temp_negative'
                else 'temp_positive'
            end
        );

        v_row := public.fn_get_calc_row(v_type_id, p_height_id);
        v_rem := abs(v_dt);

        while v_rem > 0 loop
            select h.header_value, h.col_index
            into v_part, v_col
            from public.calc_correction_headers h
            where h.type_id = v_type_id
            and h.header_value <= v_rem
            and v_row[h.col_index] is not null
            order by h.header_value desc
            limit 1;

            if v_part is null then
                raise exception 'Не удалось разложить отклонение % для type_id = %',
                    v_dt, v_type_id;
            end if;

            v_sum := v_sum + v_row[v_col];
            v_rem := v_rem - v_part;
        end loop;

        p_value := v_sum;

        if v_dt < 0 then
            p_code := v_neg_sign::integer * 10 + abs(v_sum);
        else
            p_code := v_sum;
        end if;
    end;
    $f3$;


    -- скорость среднего ветра по таблице 3
    create or replace function public.fn_calc_speed_correction(
        p_params public.parameter_set,
        p_height_id integer
    )
    returns integer
    language plpgsql
    as $f4$
    declare
        v_type_id integer;
        v_input numeric;
        v_min_input numeric;
        v_row integer[];
        v_interpolation public.interpolation_temp;
        v_col0 integer;
        v_col1 integer;
    begin
        v_type_id := public.fn_get_type_id('speed', p_params.device_id);

        v_input := coalesce(p_params.speed_wind, p_params.bullet_dist);

        select min(h.header_value)
        into v_min_input
        from public.calc_correction_headers h
        where h.type_id = v_type_id;

        if v_input < v_min_input then
            return 0;
        end if;

        v_row := public.fn_get_calc_row(v_type_id, p_height_id);

        select h.header_value, h.col_index
        into v_interpolation.x0, v_col0
        from public.calc_correction_headers h
        where h.type_id = v_type_id
        and h.header_value <= v_input
        order by h.header_value desc
        limit 1;

        select h.header_value, h.col_index
        into v_interpolation.x1, v_col1
        from public.calc_correction_headers h
        where h.type_id = v_type_id
        and h.header_value >= v_input
        order by h.header_value
        limit 1;

        v_interpolation.y0 := v_row[v_col0];
        v_interpolation.y1 := v_row[v_col1];

        return round(public.interpolate_value(v_input, v_interpolation))::integer;
    end;
    $f4$;


    -- приращение направления по таблице 3
    create or replace function public.fn_calc_direction_correction(
        p_params public.parameter_set,
        p_height_id integer
    )
    returns integer
    language plpgsql
    as $f5$
    declare
        v_type_id integer;
        v_speed_type_id integer;
        v_min_input numeric;
        v_input numeric;
        v_delta integer;
        v_circle integer;
        v_direction integer;
    begin
        v_input := coalesce(p_params.speed_wind, p_params.bullet_dist);
        v_speed_type_id := public.fn_get_type_id('speed', p_params.device_id);

        select min(h.header_value)
        into v_min_input
        from public.calc_correction_headers h
        where h.type_id = v_speed_type_id;

        if v_input < v_min_input then
            return 0;
        end if;

        v_type_id := public.fn_get_type_id('direction', p_params.device_id);

        select c.row_values[1]
        into v_delta
        from public.calc_correction c
        where c.type_id = v_type_id
        and c.height_id = p_height_id;

        select (l.max_value + 1)::integer
        into v_circle
        from public.parameter_limits l
        join public.type_parameter t on t.id = l.type_par_id
        where t.name = 'Направление ветра';

        v_direction := (round(p_params.dir_wind)::integer + v_delta) % v_circle;

        if v_direction < 0 then
            v_direction := v_direction + v_circle;
        end if;

        return v_direction;
    end;
    $f5$;


    -- форматирование вывода строки
    create or replace function public.fn_format_row(
        p_height integer,
        p_temp_value integer,
        p_temp_code integer,
        p_direction integer,
        p_speed integer
    )
    returns text
    language plpgsql
    as $f6$
    begin
        return format(
            'Высота: %s, Код высоты: %s, Откл. темп.: %s (%s), Напр.: %s (%s), Скорость: %s',
            p_height,
            lpad((p_height / 100)::text, 2, '0'),
            p_temp_value,
            lpad(p_temp_code::text, 2, '0'),
            p_direction,
            lpad(p_direction::text, 2, '0'),
            lpad(p_speed::text, 2, '0')
        );
    end;
    $f6$;

    -- процедура расчета по типовым высотам
    create or replace procedure public.calc_meteo11(
        p_params public.parameter_set
    )
    language plpgsql
    as $f7$
    declare
        v_error text;
        v_value integer;
        v_code integer;
        v_direction integer;
        v_speed integer;
        r record;
    begin
        v_error := public.validate_parameters(p_params);

        if v_error is not null then
            raise exception 'Ошибка параметров: %', v_error;
        end if;

        for r in
            select h.id, h.height
            from public.calc_correction_heights h
            order by h.height
        loop
            select t.p_value, t.p_code
            into v_value, v_code
            from public.fn_calc_temp_correction(p_params, r.id) t;

            v_direction := public.fn_calc_direction_correction(p_params, r.id);
            v_speed := public.fn_calc_speed_correction(p_params, r.id);

            raise notice '%',
                public.fn_format_row(r.height, v_value, v_code, v_direction, v_speed);
        end loop;
    end;
    $f7$;

end $$;