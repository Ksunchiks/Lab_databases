-- 1. Выборка из одной таблицы.

-- 1.1 Выбрать из произвольной таблицы данные и отсортировать их по двум  
-- произвольным имеющимся в таблице признакам (разные направления сортировки).

SELECT *
FROM Employee
ORDER BY role ASC, employee_fio DESC

-- 1.2 Выбрать из произвольной таблицы те записи, которые удовлетворяют
-- условию отбора (where). Привести 2-3 запроса.

SELECT name_product, manufacturer
FROM Products
WHERE manufacturer='Овощевод' or manufacturer='Петелинка'

SELECT name_product, purchase_price
FROM Products
WHERE purchase_price > 100

SELECT name_product, production_date
FROM Products
WHERE production_date BETWEEN '2024-01-01' AND '2024-12-31'

-- 1.3 Привести примеры 2-3 запросов с использованием агрегатных функций
-- (count, max, sum и др.) с группировкой и без группировки. 

SELECT 
	COUNT(*) AS 'Кол-во покупок',
	SUM(final_amount) AS 'Общая выручка',
    MAX(final_amount) AS 'Max сумма покупки',
    MIN(final_amount) AS 'Мin сумма покупки'
FROM Sale

SELECT
    CAST(sale_datetime AS DATE) AS 'Дата', -- для групптровки только по дате
    COUNT(*) AS 'Кол-во покупок',
    SUM(final_amount) AS 'Общая выручка за день',
    MAX(final_amount) AS 'Max сумма покупки',
    MIN(final_amount) AS 'Мin сумма покупки',
    AVG(final_amount) AS 'Ср. сумма покупки'
FROM Sale
GROUP BY CAST(sale_datetime AS DATE)

-- 1.4  Привести примеры подведения подытога с использованием GROUP BY [ALL] [ CUBE | ROLLUP]
-- (2-3 запроса). В ROLLUP и CUBE использовать не менее 2-х столбцов.

SELECT 
    CAST(sale_datetime AS DATE) AS 'Дата',
    employee_id,
    COUNT(*) AS 'Кол-во покупок',
    SUM(final_amount) AS 'Выручка'
FROM Sale
GROUP BY ROLLUP(CAST(sale_datetime AS DATE), employee_id)

SELECT 
    CAST(sale_datetime AS DATE) AS 'Дата',
    employee_id,
    COUNT(*) AS 'Кол-во покупок',
    SUM(final_amount) AS 'Выручка'
FROM Sale
GROUP BY CUBE(CAST(sale_datetime AS DATE), employee_id)

-- 1.5 Выбрать из таблиц информацию об объектах, в названиях которых нет заданной последовательности букв (LIKE).

SELECT *
FROM Customer
WHERE phone_number NOT LIKE '%89%'

SELECT id, customer_fio
FROM Customer
WHERE customer_fio NOT LIKE '%вна'

-- 2. Выборка из нескольких таблиц.

-- 2.1 Вывести информацию подчиненной (дочерней) таблицы, заменяя коды (значения внешних ключей) 
-- соответствующими символьными значениями из родительских таблиц. Привести 2-3 запроса 
-- с использованием классического подхода соединения таблиц (where).

SELECT 
    c.id,
    c.customer_fio AS 'ФИО клиента',
    c.phone_number AS 'Телефон',
    dc.discount_rate AS 'Размер скидки (%)'
FROM Customer c, DiscountCard dc
WHERE c.card_id = dc.id

SELECT 
    s.id AS 'ID покупки',
    s.sale_datetime AS 'Дата',
    c.customer_fio AS 'Покупатель',
    e.employee_fio AS 'Сотрудник'
FROM Sale s, Employee e, Customer c
WHERE s.employee_id=e.id AND s.customer_id=c.id

-- 2.2. Реализовать запросы пункта 2.1 через внутреннее соединение inner join. 

SELECT 
    c.id,
    c.customer_fio AS 'ФИО клиента',
    c.phone_number AS 'Телефон',
    dc.discount_rate AS 'Размер скидки (%)'
FROM Customer c
JOIN DiscountCard dc ON c.card_id = dc.id

SELECT 
    s.id AS 'ID покупки',
    s.sale_datetime AS 'Дата',
    c.customer_fio AS 'Покупатель',
    e.employee_fio AS 'Сотрудник'
FROM Sale s
JOIN Employee e ON s.employee_id=e.id
JOIN Customer c ON s.customer_id=c.id

