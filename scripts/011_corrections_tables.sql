-- Домашняя работа от 2026-11-02
do $$
begin
    drop table if exists calc_correction cascade;
    drop table if exists calc_correction_types cascade;
    drop table if exists calc_correction_heights cascade;
    
    drop sequence if exists calc_correction_height_seq cascade;
    drop sequence if exists calc_correction_types_seq cascade;
    drop sequence if exists calc_correction_seq cascade;

	-- Создаем новые структуры
	begin
		
		-- Таблица стандартных высот
		create sequence calc_correction_height_seq;
		create table calc_correction_heights
		(
		        id integer primary key not null default nextval('public.calc_correction_height_seq'),
		        height integer not null
		);
		
		
		insert into calc_correction_heights(height)
		values(200),(400),(800),(1200),(1600),(2000),(2400),(3000),(4000);
	
		comment on table calc_correction_heights is 'Таблица стандартных высот';
		comment on column calc_correction_heights.id is 'Уникальный код';
		comment on column calc_correction_heights.height is 'Высота';
	
		-- Справочник типов таблиц корректировок
		create sequence calc_correction_types_seq;
		create table calc_correction_types
		(
		        id integer not null primary key default nextval('public.calc_correction_types_seq'),
		        parent_id integer,
		        measurment_equipment_id integer,
		        description text not null,
		        header_values integer[]
		);
	
		comment on table calc_correction_types is 'Справочник типов таблиц с собственными заголовками';
		comment on column calc_correction_types.id is 'Уникальный код';
		comment on column calc_correction_types.parent_id is 'Уникальный код владельца - тип таблицы';
		comment on column calc_correction_types.measurment_equipment_id is 'Тип оборудования';
		comment on column calc_correction_types.description is 'Описание к таблице';
		comment on column calc_correction_types.header_values is 'Значения в заголовке таблице';

		-- Универсальная таблица корректировок
		create sequence calc_correction_seq;
		create table calc_correction
		(
		        id integer not null primary key default nextval('public.calc_correction_seq'),
		        height_id integer not null,
		        type_id integer not null,
		        row_values integer[]
		);

		comment on table calc_correction is 'Универсальная таблица корректировок';
		comment on column calc_correction.id is 'Уникальный код';
		comment on column calc_correction.height_id is 'Код высоты';
		comment on column calc_correction.type_id is 'Код типа таблиц';
		comment on column calc_correction.row_values is 'Значения с корректировками';

	end;	

	-- Добавляем данные
	begin

		
		insert into calc_correction_types(  description, header_values)
		values( 'Таблица 2', array[0, 1, 2, 3, 4, 5, 6, 7, 8, 8, 10, 20, 30, 40, 50]),  -- 1
		( 'Таблица 3, скорость среднего ветра', null), -- 2
		( 'Таблица 3, направление среднего ветра', null);       -- 3

		insert into calc_correction_types( description, parent_id, measurment_equipment_id, header_values)
		values
		('Таблица 3, Скорость среднего ветра (ВР)', 2, 2, array[40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150]), -- 4
		('Таблица 3, Направление среднего ветра (ВР)',3, 2, array[40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150]), -- 5
		('Таблица 3, Скорость среднего ветра (ДМК)',2, 1, array[3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]), -- 6
		('Таблица 3, Направление среднего ветра (ДМК)',3, 1, array[3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]); -- 7
		
		insert into calc_correction_types( description, parent_id)
		values('Таблица 2, Положительные температуры', 1 ), -- 8
		('Таблица 2, Отрицательные температуры', 1 ) --9
		;

		
		insert into calc_correction(height_id, type_id, row_values )
		-- Таблица 2, отрицптельные значения
		values(1, 8, array[-1, -2, -3, -4, -5, -6, -7, -8, -8, -9, -20, -29, -39, -49]), -- 200
		(2, 8, array[-1, -2, -3, -4, -5, -6, -6, -7, -8, -9, -19, -29, -39, -48]), -- 400
		(3, 8, array[-1, -2, -3, -4, -5, -6, -6, -7, -7, -8, -18, -28, -37, -46]), -- 800
		(4, 8, array[-1, -2, -3, -4, -4, -5, -5, -6, -7, -8, -17, -26, -35, -44]), -- 1200
		-- Таблица 2, положитеьные значения
		(1, 7, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]), -- 200
		(2, 7, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]), -- 400
		(3, 7, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]), -- 800
		(4, 7, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]), -- 1200
		-- Таблица 3, Скорость среднего ветра (ВР)
		(1, 4, array[3, 4, 5, 6, 7, 7, 8, 9, 10, 11, 12, 12]), -- 200
		(2, 4, array[4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 ,15]), -- 400
		(3, 4, array[4, 5, 6, 7, 8, 9, 10, 11, 13, 14, 15 ,16]), -- 800
		(4, 4, array[4, 5, 7, 8, 8, 9, 11, 12, 13, 15 ,15, 16]), -- 1200
		-- Таблица 3, Направление среднего ветра (ВР)
		(1, 5, array[0]), -- 200
		(2, 5, array[1]), -- 400
		(3, 5, array[2]), -- 800
		(4, 5, array[2]), -- 1200
		-- Таблица 3,Скорость среднего ветра (ДМК)
		(1, 6, array[4,6,8,9,10,12,14,15,16,18,20,21,22]), -- 200
		(2, 6, array[5,7,10,11,12,14,17,18,20,22,23,25,27]), -- 400
		(3, 6, array[5,8,10,11,13,15,18,19,21,23,25,27,28]), -- 800
		(4, 6, array[5,8,11,12,13,16,19,20,23,24,26,28,30]), -- 1200
		-- 'Таблица 3, Направление среднего ветра (ДМК)
		(1, 7, array[1]), -- 200
		(2, 7, array[2]), -- 400
		(3, 7, array[3]), -- 800
		(4, 7, array[3]) -- 1200
		;
	end;

	commit;

    begin
        -- убираем лишний 0 из массива
        update calc_correction_types
        set header_values = array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50]
        where id in (1, 8, 9);

        -- для таблиц ветра не нужны заголовки так как 1 значения на высоту
        update calc_correction_types
        set header_values = null
        where id in (5, 7);

        -- создание справочника заголовок
        drop table if exists calc_correction_headers cascade;
        drop sequence if exists seq_calc_correction_headers;

        create sequence seq_calc_correction_headers;

        create table calc_correction_headers (
            id integer primary key default nextval('seq_calc_correction_headers'),
            type_id integer not null,
            col_index integer not null,
            header_value integer not null
        );

        comment on table calc_correction_headers is 'Справочник заголовковтаблиц корректировок';
        comment on column calc_correction_headers.id is 'Уникальный код заголовка';
        comment on column calc_correction_headers.type_id is 'Уникальный код из типа таблицы корректировок';
        comment on column calc_correction_headers.col_index is 'Порядковый номер колонки';
        comment on column calc_correction_headers.header_value is 'Значение заголовка колонки';

        -- перенос заголовок из массивов в таблицу
        insert into calc_correction_headers (type_id, col_index, header_value)
        select
            t.id as type_id,
            h.ord::integer as col_index,
            h.val as header_value
        from calc_correction_types t
        cross join lateral unnest(t.header_values) with ordinality as h(val, ord)
        where t.header_values is not null;

        -- удаление колонки с заголовками
        alter table calc_correction_types drop column header_values;

        -- перезаполнение таблиц полными и верными данными
        truncate table calc_correction cascade;

        insert into calc_correction(height_id, type_id, row_values)
        values
        -- Таблица 2, отрицптельные значения
        (1, 9, array[-1, -2, -3, -4, -5, -6, -7, -8, -8, -9, -20, -29, -39, -49]), -- 200
        (2, 9, array[-1, -2, -3, -4, -5, -6, -6, -7, -8, -9, -19, -29, -38, -48]), -- 400
        (3, 9, array[-1, -2, -3, -4, -5, -6, -6, -7, -7, -8, -18, -28, -37, -46]), -- 800
        (4, 9, array[-1, -2, -3, -4, -4, -5, -5, -6, -7, -8, -17, -26, -35, -44]), -- 1200
        (5, 9, array[-1, -2, -3, -3, -4, -4, -5, -6, -7, -7, -17, -25, -34, -42]), -- 1600
        (6, 9, array[-1, -2, -3, -3, -4, -4, -5, -6, -6, -7, -16, -24, -32, -40]), -- 2000
        (7, 9, array[-1, -2, -2, -3, -4, -4, -5, -5, -6, -7, -15, -23, -31, -38]), -- 2400
        (8, 9, array[-1, -2, -2, -3, -4, -4, -4, -5, -5, -6, -15, -22, -30, -37]), -- 3000
        (9, 9, array[-1, -2, -2, -3, -4, -4, -4, -4, -5, -6, -14, -20, -27, -34]), -- 4000

        -- Таблица 2, положитеьные значения
        (1, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]), -- 200
        (2, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]), -- 400
        (3, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]), -- 800
        (4, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]), -- 1200
        (5, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]), -- 1600
        (6, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]), -- 2000
        (7, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]), -- 2400
        (8, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]), -- 3000
        (9, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]), -- 4000

        -- Таблица 3, Скорость среднего ветра (ВР)
        (1, 4, array[3, 4, 5, 6, 7, 7, 8, 9, 10, 11, 12, 12]), -- 200
        (2, 4, array[4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]), -- 400
        (3, 4, array[4, 5, 6, 7, 8, 9, 10, 11, 13, 14, 15, 16]), -- 800
        (4, 4, array[4, 5, 7, 8, 8, 9, 11, 12, 13, 15, 15, 16]), -- 1200
        (5, 4, array[4, 6, 7, 8, 9, 10, 11, 13, 14, 15, 17, 17]), -- 1600
        (6, 4, array[4, 6, 7, 8, 9, 10, 11, 13, 14, 16, 17, 18]), -- 2000
        (7, 4, array[4, 6, 8, 9, 9, 10, 12, 14, 15, 16, 18, 19]), -- 2400
        (8, 4, array[5, 6, 8, 9, 10, 11, 12, 14, 15, 17, 18, 19]), -- 3000
        (9, 4, array[5, 6, 8, 9, 10, 11, 12, 14, 16, 18, 19, 20]), -- 4000

        -- Таблица 3, Направление среднего ветра (ВР)
        (1, 5, array[0]), -- 200
        (2, 5, array[1]), -- 400 
        (3, 5, array[2]), -- 800 
        (4, 5, array[2]), -- 1200
        (5, 5, array[3]), -- 1600
        (6, 5, array[3]), -- 2000
        (7, 5, array[3]), -- 2400
        (8, 5, array[4]), -- 3000
        (9, 5, array[4]), -- 4000

        -- Таблица 3,Скорость среднего ветра (ДМК)
        (1, 6, array[4, 6, 8, 9, 10, 12, 14, 15, 16, 18, 20, 21, 22]), -- 200
        (2, 6, array[5, 7, 10, 11, 12, 14, 17, 18, 20, 22, 23, 25, 27]), -- 400
        (3, 6, array[5, 8, 10, 11, 13, 15, 18, 19, 21, 23, 25, 27, 28]), -- 800
        (4, 6, array[5, 8, 11, 12, 13, 16, 19, 20, 22, 24, 26, 28, 30]), -- 1200
        (5, 6, array[6, 8, 11, 13, 14, 17, 20, 21, 23, 25, 27, 29, 32]), -- 1600
        (6, 6, array[6, 9, 11, 13, 14, 17, 20, 21, 24, 26, 28, 30, 32]), -- 2000
        (7, 6, array[6, 9, 12, 14, 15, 18, 21, 22, 25, 27, 29, 32, 34]), -- 2400
        (8, 6, array[6, 9, 12, 14, 15, 18, 21, 23, 25, 28, 30, 32, 36]), -- 3000
        (9, 6, array[6, 10, 12, 14, 16, 19, 22, 24, 26, 29, 32, 34, 36]), -- 4000

        -- 'Таблица 3, Направление среднего ветра (ДМК)
        (1, 7, array[1]), -- 200 
        (2, 7, array[2]), -- 400 
        (3, 7, array[3]), -- 800 
        (4, 7, array[3]), -- 1200
        (5, 7, array[4]), -- 1600
        (6, 7, array[4]), -- 2000
        (7, 7, array[4]), -- 2400
        (8, 7, array[5]), -- 3000
        (9, 7, array[5]); -- 4000

        -- связи
        alter table calc_correction_headers
        add constraint fk_calc_correction_headers_type
        foreign key (type_id) references calc_correction_types(id) on delete cascade,
        add constraint uq_calc_correction_headers_type_col
        unique (type_id, col_index);

        alter table calc_correction_types
        add constraint fk_calc_correction_types_parent
        foreign key (parent_id) references calc_correction_types(id);

        alter table calc_correction
        add constraint fk_calc_correction_height
        foreign key (height_id) references calc_correction_heights(id),
        add constraint fk_calc_correction_type
        foreign key (type_id) references calc_correction_types(id),
        add constraint uq_calc_correction_height_type
        unique (height_id, type_id);
        end;
	
end $$;