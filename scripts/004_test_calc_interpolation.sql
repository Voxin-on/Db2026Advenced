do $$
declare 
    var_result numeric;
    var_delta_tv numeric;
begin

    var_delta_tv := public.interpolate_value(23, public.get_temperature_interpolation(23));
    raise notice '%', var_delta_tv;
    if var_delta_tv = 1.8 then
        raise notice 'правильно';
    else
        raise warning 'неправильно';
    end if;

    var_result := 23 + var_delta_tv;
    raise notice '%', var_result;
    if var_result = 24.8 then
        raise notice 'правильно';
    else
        raise warning 'неправильно';
    end if;

    var_result := round(var_result - 15.9);
    raise notice '%', var_result;
    if var_result = 9 then
        raise notice 'правильно';
    else
        raise warning 'неправильно';
    end if;

end $$;