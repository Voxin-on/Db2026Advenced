do $funcs$
begin

    -- Функция ДДЧЧМ (дата, часы, десятки минут)
    create or replace function public.calc_ddchchm(p_time timestamptz)
    returns text
    language plpgsql
    as $f1$
    begin
        -- DD + HH + (минуты / 10)
        return to_char(p_time, 'DDHH') || (extract(minute from p_time) / 10)::int;
    end;
    $f1$;

    -- Функция ВВВВ (высота)
    create or replace function public.calc_vvvv(p_height numeric)
    returns text
    language plpgsql
    as $f2$
    begin
        -- 4 знака с нулями
        return lpad(p_height::text, 4, '0');
    end;
    $f2$;

    -- Функция: БББ (отклонение давления)
    create or replace function public.calc_bbb(p_press numeric)
    returns text
    language plpgsql
    as $f3$
    declare
        v_table_press numeric;
        v_neg_sign numeric;
        v_diff numeric;
    begin
        select value into v_table_press from meteorology_constants where name = 'table_press';
        select value into v_neg_sign from meteorology_constants where name = 'negative_sign';
        
        v_diff := p_press - v_table_press;
        
        if v_diff >= 0 then
            return lpad(v_diff::text, 3, '0');
        else
            return v_neg_sign::text || lpad(abs(v_diff)::text, 2, '0');
        end if;
    end;
    $f3$;

    -- Функция: ТТ (отклонение температуры)
    create or replace function public.calc_tt(p_temp numeric)
    returns text
    language plpgsql
    as $f4$
    declare
        v_table_temp numeric;
        v_neg_sign numeric;
        v_delta_tv numeric;
        v_t0 numeric;
        v_delta_t numeric;
    begin
        select value into v_table_temp from meteorology_constants where name = 'table_temp';
        select value into v_neg_sign from meteorology_constants where name = 'negative_sign';
        
        -- Получаем T0
        v_delta_tv := public.interpolate_value(p_temp, public.get_temperature_interpolation(p_temp));
        v_t0 := p_temp + v_delta_tv;
        
        -- Считаем отклонение и округляем
        v_delta_t := round(v_t0 - v_table_temp);
        
        -- Форматируем также как с давлением 0 для +; 5 для -
        if v_delta_t >= 0 then
            return lpad(v_delta_t::text, 2, '0');
        else
            return v_neg_sign::text || lpad(abs(v_delta_t)::text, 1, '0'); 
        end if;
    end;
    $f4$;

    -- Функция сборки БББТТ
    create or replace function public.get_bbbtt(p_press numeric, p_temp numeric)
    returns text
    language plpgsql
    as $f5$
    begin
        return public.calc_bbb(p_press) || public.calc_tt(p_temp);
    end;
    $f5$;

end $funcs$;