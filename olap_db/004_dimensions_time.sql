do $$
declare
    v_start date := date '2012-01-01';
    v_end date := date '2026-12-01';
    v_date date := v_start;
begin

    drop table if exists dim_time;

    create table dim_time
    (
        code int primary key,
        month_start date,
        month_end date,
        month_name text,
        year int,
        quarter_num int,
        quarter_name text
    );

    while v_date <= v_end loop
        insert into dim_time (code, month_start, month_end, month_name,
                              year, quarter_num, quarter_name)
        values (
            extract(year from v_date)::int * 100 + extract(month from v_date)::int,
            date_trunc('month', v_date)::date,
            (date_trunc('month', v_date) + interval '1 month - 1 day')::date,
            case extract(month from v_date)::int
                when 1  then 'Январь'
                when 2  then 'Февраль'
                when 3  then 'Март'
                when 4  then 'Апрель'
                when 5  then 'Май'
                when 6  then 'Июнь'
                when 7  then 'Июль'
                when 8  then 'Август'
                when 9  then 'Сентябрь'
                when 10 then 'Октябрь'
                when 11 then 'Ноябрь'
                when 12 then 'Декабрь'
            end,
            extract(year from v_date)::int,
            extract(quarter from v_date)::int,
            extract(quarter from v_date)::int || ' квартал'
        );

        v_date := (v_date + interval '1 month')::date;
    end loop;

end $$;
