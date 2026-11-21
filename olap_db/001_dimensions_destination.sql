do $$
begin

-- Единицы измерения
drop table if exists dim_ranges;
drop sequence if exists seq_dim_ranges;

create sequence seq_dim_ranges;

create table dim_ranges
(
    -- Внутренний код
    id bigint primary key default nextval('seq_dim_ranges'),
    external_id bigint,
    name text,
    factor float,
    -- Дата добавления
    date_add timestamp default now()
);


-- Категории
drop table if exists dim_categories;
drop sequence if exists seq_dim_categories;

create sequence seq_dim_categories;

create table dim_categories
(
    id bigint primary key default nextval('seq_dim_categories'),
    external_id bigint,
    name text,
    parent_id bigint,
    parent_name text,
    date_add timestamp default now()
);


-- Поставщики
drop table if exists dim_vendors;
drop sequence if exists seq_dim_vendors;

create sequence seq_dim_vendors;

create table dim_vendors
(
    id bigint primary key default nextval('seq_dim_vendors'),
    external_id bigint,
    name text,
    parent_id bigint,
    parent_name text,
    date_add timestamp default now()
);


-- Продукты
drop table if exists dim_products;
drop sequence if exists seq_dim_products;

create sequence seq_dim_products;

create table dim_products
(
    id bigint primary key default nextval('seq_dim_products'),
    external_id bigint,
    name text,
    category_external_id bigint,
    range_external_id bigint,
    flaging smallint,
    date_add timestamp default now()
);


-- Склады
drop table if exists dim_storages;
drop sequence if exists seq_dim_storages;

create sequence seq_dim_storages;

create table dim_storages
(
    id bigint primary key default nextval('seq_dim_storages'),
    external_id bigint,
    name text,
    company_external_id bigint,
    responsible_external_id bigint,
    date_add timestamp default now()
);


-- Свои организации
drop table if exists dim_companies;
drop sequence if exists seq_dim_companies;

create sequence seq_dim_companies;

create table dim_companies
(
    id bigint primary key default nextval('seq_dim_companies'),
    external_id bigint,
    name text,
    inn text,
    kpp text,
    date_add timestamp default now()
);


-- Сотрудники
drop table if exists dim_personnel;
drop sequence if exists seq_dim_personnel;

create sequence seq_dim_personnel;

create table dim_personnel
(
    id bigint primary key default nextval('seq_dim_personnel'),
    external_id bigint,
    lastname text,
    firstname text,
    middlename text,
    role_id bigint,
    role_name text,
    percent float,
    deleteflag smallint,
    date_add timestamp default now()
);


-- Типы документов
drop table if exists dim_document_types;
drop sequence if exists seq_dim_document_types;

create sequence seq_dim_document_types;

create table dim_document_types
(
    id bigint primary key default nextval('seq_dim_document_types'),
    external_id bigint,
    name text,
    date_add timestamp default now()
);


-- Виды складских операций
drop table if exists dim_operation_types;
drop sequence if exists seq_dim_operation_types;

create sequence seq_dim_operation_types;

create table dim_operation_types
(
    id bigint primary key default nextval('seq_dim_operation_types'),
    external_id bigint,
    name text,
    factor smallint,
    date_add timestamp default now()
);


-- Клиенты
drop table if exists dim_clients;
drop sequence if exists seq_dim_clients;

create sequence seq_dim_clients;

create table dim_clients
(
    id bigint primary key default nextval('seq_dim_clients'),
    external_id bigint,
    code text,
    name text,
    group_id bigint,
    group_name text,
    discount float,
    bonus float,
    date_add timestamp default now()
);


-- Типы оплаты
drop table if exists dim_payment_types;
drop sequence if exists seq_dim_payment_types;

create sequence seq_dim_payment_types;

create table dim_payment_types
(
    id bigint primary key default nextval('seq_dim_payment_types'),
    external_id bigint,
    name text,
    currency text,
    date_add timestamp default now()
);


-- Причины списания
drop table if exists dim_reasons;
drop sequence if exists seq_dim_reasons;

create sequence seq_dim_reasons;

create table dim_reasons
(
    id bigint primary key default nextval('seq_dim_reasons'),
    external_id bigint,
    name text,
    parent_external_id bigint,
    parent_name text,
    date_add timestamp default now()
);


-- Типы транзакций
drop table if exists dim_transaction_types;
drop sequence if exists seq_dim_transaction_types;

create sequence seq_dim_transaction_types;

create table dim_transaction_types
(
    id bigint primary key default nextval('seq_dim_transaction_types'),
    external_id bigint,
    name text,
    preview_group text,
    date_add timestamp default now()
);

end $$;