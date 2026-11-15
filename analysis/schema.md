# Front: таблицы по направлениям

## 1. Анализ закупки продукции

Закупка: документы DocumentTypeID = 4 и строки bm_StorageOperations с OperationID = 1. Одного OperationID = 1 мало: в нём есть ещё положительные строки товарных чеков.

### 1.1. Основные таблицы

bm_JournalBarnetDocs (документы поступления)
- ID: ключ документа (388235)
- Period: дата (2020-11-11)
- DocumentTypeID: тип, 4 = поступление
- Amount: сумма (892.77)
- PersonID: автор (897)

bm_StorageOperations (строки поступления)
- DocumentID: ссылка на документ (388235)
- OperationID: 1 = приход
- ProductID: товар (4368)
- VendorID: поставщик (200)
- Price: цена (323.00)
- Count: количество (2.7640)
- Amount: сумма (892.77)

bm_JournalTypeDocuments (типы документов)
- ID: ключ (4)
- Description: название (Поступление продуктов)

bm_StorageOperationsType (виды операций)
- ID: ключ (1)
- Description: название (Поступление)
- Factor: знак для остатка (1)

### 1.2. Связанные таблицы

product (номенклатура)
- id: ключ (4420)
- productid: внешний код (3591888)
- description: название (Пицца Рэд бинс 24 см)
- flaging: тип, 0 блюдо, 1 ингредиент, 2 полуфабрикат, 3 товар, 4 изделие (0)
- CategoryID: категория (152)

category (категории)
- id: ключ (147)
- description: название (Меню доставка)
- ParentID: родитель (0)

size (размеры и упаковки)
- ID: ключ (2)
- description: название (100г)
- BaseSizeID: базовая единица (163)
- portionrate: коэффициент (100.000)

vendors (поставщики)
- id: ключ (211)
- firstname: название (Пятая Армия)
- clientgroup: группа (32)
- INN: ИНН (NULL)

storages (склады)
- id: ключ (41)
- description: название (Склад)
- ResponsibleID: ответственный (897)

bm_Companies (свои организации)
- ID: ключ (6)
- CompanyName: название (ИП Лукьянова Анастасия Игоревна)
- INN: ИНН (380122679974)

pricelist (история цен)
- productid: товар (4544)
- basecost: цена (140.00)
- groupid: тип цены (2)
- vendorid: поставщик, реальных значений нет (NULL)

bm_Contracts (договоры поставки, таблица пустая)
- ID: ключ договора
- VendorID: поставщик
- ContractNumber: номер договора
- Period: дата договора

personnel (автор документа)
- personid: ключ (897)
- firstname: имя (Администратор Barnet)
- securityaccess: роль (9)

## 2. Анализ продажи товара

Продажа: journal с transtype = 101. Детализация по ингредиентам в bm_Journal_Details, списание со склада в bm_StorageOperations по документам типа 6.

### 2.1. Основные таблицы

journal (строки чеков)
- posid: терминал (5)
- transtype: тип, 101 = продажа
- receiptn: номер чека (50672281)
- dater: дата (2023-12-06 13:58:26)
- id: код товара (7239833)
- description: название (Соус Барбекю)
- categoryid: категория (178)
- price: цена (50.00)
- quantity: количество (1.000)
- amount: сумма (50.00)
- discountamount: скидка (0.00)
- loginid: кассир (906)
- customerid: клиент (NULL)
- transnumber: номер транзакции (1951181)

bm_Journal_Details (расшифровка чека по ингредиентам)
- SourceID: номер транзакции (1675591)
- ProductID: ингредиент (4407)
- BludoID: блюдо (4451)
- Count: количество (0.4000)
- StorageID: склад (41)

bm_JournalBarnetDocs (шапка чека типа 6)
- ID: ключ (415426)
- DocumentTypeID: тип (6)
- TicketNumber: номер чека (14740696)
- Amount: сумма (1240.00)
- PersonID: сотрудник (906)

bm_StorageOperations (списание ингредиентов по чекам)
- DocumentID: документ (415426)
- OperationID: 2 = списание
- SourceID: транзакция (1675586)
- BludoID: блюдо (4451)
- ProductID: ингредиент (4345)
- Count: количество, отрицательное (-0.1300)
- Amount: сумма, отрицательная (-19.50)

transtype (типы транзакций)
- transtypeid: ключ (101)
- description: название (PLU Sales)
- PreviewGroupType: группа (POS)

В базе встречаются 101 продажа, 111 списание, 211 наличные, 216 Visa, 301 вход, 386 и 387 начало и конец работы, 501 итог чека.

### 2.2. Связанные таблицы

product (товар)
- productid: код (7239833)
- description: название (Соус Барбекю)
- CategoryID: категория (178)

