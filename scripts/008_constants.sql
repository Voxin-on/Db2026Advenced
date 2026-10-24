do $$
begin
    -- Таблица констант
    drop table if exists meteorology_constants cascade;
    
    create table meteorology_constants (
        name text primary key,
        value numeric not null,
        description text
    );

    comment on table meteorology_constants is 'Справочник констант для расчета метео';
    comment on column meteorology_constants.name is 'Уникальное название константы';
    comment on column meteorology_constants.value is 'Значение';
    comment on column meteorology_constants.description is 'Описание';

    insert into meteorology_constants (name, value, description) values
    ('table_press', 750, 'Табличное наземное давление'),
    ('table_temp', 15.9, 'Табличная приземная виртуальная температура'),
    ('negative_sign', 5, 'Спец. символ для отрицательных');
end $$;