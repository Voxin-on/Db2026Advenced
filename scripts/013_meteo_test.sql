do $$
declare
    v_cursor refcursor;
    r record;
begin
    -- ДМК пример 2
    raise notice 'результат ДМК';

    v_cursor := 'meteo_dmk';

    call public.calc_meteo11(
        row(100, 25, 765, 15, 6, null)::public.meteo_input_params,
        1,
        v_cursor
    );

    loop
        fetch v_cursor into r;
        exit when not found;

        raise notice 'Высота: %, Код высоты: %, Откл. темп.: % (%), Напр.: % (%), Скорость: %',
            r.height, r.height_code, r.temp_deviation, r.temp_code,
            r.wind_direction, r.wind_dir_code, r.wind_speed;
    end loop;

    close v_cursor;

    -- ВР те же условия
    raise notice 'результат ВР';

    v_cursor := 'meteo_vr';

    call public.calc_meteo11(
        row(100, 25, 765, 15, null, 100)::public.meteo_input_params,
        2,
        v_cursor
    );

    loop
        fetch v_cursor into r;
        exit when not found;

        raise notice 'Высота: %, Код высоты: %, Откл. темп.: % (%), Напр.: % (%), Скорость: %',
            r.height, r.height_code, r.temp_deviation, r.temp_code,
            r.wind_direction, r.wind_dir_code, r.wind_speed;
    end loop;

    close v_cursor;

end $$;