category (категория позиции)
- id: ключ (178)
- description: название (Соусы)
- ParentID: родитель (147)

clients (клиенты и карты)
- id: ключ (109)
- clientid: код (1234)
- clientgroup: группа (37)
- lastname: фамилия или название (Самовывоз)
- bonus: бонус (10.000)
- discount: скидка (0.000)

clientgroup (группы клиентов)
- clientgroupid: ключ (37)
- description: название (Дсконт карты)
- discount: скидка (5.000)
- reward: вознаграждение (2)

paymenttype (типы оплаты)
- paymenttypeid: ключ (216)
- description: название (Безнал)
- currencyid: валюта (RUB)

Всего 16 типов. У 211 название Наличные, у 216 Безнал.

bm_BonusHistory (бонусы по чекам)
- PersonID: сотрудник (906)
- ClientID: клиент (255)
- TicketNumber: номер чека (59368651)
- BonusValue: сумма (884.00)
- IsCalc: признак расчёта (0)

personnel (кассир)
- personid: ключ (906)
- lastname: фамилия (Доставка)
- firstname: имя (Доставка)
- securityaccess: роль (3)

## 3. Анализ взаимоотношений с поставщиками

Основа: vendors и закупочные строки bm_StorageOperations с VendorID. Договоры и платежи в базе не ведутся.

### 3.1. Основные таблицы

vendors (справочник поставщиков)
- id: ключ (211)
- clientid: код (Пятая Армия)
- clientgroup: группа (32)
- firstname: название (Пятая Армия)
- INN: ИНН (NULL)
- KPP: КПП (NULL)
- cityid: город (NULL)

В справочнике 63 записи. ИНН заполнен только у 5.

bm_StorageOperations (закупочные строки)
- VendorID: поставщик (200)
- DocumentID: документ (388235)
- ProductID: товар (4368)
- Price: цена (323.00)
- Count: количество (2.7640)
- Amount: сумма (892.77)

В закупках участвует 21 поставщик. Все 11 358 строк заполнены.

bm_JournalBarnetDocs (документ закупки)
- ID: ключ (388235)
- Period: дата (2020-11-11)
- DocumentTypeID: тип (4)
- Amount: сумма (892.77)

bm_Contracts (договоры с поставщиками, таблица пустая)
- ID: ключ договора
- VendorID: поставщик
- ContractNumber: номер договора
- Period: дата договора

pricelist (цены)
- productid: товар (4544)
- basecost: цена (140.00)
- vendorid: поставщик (NULL)
- dateeff: дата начала действия (NULL)

В pricelist поле vendorid есть, но реальных поставщиков в нём нет: 2 181 строка с нулём и 22 616 с NULL.

### 3.2. Связанные таблицы

vendorgroup (группы поставщиков)
- vendorgroupid: ключ (31)
- description: название (Поставщики)

Всего две записи: 31 и 32.

city (город поставщика)
- cityid: ключ (4)
- name: название (Иркутск)

В справочнике 17 городов, у двух название пустое. У поставщиков cityid заполнен только у 3 из 63.

bm_Companies (своя организация)
- ID: ключ (6)
- CompanyName: название (ИП Лукьянова Анастасия Игоревна)
- INN: ИНН (380122679974)

bm_PaymentOperations (платежи по договорам, таблица пустая)
- ID: ключ платежа
- PaymentTypeID: тип оплаты
- ContractID: договор
- Amount: сумма

bm_CashOperations (кассовые расчёты с поставщиком, таблица пустая)
- ID: ключ операции
- VendorID: поставщик
- ContractID: договор
- Amount: сумма

## 4. Анализ работы персонала

Сотрудники в personnel. Смены: события journal с transtype 386 и 387. Продажи напрямую к сотруднику не привязаны.

### 4.1. Основные таблицы

personnel (справочник сотрудников)
- personid: ключ (898)
- lastname: фамилия (Безик)
- firstname: имя (Татьяна)
- middlename: отчество (Сергеевна)
- securityaccess: роль (9)
- deleteflag: признак удаления, у всех 1
- percent: максимальная скидка (10.000)

journal (события работы)
- transtype: 386 начало, 387 окончание, 301 вход
- dater: дата (2023-12-06 09:50:30)
- loginid: сотрудник (1066)
- transnumber: транзакция (1951154)

Смены есть у 35 сотрудников. Всего 11 532 события. Вход в систему: 4 316 событий у 26 сотрудников.

bm_BonusHistory (бонусы и привязка чека к сотруднику)
- PersonID: сотрудник (906)
- TicketNumber: чек (59368651)
- BonusValue: сумма (884.00)
- IsCalc: признак (0)

bm_JournalSessions (журнал действий)
- ID: ключ (174072)
- Type: тип (barnetbc.ru)
- Message: текст ошибки (Ошибка при выполнении операции обновления настроек Barnet Front)
- DateAdd: дата (2023-12-06 14:18:08)
- PersonID: сотрудник (897)

