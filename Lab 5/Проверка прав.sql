-- Проверка прав администратора --

SELECT * FROM Employee 
SELECT * FROM Products

UPDATE DiscountCard SET discount_rate = 15.00 WHERE id = 1
INSERT INTO Customer (customer_fio, phone_number) VALUES ('Тест', '111')

EXEC ExpiredProducts
SELECT * FROM Manufacturers(1)
SELECT * FROM Selling

-- проверка передачи прав
BEGIN TRY
    GRANT SELECT ON Customer TO User_Cashier
    PRINT 'Может передавать права (WITH GRANT OPTION работает)'
END TRY
BEGIN CATCH
    PRINT 'Не может передавать права: ' + ERROR_MESSAGE()
END CATCH



-- Проверка прав кассира --

SELECT * FROM Customer
SELECT * FROM Sale

UPDATE DiscountCard SET discount_rate = 10.00 WHERE id = 1
INSERT INTO Customer (customer_fio, phone_number) VALUES ('Тест Кассир', '444')

EXEC ExpiredProducts
SELECT * FROM Selling

-- запрещённая операция 
BEGIN TRY
    SELECT * FROM Employee
    PRINT 'Ошибка: Увидел сотрудников!'
END TRY
BEGIN CATCH
    PRINT 'Правильно: Не видит сотрудников'
END CATCH

