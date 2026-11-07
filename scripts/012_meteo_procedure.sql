do $$
begin
    -- входные параметры
    drop type if exists public.meteo_input_params cascade;

    create type public.meteo_input_params as
    (
        height numeric,
        temp numeric,
        atm_press numeric,
        dir_wind numeric,
        speed_wind numeric,
        bullet_dist numeric
    );

    comment on type public.meteo_input_params is 'Входные параметры для расчета Метео-11';


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


    -- отклонение температуры по таблице 2
    create or replace function public.fn_calc_temp_correction(
        p_type_id integer,
        p_height_id integer,
        p_delta_temp integer,
        out p_value integer,
        out p_code integer
    )
    language plpgsql
    as $f2$
    declare
        v_row integer[];
        v_rem integer;
        v_part integer;
        v_col integer;
        v_sum integer := 0;
    begin
        if p_delta_temp = 0 then
            p_value := 0;
            p_code := 0;
            return;
        end if;

        v_row := public.fn_get_calc_row(p_type_id, p_height_id);
        v_rem := abs(p_delta_temp);

        while v_rem > 0 loop
            select h.header_value, h.col_index
            into v_part, v_col
            from public.calc_correction_headers h
            where h.type_id = p_type_id
            and h.header_value <= v_rem
            and v_row[h.col_index] is not null
            order by h.header_value desc
            limit 1;

            if v_part is null then
                raise exception 'Не удалось разложить отклонение % для type_id = %',
                    p_delta_temp, p_type_id;
            end if;

            v_sum := v_sum + v_row[v_col];
            v_rem := v_rem - v_part;
        end loop;

        p_value := v_sum;

        if p_delta_temp < 0 then
            p_code := abs(v_sum) + 50;
        else
            p_code := v_sum;
        end if;
    end;
    $f2$;


    -- скорость среднего ветра по таблице 3
    create or replace function public.fn_calc_speed_correction(
        p_type_id integer,
        p_height_id integer,
        p_input numeric
    )
    returns integer
    language plpgsql
    as $f3$
    declare
        v_row integer[];
        v_x0 integer;
        v_x1 integer;
        v_i0 integer;
        v_i1 integer;
        v_y0 integer;
        v_y1 integer;
        v_res numeric;
    begin
        v_row := public.fn_get_calc_row(p_type_id, p_height_id);

        select h.header_value, h.col_index
        into v_x0, v_i0
        from public.calc_correction_headers h
        where h.type_id = p_type_id
        and h.header_value <= p_input
        order by h.header_value desc
        limit 1;

        select h.header_value, h.col_index
        into v_x1, v_i1
        from public.calc_correction_headers h
        where h.type_id = p_type_id
          and h.header_value >= p_input
        order by h.header_value
        limit 1;

        if v_x0 is null or v_x1 is null then
            raise exception 'Значение % вне диапазона таблицы type_id = %',
            p_input, p_type_id;
        end if;

        v_y0 := v_row[v_i0];
        v_y1 := v_row[v_i1];

        if v_x1 = v_x0 then
            v_res := v_y0;
        else
            v_res := v_y0 + (p_input - v_x0) * (v_y1 - v_y0)::numeric / (v_x1 - v_x0);
        end if;

        return round(v_res)::integer;
    end;
    $f3$;


    -- приращение направления по таблице 3
    create or replace function public.fn_calc_direction_correction(
        p_type_id integer,
        p_height_id integer
    )
    returns integer
    language plpgsql
    as $f4$
    declare
        v_delta integer;
    begin
        select c.row_values[1]
        into v_delta
        from public.calc_correction c
        where c.type_id = p_type_id
        and c.height_id = p_height_id;

        if v_delta is null then
            raise exception 'Нет данных о направлении: type_id = %, height_id = %',
            p_type_id, p_height_id;
        end if;

        return v_delta;
    end;
    $f4$;


    -- расчет по типовым высотам
    create or replace function public.fn_calc_meteo11(
        p_params public.meteo_input_params,
        p_device_id integer
    )
    returns table
    (
        height integer,
        height_code text,
        temp_deviation integer,
        temp_code text,
        wind_direction integer,
        wind_dir_code text,
        wind_speed integer
    )
    language plpgsql
    as $f5$
    declare
        v_set public.parameter_set;
        v_err text;
        v_dtv numeric;
        v_t0 numeric;
        v_table_temp numeric;
        v_dt integer;
        v_temp_type integer;
        v_speed_type integer;
        v_dir_type integer;
        v_limit numeric;
        v_input numeric;
        v_zero boolean;
    begin
        v_set := row(
            p_params.height,
            p_params.temp,
            p_params.atm_press,
            p_params.dir_wind,
            p_params.speed_wind,
            p_params.bullet_dist,
            p_device_id
        )::public.parameter_set;

        v_err := public.validate_parameters(v_set);

        if v_err is not null then
            raise exception 'Ошибка параметров: %', v_err;
        end if;

        v_dtv := public.interpolate_value(
            p_params.temp,
            public.get_temperature_interpolation(p_params.temp)
        );

        v_t0 := p_params.temp + v_dtv;
        select value into v_table_temp
        from public.meteorology_constants
        where name = 'table_temp';

        v_dt := round(v_t0 - v_table_temp)::integer;
        v_temp_type := case when v_dt < 0 then 9 else 8 end;

        if p_device_id = 1 then
            v_speed_type := 6;
            v_dir_type := 7;
            v_limit := 3;
            v_input := p_params.speed_wind;
        else
            v_speed_type := 4;
            v_dir_type := 5;
            v_limit := 40;
            v_input := p_params.bullet_dist;
        end if;

        v_zero := v_input < v_limit;

        return query
        select
            h.height,
            lpad((h.height / 100)::text, 2, '0'),
            t.p_value,
            lpad(t.p_code::text, 2, '0'),
            ws.wind_direction,
            lpad(ws.wind_direction::text, 2, '0'),
            ws.wind_speed
        from public.calc_correction_heights h
        cross join lateral public.fn_calc_temp_correction(
            v_temp_type, h.id, v_dt
        ) t
        cross join lateral (
            select
                case
                    when v_zero then 0
                    else ((round(p_params.dir_wind)::integer 
                    + public.fn_calc_direction_correction(v_dir_type, h.id)) % 60 + 60) % 60
                end as wind_direction,
                case
                    when v_zero then 0
                    else public.fn_calc_speed_correction(v_speed_type, h.id, v_input)
                end as wind_speed
        ) ws
        order by h.height;

        return;
    end;
    $f5$;

    -- процедура
    create or replace procedure public.calc_meteo11(
        p_params public.meteo_input_params,
        p_device_id integer,
        inout p_result refcursor
    )
    language plpgsql
    as $f6$
    begin
        open p_result for
            select *
            from public.fn_calc_meteo11(p_params, p_device_id);
    end;
    $f6$;

end $$;