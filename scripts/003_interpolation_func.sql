do $do$
begin

    drop type if exists interpolation_temp cascade;

    create type interpolation_temp as (
        x0 numeric,
        y0 numeric,
        x1 numeric,
        y1 numeric
    );

    comment on type interpolation_temp is 'Параметры для линейной интерполяции: (x0,y0) и (x1,y1)';

    create or replace function public.get_temperature_interpolation(par_temperature numeric)
    returns public.interpolation_temp
    language plpgsql
    as $func1$
    declare
        var_interpolation public.interpolation_temp;
    begin
        -- по условию температура меньше нуля = 0 
        if par_temperature < 0 then
            var_interpolation.x0 := par_temperature;
            var_interpolation.y0 := 0;
            var_interpolation.x1 := par_temperature;
            var_interpolation.y1 := 0;
            return var_interpolation;
        end if;

        select t0, delta_tv
        into var_interpolation.x0, var_interpolation.y0
        from public.temp_correction
        where t0 <= par_temperature
        order by t0 desc
        limit 1;

        select t0, delta_tv
        into var_interpolation.x1, var_interpolation.y1
        from public.temp_correction
        where t0 >= par_temperature
        order by t0 asc
        limit 1;

        if var_interpolation.x0 is null and var_interpolation.x1 is null then
            raise exception 'Нет данных для интерполяции температуры';
        end if;

        -- проверка на нижнию границу излишняя из за провекри if par_temperature < 0 
        if var_interpolation.x1 is null then
            var_interpolation.x1:=var_interpolation.x0;
            var_interpolation.y1:=var_interpolation.y0;
        end if;

        return var_interpolation;
    end;
    $func1$;

    comment on function public.get_temperature_interpolation(numeric) is 
    'Возвращает параметры для линейной интерполяции по температуре';

    create or replace function public.interpolate_value(
    par_x numeric,
    par_params public.interpolation_temp
    )
    returns numeric
    language plpgsql
    as $func2$
    begin
        if par_params.x1 = par_params.x0 then
            return par_params.y0;
        end if;

        return par_params.y0 + (par_x - par_params.x0) 
        * (par_params.y1 - par_params.y0) / (par_params.x1 - par_params.x0);
    end;
    $func2$;

    comment on function public.interpolate_value(numeric, public.interpolation_temp) is 
    'Линейная интерполяция значения y по x и структуре interpolation_temp';

end $do$;