-- 1. Создание графовых таблиц --

-- Таблицы узлов --

CREATE TABLE ProductsNode (
    id INT PRIMARY KEY,
    name_product NVARCHAR(100) NOT NULL,
    purchase_price DECIMAL(10,2) NOT NULL CHECK (purchase_price >= 0),
    selling_price DECIMAL(10,2) NOT NULL CHECK (selling_price >= 0),
    unit NVARCHAR(10) NOT NULL CHECK (unit IN ('шт', 'кг')),
    manufacturer NVARCHAR(100),
    production_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    stock_quantity DECIMAL(10,3) NOT NULL CHECK (stock_quantity >= 0),
    CHECK (expiration_date >= production_date)
) AS NODE;

CREATE TABLE DiscountCardNode (
    id INT PRIMARY KEY,
    discount_rate DECIMAL(5,2) NOT NULL CHECK (discount_rate >= 0 AND discount_rate < 100)
) AS NODE;

CREATE TABLE CustomerNode (
    id INT PRIMARY KEY,
    customer_fio NVARCHAR(100) NOT NULL,
    phone_number NVARCHAR(20) UNIQUE
) AS NODE;

CREATE TABLE EmployeeNode (
    id INT PRIMARY KEY,
    employee_fio NVARCHAR(100) NOT NULL,
    role NVARCHAR(100) NOT NULL
) AS NODE;

CREATE TABLE SaleNode (
    id INT PRIMARY KEY,
    sale_datetime DATETIME NOT NULL DEFAULT GETDATE(),
    total_amount DECIMAL(12,2) NOT NULL CHECK (total_amount >= 0),
    discount_amount DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (discount_amount >= 0),
    final_amount DECIMAL(12,2) NOT NULL CHECK (final_amount >= 0),
    CHECK (discount_amount <= total_amount),
    CHECK (final_amount = total_amount - discount_amount)
) AS NODE;

CREATE TABLE SaleItemNode (
    id INT PRIMARY KEY,
    quantity DECIMAL(10,3) NOT NULL CHECK (quantity >= 0),
    price_per_unit DECIMAL(10,2) NOT NULL CHECK (price_per_unit >= 0),
    total_price DECIMAL(10,2) NOT NULL CHECK (total_price >= 0),
    CHECK (total_price = quantity * price_per_unit)
) AS NODE;


-- Таблицы рёбер --

-- Покупатель имеет карту
CREATE TABLE Has_Card AS EDGE;

-- Продажа (чек) оформлена сотрудником
CREATE TABLE Made_By AS EDGE;

-- Покупка (чек) принадлежит покупателю
CREATE TABLE Purchased_By AS EDGE;

-- Позиция относится к покупке (чеку)
CREATE TABLE In_Sale AS EDGE;

-- Позиция относится к товару
CREATE TABLE Is_Product AS EDGE;



-- 2. Заполнение таблиц --

-- Заполнение узлов --

INSERT INTO ProductsNode (id, name_product, purchase_price, selling_price, unit, manufacturer, production_date, expiration_date, stock_quantity)
SELECT id, name_product, purchase_price, selling_price, unit, manufacturer, production_date, expiration_date, stock_quantity 
FROM Products;  

INSERT INTO DiscountCardNode (id, discount_rate)
SELECT id, discount_rate 
FROM DiscountCard;

INSERT INTO CustomerNode (id, customer_fio, phone_number)
SELECT id, customer_fio, phone_number 
FROM Customer;

INSERT INTO EmployeeNode (id, employee_fio, role)
SELECT id, employee_fio, role 
FROM Employee;

INSERT INTO SaleNode (id, sale_datetime, total_amount, discount_amount, final_amount)
SELECT id, sale_datetime, total_amount, discount_amount, final_amount 
FROM Sale;

INSERT INTO SaleItemNode (id, quantity, price_per_unit, total_price)
SELECT id, quantity, price_per_unit, total_price 
FROM SaleItem;


-- Заполнение рёбер --

-- CustomerNode -> [Has_Card] -> DiscountCardNode
INSERT INTO Has_Card ($from_id, $to_id)
SELECT 
    (SELECT $node_id FROM CustomerNode WHERE id = c.id),
    (SELECT $node_id FROM DiscountCardNode WHERE id = c.card_id)
FROM Customer c
WHERE c.card_id IS NOT NULL;

-- SaleNode -> [Made_By] -> EmployeeNode
INSERT INTO Made_By ($from_id, $to_id)
SELECT 
    (SELECT $node_id FROM SaleNode WHERE id = s.id),
    (SELECT $node_id FROM EmployeeNode WHERE id = s.employee_id)
FROM Sale s;

-- SaleNode -> [Purchased_By] -> CustomerNode 
INSERT INTO Purchased_By ($from_id, $to_id)
SELECT 
    (SELECT $node_id FROM SaleNode WHERE id = s.id),
    (SELECT $node_id FROM CustomerNode WHERE id = s.customer_id)
FROM Sale s
WHERE s.customer_id IS NOT NULL;

-- SaleItemNode -> [In_Sale] -> SaleNode 
INSERT INTO In_Sale ($from_id, $to_id)
SELECT 
    (SELECT $node_id FROM SaleItemNode WHERE id = si.id),
    (SELECT $node_id FROM SaleNode WHERE id = si.sale_id)
FROM SaleItem si;

-- SaleItemNode -> [Is_Product] -> ProductsNode 
INSERT INTO Is_Product ($from_id, $to_id)
SELECT 
    (SELECT $node_id FROM SaleItemNode WHERE id = si.id),
    (SELECT $node_id FROM ProductsNode WHERE id = si.product_id)
FROM SaleItem si;