Реальных сотрудников всего три: 897, 990 и 993. Остальные записи системные с PersonID = 0.

bm_JournalBarnetDocs (документы сотрудника)
- ID: ключ (388235)
- PersonID: автор (897)
- DocumentTypeID: тип (4)
- Period: дата (2020-11-11)

### 4.2. Связанные таблицы

securityaccess (роли доступа)
- securityaccessid: ключ (2)
- description: название (Clerk)

В справочнике роли 2, 3, 4, 9. Записи с ID = 1 нет, хотя у 102 сотрудников стоит именно 1.

bm_PersonnelSecurity (права сотрудника)
- PersonID: сотрудник (906)
- ObjectID: объект (36)
- IsUse: признак (1)

bm_SecurityObjects (объекты прав)
- ID: ключ (1)
- ParentSystem: система (Manager)
- SecurityGroup: группа (Прочее)
- ObjectName: объект (dlgProperties)

bm_WorkHours (таблица пустая)
- ID: ключ записи
- ShiftID: смена
- PersonID: сотрудник
- SystemPeriod: системный период
- ManualPeriod: ручной период

bm_ShiftsOperations (одна старая запись)
- ID: ключ (65)
- ShiftNumber: номер (1)
- DateAdd: дата (2015-07-14)
- PersonalID: сотрудник (0)

bm_TicketLoadInfo_History (загрузка чеков сотрудником)
- ID: ключ (88)
- TicketNumber: чек (59377270)
- Errors: сообщение (21:55:37 Чек: 59377270 добавлено в StorageOperations по средневзвешанной цене)
- PersonnelID: сотрудник (0)
- DateAdd: дата (2023-12-04)

## 5. Анализ остатков

Остатки ведутся регистром bm_StorageOperations. Готовых срезов нет: closingcount, onhand, stock, stockbp и storagesonhand пустые. Остаток считается накопительным итогом по Count.

### 5.1. Основные таблицы

bm_StorageOperations (регистр движений)
- DocumentID: документ (388235)
- OperationID: 1 приход, 2 списание
- ProductID: товар (4368)
- StorageID: склад (41)
- Count: количество (2.7640)
- Rest: остаток после операции, везде 0
- Price: цена (323.00)
- Amount: сумма (892.77)
- BatchID: партия, везде 0
- ReasonID: причина (0)

bm_StorageOperationsType (виды операций)
- ID: ключ (2)
- Description: название (Списание)
- Factor: знак (-1)

bm_StorageOperations_Table (списания с себестоимостью)
- DocumentID: документ (415428)
- ProductID: товар (4365)
- PriceCost: себестоимость (157.50)
- Count: количество (-0.1200)
- Amount: сумма (-29.9100)
- ReasonID: причина (164)

bm_JournalBarnetDocs (документы списания и инвентаризации)
- ID: ключ (465974)
- DocumentTypeID: 5 списание, 8 инвентаризация
- Period: дата (2023-12-03)
- Amount: сумма (948.75)

bm_JournalTypeDocuments (типы документов)
- ID: ключ (5)
- Description: название (Списание продуктов)

### 5.2. Связанные таблицы

product (номенклатура, поля остатков не заполнены)
- id: ключ (4337)
- productid: код (1204073)
- description: название (Бананы)
- flaging: тип (1)
- onhand: остаток (NULL)
- closingcount: остаток на дату (0.000)

category (категория товара)
- id: ключ (149)
- description: название (Склад)
- ParentID: родитель (0)

bm_ReasonDebit (причины списания)
- ID: ключ (1)
- ParentID: родитель (0)
- Description: название (Порча продукта)

stockperiod (данные тестовые)
- id: ключ (1)
- price: цена (2.30)
- quantityopen: остаток на начало (0.000)
- quantityin: приход (10000.000)
- quantityout: расход (14999.000)
- quantityclose: остаток на конец (0.000)

bm_Journal_Details (фактический расход ингредиентов)
- ProductID: ингредиент (4407)
- Count: количество (0.4000)
- SourceID: транзакция (1675591)
- StorageID: склад (41)

Пустые таблицы остатков:
- closingcount: productid, onhand, closingcount, closingcountdate
- onhand: productid, onhand
- stock: productid, quantity, amount, onhand
- stockbp: productid, qnt, cost
- storagesonhand: productid, storageid, onhand

## 6. Что в итоге пустое

- Договоры и платежи: bm_Contracts, bm_PaymentOperations, bm_CashOperations.
- Остатки: closingcount, onhand, stock, stockbp, storagesonhand.
- Персонал: bm_WorkHours.

Эти таблицы можно использовать в запросах, но данных в них нет.
