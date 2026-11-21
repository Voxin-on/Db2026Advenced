-- Единицы измерения
select id, sizeid as name, portionrate as factor
from [size];

select 'insert into dim_ranges(external_id, name, factor) values ('
    + cast(id as varchar(max)) + ', '''
    + [sizeid] + ''', '
    + cast(portionrate as varchar(max)) + ');'
    as [sql]
from [size];


-- Категории
select c.id,
       c.description as name,
       nullif(c.ParentID, 0) as parent_id,
       p.description as parent_name
from category c
left join category p on p.id = c.ParentID
order by c.ParentID, c.description;

select 'insert into dim_categories(external_id, name, parent_id, parent_name) values ('
    + cast(c.id as varchar(max)) + ', '''
    + replace(c.description, '''', '''''') + ''', '
    + coalesce(cast(nullif(c.ParentID, 0) as varchar(max)), 'null') + ', '
    + coalesce('''' + replace(p.description, '''', '''''') + '''', 'null') + ');'
    as [sql]
from category c
left join category p on p.id = c.ParentID
order by c.ParentID, c.description;


-- Поставщики
select v.id,
       v.clientid as name,
       v.clientgroup as parent_id,
       g.description as parent_name
from vendors v
left join vendorgroup g on g.vendorgroupid = v.clientgroup
order by v.clientgroup;

select 'insert into dim_vendors(external_id, name, parent_id, parent_name) values ('
    + cast(v.id as varchar(max)) + ', '''
    + replace(v.clientid, '''', '''''') + ''', '
    + coalesce(cast(v.clientgroup as varchar(max)), 'null') + ', '
    + coalesce('''' + replace(g.description, '''', '''''') + '''', 'null') + ');'
    as [sql]
from vendors v
left join vendorgroup g on g.vendorgroupid = v.clientgroup
order by v.clientgroup;


-- Продукты
select id, [description] as name, CategoryID, SizeID, flaging
from product
order by product.id;

select 'insert into dim_products(external_id, name, category_external_id, range_external_id, flaging) values ('
    + cast(p.id as varchar(max)) + ', '''
    + replace(p.description, '''', '''''') + ''', '
    + coalesce(cast(p.CategoryID as varchar(max)), 'null') + ', '
    + coalesce(cast(p.SizeID as varchar(max)), 'null') + ', '
    + coalesce(cast(p.flaging as varchar(max)), 'null') + ');'
    as [sql]
from product p
order by p.id;


-- Склады
select id, [description] as name, CompanyID, ResponsibleID
from storages;

select 'insert into dim_storages(external_id, name, company_external_id, responsible_external_id) values ('
    + cast(s.id as varchar(max)) + ', '''
    + replace(s.[description], '''', '''''') + ''', '
    + coalesce(cast(s.CompanyID as varchar(max)), 'null') + ', '
    + coalesce(cast(s.ResponsibleID as varchar(max)), 'null') + ');'
    as [sql]
from storages s;


-- Свои организации
select ID, CompanyName, INN, KPP
from bm_Companies;

select 'insert into dim_companies(external_id, name, inn, kpp) values ('
    + cast(c.ID as varchar(max)) + ', '''
    + replace(c.CompanyName, '''', '''''') + ''', '
    + coalesce('''' + replace(c.INN, '''', '''''') + '''', 'null') + ', '
    + coalesce('''' + replace(c.KPP, '''', '''''') + '''', 'null') + ');'
    as [sql]
from bm_Companies c;


-- Сотрудники
select p.personid, p.lastname, p.firstname, p.middlename, p.[percent]
from personnel p
order by p.personid;

select 'insert into dim_personnel(external_id, lastname, firstname, middlename, percent) values ('
    + cast(p.personid as varchar(max)) + ', '''
    + replace(coalesce(p.lastname, ''), '''', '''''') + ''', '''
    + replace(coalesce(p.firstname, ''), '''', '''''') + ''', '''
    + replace(coalesce(p.middlename, ''), '''', '''''') + ''', '
    + coalesce(cast(p.[percent] as varchar(max)), 'null') + ');'
    as [sql]
from personnel p
order by p.personid;


-- Роли
select securityaccessid, [description]
from securityaccess
order by securityaccessid;

select 'insert into dim_roles(external_id, name) values ('
    + cast(securityaccessid as varchar(max)) + ', '''
    + replace([description], '''', '''''') + ''');'
    as [sql]
from securityaccess
order by securityaccessid;


-- Виды складских операций
select ID, [Description], Factor
from bm_StorageOperationsType
order by ID;

select 'insert into dim_operation_types(external_id, name, factor) values ('
    + cast(ID as varchar(max)) + ', '''
    + replace([Description], '''', '''''') + ''', '
    + coalesce(cast(Factor as varchar(max)), 'null') + ');'
    as [sql]
from bm_StorageOperationsType
order by ID;


-- Клиенты
select c.id, c.clientid, c.lastname, c.firstname, c.clientgroup as group_id,
       g.description as group_name, c.discount, c.bonus
from clients c
left join clientgroup g on g.clientgroupid = c.clientgroup
order by c.id;

select 'insert into dim_clients(external_id, code, name, group_id, group_name, discount, bonus) values ('
    + cast(c.id as varchar(max)) + ', '''
    + replace(coalesce(c.clientid, ''), '''', '''''') + ''', '''
    + replace(ltrim(rtrim(coalesce(c.lastname, '') + ' ' + coalesce(c.firstname, ''))), '''', '''''') + ''', '
    + coalesce(cast(c.clientgroup as varchar(max)), 'null') + ', '
    + coalesce('''' + replace(g.description, '''', '''''') + '''', 'null') + ', '
    + coalesce(cast(c.discount as varchar(max)), 'null') + ', '
    + coalesce(cast(c.bonus as varchar(max)), 'null') + ');'
    as [sql]
from clients c
left join clientgroup g on g.clientgroupid = c.clientgroup
order by c.id;


-- Типы оплаты
select paymenttypeid, [description], currencyid
from paymenttype
order by paymenttypeid;

select 'insert into dim_payment_types(external_id, name, currency) values ('
    + cast(paymenttypeid as varchar(max)) + ', '''
    + replace([description], '''', '''''') + ''', '''
    + replace(coalesce(currencyid, ''), '''', '''''') + ''');'
    as [sql]
from paymenttype
order by paymenttypeid;


-- Причины списания
select r.ID,
       r.[Description] as name,
       nullif(r.ParentID, 0) as parent_external_id,
       p.[Description] as parent_name
from bm_ReasonDebit r
left join bm_ReasonDebit p on p.ID = r.ParentID
order by r.ParentID, r.[Description];

select 'insert into dim_reasons(external_id, name, parent_external_id, parent_name) values ('
    + cast(r.ID as varchar(max)) + ', '''
    + replace(r.[Description], '''', '''''') + ''', '
    + coalesce(cast(nullif(r.ParentID, 0) as varchar(max)), 'null') + ', '
    + coalesce('''' + replace(p.[Description], '''', '''''') + '''', 'null') + ');'
    as [sql]
from bm_ReasonDebit r
left join bm_ReasonDebit p on p.ID = r.ParentID
order by r.ParentID, r.[Description];


-- Типы транзакций
select transtypeid, [description], PreviewGroupType
from transtype
where [description] is not null
  and [description] <> ''
order by transtypeid;

select 'insert into dim_transaction_types(external_id, name, preview_group) values ('
    + cast(transtypeid as varchar(max)) + ', '''
    + replace([description], '''', '''''') + ''', '''
    + replace(coalesce(PreviewGroupType, ''), '''', '''''') + ''');'
    as [sql]
from transtype
where [description] is not null
  and [description] <> ''
order by transtypeid;