-- 2.3. Левое внешнее соединение left join. Привести 2-3 запроса.

SELECT 
    c.id,
    c.customer_fio AS 'ФИО клиента',
    dc.discount_rate AS 'Размер скидки (%)'
FROM Customer c
LEFT JOIN DiscountCard dc ON c.card_id = dc.id

SELECT 
    e.employee_fio AS 'Сотрудник',
    e.role AS 'Должность',
    s.id AS 'Номер оформленной продажи'
FROM Employee e
LEFT JOIN Sale s ON e.id = s.employee_id
GROUP BY e.employee_fio, e.role, s.id

-- 2.4. Правое внешнее соединение right join. Привести 2-3 запроса 

SELECT
    c.customer_fio AS 'Покупатель',
    c.card_id AS 'Скидочная карта',
    s.id AS 'Номер покупки'
FROM Customer c
RIGHT JOIN Sale s ON c.id=s.customer_id

SELECT 
    s.id AS 'Номер оформленной продажи',
    e.employee_fio AS 'Сотрудник'
FROM Sale s
RIGHT JOIN Employee e ON e.id = s.employee_id
GROUP BY e.employee_fio, s.id

-- 2.5. Привести примеры 2-3 запросов с использованием агрегатных функций и группировки.

SELECT 
    e.employee_fio AS 'Сотрудник',
    e.role AS 'Должность',
    COUNT(s.id) AS 'Кол-во оформленных продаж'
FROM Employee e
LEFT JOIN Sale s ON e.id = s.employee_id
GROUP BY e.employee_fio, e.role

SELECT
    p.name_product AS 'Товар',
    p.unit AS 'Единица измерения',
    SUM(si.quantity) AS 'Кол-во куплено',
    SUM(si.total_price) AS 'Выручка'
FROM Products p
LEFT JOIN SaleItem si ON p.id=si.product_id
GROUP BY p.name_product, p.unit

-- 2.6. Привести примеры 2-3 запросов с использованием группировки и условия отбора групп (Having).

SELECT 
    e.employee_fio AS 'Сотрудник',
    e.role AS 'Должность',
    COUNT(s.id) AS 'Кол-во оформленных продаж'
FROM Employee e
LEFT JOIN Sale s ON e.id = s.employee_id
GROUP BY e.employee_fio, e.role
HAVING COUNT(s.id)>1

SELECT
    p.name_product AS 'Товар',
    p.unit AS 'Единица измерения',
    SUM(si.quantity) AS 'Кол-во куплено',
    SUM(si.total_price) AS 'Выручка'
FROM Products p
LEFT JOIN SaleItem si ON p.id=si.product_id
GROUP BY p.name_product, p.unit
HAVING SUM(si.total_price) BETWEEN 600 AND 1700

-- 2.7. Привести примеры 3-4 вложенных (соотнесенных, c использованием IN, EXISTS) запросов.

SELECT *
FROM Employee
WHERE role IN ('Кассир','Администратор')

SELECT * 
FROM Employee 
WHERE id NOT IN (SELECT DISTINCT employee_id 
                 FROM Sale
                 WHERE employee_id IS NOT NULL)

SELECT *
FROM Employee e
WHERE EXISTS (SELECT 1 
              FROM Sale s 
              WHERE s.employee_id = e.id)

SELECT *
FROM Customer c
WHERE EXISTS (SELECT 1 
              FROM Sale s 
              WHERE s.customer_id = c.id AND s.final_amount > 2000)

-- 3. Представления

-- 3.1  На основе любых запросов из п. 2 создать два представления (VIEW).

DROP VIEW IF EXISTS Product_unit_purchase 
GO
CREATE VIEW Product_unit_purchase
AS SELECT 
    p.name_product AS 'Товар',
    p.unit AS 'Единица измерения',
    SUM(si.quantity) AS 'Кол-во куплено',
    SUM(si.total_price) AS 'Выручка'
FROM Products p
LEFT JOIN SaleItem si ON p.id=si.product_id
GROUP BY p.name_product, p.unit
GO
SELECT *
FROM Product_unit_purchase 
WHERE [Единица измерения]='кг'

DROP VIEW IF EXISTS Selling 
GO
CREATE VIEW Selling
AS SELECT 
    e.employee_fio AS 'Сотрудник',
    e.role AS 'Должность',
    s.id AS 'Номер оформленной продажи'
