do $$
begin
    -- ДМК пример 2
    raise notice 'результат ДМК';

    call public.calc_meteo11(
        row(100, 25, 765, 15, 6, null, 1)::public.parameter_set
    );

    -- ВР те же условия
    raise notice 'результат ВР';

    call public.calc_meteo11(
        row(100, 25, 765, 15, null, 100, 2)::public.parameter_set
    );
end $$;