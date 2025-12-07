-- Напишите запросы из задания 3.2 используя паттерн MATCH.
-- Сравните полученные результаты с результатами запросов к реляционной модели. 

-- a) Найти товары, у которых срок годности заканчивается сегодня.

SELECT
    id AS 'ID товара',
    name_product AS 'Название товара',
    production_date AS 'Дата производства',
    expiration_date AS 'Срок годности'
FROM Products
WHERE expiration_date = '2025-10-17'

-- match не нужен, т.к. всего 1 узел
SELECT
    id AS 'ID товара',
    name_product AS 'Название товара',
    production_date AS 'Дата производства',
    expiration_date AS 'Срок годности'
FROM ProductsNode 
WHERE expiration_date = '2025-10-17'


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

-- не используем match т.к. нужны все карты, а не только используемые
SELECT
    dc.discount_rate AS 'Процент скидки',
    COUNT(dc.id) AS 'Всего карт в базе',
    COUNT(hc.$edge_id) AS 'Карт у клиентов',
    COUNT(dc.id) - COUNT(hc.$edge_id) AS 'Свободных карт'
FROM DiscountCardNode dc
LEFT JOIN Has_Card hc ON dc.$node_id = hc.$to_id
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
WHERE CAST(s.sale_datetime AS DATE) = '2025-09-28'

-- match нужен, т.к. используем связи
SELECT
    'Количество карт' AS 'Процент',
    COUNT(DISTINCT CASE WHEN dc.discount_rate = 0 THEN c.id END) AS '0%',
    COUNT(DISTINCT CASE WHEN dc.discount_rate = 2 THEN c.id END) AS '2%',
    COUNT(DISTINCT CASE WHEN dc.discount_rate = 4 THEN c.id END) AS '4%'
FROM SaleNode s, Purchased_By pb, CustomerNode c, Has_Card hc, DiscountCardNode dc
WHERE MATCH(s-(pb)->c-(hc)->dc) AND CAST(s.sale_datetime AS DATE) = '2025-09-28'


-- d) Вывести список товаров, проданных за сегодня, их количество и суммарную стоимость.

SELECT 
    p.name_product AS 'Товар',
    SUM(si.quantity) AS 'Количество',
    p.unit AS 'Единица измерения',
    SUM(si.total_price) AS 'Суммарная стоимость'
FROM Sale s
JOIN SaleItem si ON s.id=si.sale_id
JOIN Products p ON si.product_id=p.id
WHERE CAST(s.sale_datetime AS DATE) ='2025-09-27'
GROUP BY p.id, p.name_product, p.unit

-- match используем
SELECT 
    p.name_product AS 'Товар',
    SUM(si.quantity) AS 'Количество',
    p.unit AS 'Единица измерения',
    SUM(si.total_price) AS 'Суммарная стоимость'
FROM SaleNode s, In_Sale ins, SaleItemNode si, Is_Product ip, ProductsNode p
WHERE MATCH(si-(ins)->s AND si-(ip)->p) AND CAST(s.sale_datetime AS DATE) = '2025-09-27'
GROUP BY p.id, p.name_product, p.unit


-- e) Подсчитать выручку супермаркета с начала текущего месяца.

SELECT 
    COALESCE(SUM(final_amount), 0) AS 'Выручка с начала месяца'
FROM Sale
WHERE YEAR(sale_datetime) = 2025 AND MONTH(sale_datetime) = 9

-- match не нужен, т.к. используем только 1 узел
SELECT 
    COALESCE(SUM(final_amount), 0) AS 'Выручка с начала месяца'
FROM SaleNode
WHERE YEAR(sale_datetime) = 2025 AND MONTH(sale_datetime) = 9