FROM Employee e
LEFT JOIN Sale s ON e.id = s.employee_id
GROUP BY e.employee_fio, e.role, s.id
GO
SELECT
    [Должность],
    COUNT(DISTINCT[Сотрудник]) AS 'Кол-во сотрудников',
    COUNT([Номер оформленной продажи]) AS 'Кол-во продаж'
FROM Selling
GROUP BY [Должность]
GO

-- 3.2  Привести примеры использования общетабличных выражений (СТЕ) (2-3 запроса)

WITH SalesInf AS (
    SELECT
        s.id AS 'Номер чека',
        c.customer_fio AS 'Покупатель',
        s.final_amount AS 'Сумма покупки'
    FROM Sale s
    LEFT JOIN Customer c ON s.customer_id=c.id
)
SELECT *
FROM SalesInf
WHERE [Сумма покупки]>2000
GO

WITH Sale_Emp AS(
    SELECT 
    s.id AS 'Номер продажи', 
    e.employee_fio AS 'Сотрудник'
    FROM Sale s
    JOIN Employee e ON s.employee_id=e.id
),
Sale_Cust AS(
    SELECT
        s.id AS 'Номер чека',
        c.customer_fio AS 'Покупатель'
    FROM Sale s
    LEFT JOIN Customer c ON s.customer_id=c.id
)
SELECT [Номер чека], [Сотрудник],[Покупатель]
FROM Sale_Emp 
JOIN Sale_Cust ON [Номер продажи]=[Номер чека]

-- 4. Функции ранжирования

-- 4.1 Привести примеры 3-4 запросов с использованием ROW_NUMBER, RANK, DENSE_RANK (c  PARTITION BY и без)

SELECT 
    ROW_NUMBER() OVER(ORDER BY customer_fio) AS 'Номер',
    id,
    customer_fio
FROM Customer

SELECT 
    id,
    employee_fio,
    role,
    ROW_NUMBER() OVER(PARTITION BY role
                      ORDER BY employee_fio) AS 'Номер'
FROM Employee

SELECT 
    c.customer_fio AS 'Покупатель',
    dc.discount_rate AS 'Размер скидки',
    RANK() OVER (ORDER BY dc.discount_rate) AS 'Номер'
FROM Customer c
JOIN DiscountCard dc ON c.card_id=dc.id
GROUP BY dc.discount_rate, c.customer_fio

SELECT 
    c.customer_fio AS 'Покупатель',
    dc.discount_rate AS 'Размер скидки',
    DENSE_RANK() OVER (ORDER BY dc.discount_rate) AS 'Номер'
FROM Customer c
JOIN DiscountCard dc ON c.card_id=dc.id
GROUP BY dc.discount_rate, c.customer_fio

-- 5. Объдинение, пересечение, разность

-- 5.1 Привести примеры 3-4 запросов с использованием UNION / UNION ALL, EXCEPT, INTERSECT. 
-- Данные  в одном из запросов отсортируйте по произвольному признаку.

SELECT name_product, manufacturer
FROM Products
WHERE manufacturer='Овощевод'
UNION
SELECT name_product, manufacturer
FROM Products
WHERE manufacturer='Овощевод' or manufacturer='Петелинка'
ORDER BY name_product

SELECT name_product, manufacturer
FROM Products
WHERE manufacturer='Овощевод'
UNION ALL
SELECT name_product, manufacturer
FROM Products
WHERE manufacturer='Овощевод' or manufacturer='Петелинка'
ORDER BY name_product

SELECT *
FROM Customer  
EXCEPT  
SELECT *  
FROM Customer  
WHERE card_id IS NOT NULL

SELECT id, sale_datetime, final_amount 
FROM Sale
WHERE final_amount BETWEEN 100 AND 1000 
INTERSECT
SELECT id, sale_datetime, final_amount 
FROM Sale
WHERE final_amount BETWEEN 500 AND 5000

-- 6. Использование CASE, PIVOT и UNPIVOT.

-- 6.1 Привести примеры получения сводных (итоговых) таблиц с использованием CASE

SELECT  
    s.id AS 'Номер чека',  
    c.customer_fio AS 'Покупатель',  
    s.total_amount AS 'Сумма покупки',  
    CASE  
        WHEN c.card_id IS NOT NULL THEN 'Уже есть'  
        WHEN (s.total_amount > 2000 AND c.card_id IS NULL) THEN 'Выдать на 4%'  
        WHEN (s.total_amount > 500 AND c.card_id IS NULL) THEN 'Выдать на 2%'  
        ELSE 'Скидка не положена'  
    END AS 'Скидочная карта'  
