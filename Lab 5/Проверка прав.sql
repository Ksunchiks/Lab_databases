-- Проверка прав администратора 

SELECT TOP 1 * FROM Employee 
SELECT TOP 1 * FROM Products

UPDATE DiscountCard SET discount_rate = 15.00 WHERE id = 1
INSERT INTO Customer (customer_fio, phone_number) VALUES ('Тест', '111')

EXEC ExpiredProducts
SELECT * FROM Manufacturers(1)
SELECT * FROM Selling

-- Проверка делегирования прав
BEGIN TRY
    GRANT SELECT ON Customer TO User_Cashier
    PRINT 'Может делегировать права (WITH GRANT OPTION работает)'
END TRY
BEGIN CATCH
    PRINT 'Не может делегировать права: ' + ERROR_MESSAGE()
END CATCH



-- Проверка прав кассира

SELECT TOP 1 * FROM Customer
SELECT TOP 1 * FROM Sale

UPDATE DiscountCard SET discount_rate = 10.00 WHERE id = 1
INSERT INTO Customer (customer_fio, phone_number) VALUES ('Тест Кассир', '444')

EXEC ExpiredProducts
SELECT TOP 1 * FROM Selling

-- запрещённая операция 
BEGIN TRY
    SELECT TOP 1 * FROM Employee
    PRINT 'Ошибка: Увидел сотрудников!'
END TRY
BEGIN CATCH
    PRINT 'Правильно: Не видит сотрудников'
END CATCH
