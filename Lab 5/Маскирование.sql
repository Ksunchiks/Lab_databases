-- 1. Динамическое маскирование данных (DDM)

-- Маскирование телефона покупателя
ALTER TABLE Customer 
ALTER COLUMN phone_number ADD MASKED WITH (FUNCTION = 'partial(2,"-XXX-XXX-XX-",2)')

-- Маскирование закупочной цены товара
ALTER TABLE Products 
ALTER COLUMN purchase_price ADD MASKED WITH (FUNCTION = 'default()')

GRANT UNMASK TO Role_Administrator

-- Проверка для администратора 1
EXECUTE AS USER = 'User_Administrator'
SELECT * FROM Customer
REVERT

-- Проверка для кассира 1
EXECUTE AS USER = 'User_Cashier'
SELECT * FROM Customer
REVERT

-- Проверка для администратора 2
EXECUTE AS USER = 'User_Administrator'
SELECT id, name_product, purchase_price FROM Products
REVERT

-- Проверка для кассира 2
EXECUTE AS USER = 'User_Cashier'
SELECT id, name_product, purchase_price FROM Products
REVERT
GO


-- 2. Маскирование с помощью представлений, процедур и функций

-- Функция для маскирования ФИО
--DROP FUNCTION IF EXISTS MaskFio
--GO

CREATE FUNCTION MaskFio (@original_fio NVARCHAR(100))
RETURNS NVARCHAR(100)
AS
BEGIN
    DECLARE @result NVARCHAR(100)
    
    IF IS_MEMBER('Role_Administrator') = 1
        SET @result = @original_fio
    ELSE
        SET @result = LEFT(@original_fio, 3) + 'xxxx'
    
    RETURN @result
END
GO

-- Представление для покупателей с маскированием
CREATE VIEW Customers_Masked
AS
SELECT id, dbo.MaskFio(customer_fio) AS customer_fio, phone_number,card_id
FROM Customer
GO

-- Предоставление прав на чтение
GRANT SELECT ON Customers_Masked TO Role_Administrator
GRANT SELECT ON Customers_Masked TO Role_Cashier

-- Проверка для администратора 
EXECUTE AS USER = 'User_Administrator'
SELECT * FROM Customers_Masked
REVERT

-- Проверка для кассира 
EXECUTE AS USER = 'User_Cashier'
SELECT * FROM Customers_Masked
REVERT