FROM Sale s  
LEFT JOIN Customer c ON s.customer_id = c.id

SELECT
    s.id AS 'Номер чека',
    c.customer_fio AS 'Покупатель',
    SUM(CASE WHEN p.manufacturer='Петелинка' THEN 1 ELSE 0 END) AS 'Кол-во товаров от "Петелинка"'
FROM Sale s
LEFT JOIN Customer c ON s.customer_id = c.id
LEFT JOIN SaleItem si ON s.id = si.sale_id
LEFT JOIN Products p ON p.id = si.product_id
GROUP BY s.id, c.customer_fio

-- 6.2 Привести примеры получения сводных (итоговых) таблиц с использованием PIVOT и UNPIVOT.

SELECT *
FROM (
    SELECT s.id, c.customer_fio, si.product_id, p.manufacturer
    FROM Sale s
    LEFT JOIN Customer c ON s.customer_id = c.id
    LEFT JOIN SaleItem si ON s.id = si.sale_id
    LEFT JOIN Products p ON p.id = si.product_id
    GROUP BY s.id, c.customer_fio, si.product_id, p.manufacturer
) AS src
PIVOT
(
    COUNT(product_id)
    FOR manufacturer IN ([Овощевод], [Петелинка], [Ярмолирод], [Хлебавода №1])
) AS pvt
ORDER BY id

SELECT id, name_product, price_type, price_value
FROM ( 
    SELECT id, name_product, purchase_price, selling_price 
    FROM Products 
) AS src 
UNPIVOT (
    price_value FOR price_type IN (purchase_price, selling_price)
) AS unpvt


-- Часть 2.	

-- a) Найти товары, у которых срок годности заканчивается сегодня.

SELECT
    id AS 'ID товара',
    name_product AS 'Название товара',
    production_date AS 'Дата производства',
    expiration_date AS 'Срок годности'
FROM Products
WHERE expiration_date = CAST(GETDATE() AS DATE)

-- b) Вывести все скидки, которые используются в супермаркете, и количество карт с этим % скидки.

SELECT
    dc.discount_rate AS 'Процент скидки',
    COUNT(dc.id) AS 'Всего карт в базе',
    COUNT(c.id) AS 'Карт у клиентов',
    COUNT(dc.id) - COUNT(c.id) AS 'Свободных карт'
FROM DiscountCard dc
LEFT JOIN Customer c ON dc.id = c.card_id
GROUP BY dc.discount_rate
ORDER BY dc.discount_rate

-- c) Подсчитать для каждого % скидки количество карточек, предъявленных за вчерашний день.

SELECT
    'Количество карт' AS 'Процент',
    COUNT(DISTINCT CASE WHEN dc.discount_rate = 0 THEN s.customer_id END) AS '0%',
    COUNT(DISTINCT CASE WHEN dc.discount_rate = 2 THEN s.customer_id END) AS '2%',
    COUNT(DISTINCT CASE WHEN dc.discount_rate = 4 THEN s.customer_id END) AS '4%'
FROM Sale s
JOIN Customer c ON s.customer_id = c.id
JOIN DiscountCard dc ON c.card_id = dc.id
WHERE CAST(s.sale_datetime AS DATE) = CAST(GETDATE() - 1 AS DATE)

-- d) Вывести список товаров, проданных за сегодня, их количество и суммарную стоимость.

SELECT 
    p.name_product AS 'Товар',
    SUM(si.quantity) AS 'Количество',
    p.unit AS 'Единица измерения',
    SUM(si.total_price) AS 'Суммарная стоимость'
FROM Sale s
LEFT JOIN SaleItem si ON s.id=si.sale_id
LEFT JOIN Products p ON si.product_id=p.id
WHERE CAST(s.sale_datetime AS DATE) = CAST(GETDATE() AS DATE)
GROUP BY p.id, p.name_product, p.unit

-- e) Подсчитать выручку супермаркета с начала текущего месяца.

SELECT 
    COALESCE(SUM(final_amount), 0) AS 'Выручка с начала месяца'
FROM Sale
WHERE YEAR(sale_datetime) = YEAR(GETDATE()) AND MONTH(sale_datetime) = MONTH(GETDATE())