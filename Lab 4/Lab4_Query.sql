-- Создать  4 различных хранимых процедуры:

-- a) Процедура без параметров, формирующая список товаров с истекшим сроком годности

-- DROP PROCEDURE ExpiredProducts;
-- GO

CREATE PROCEDURE ExpiredProducts
AS
BEGIN
    SELECT 
        id,
        name_product,  
        production_date,
        expiration_date
    FROM Products
    WHERE expiration_date < CAST(GETDATE() AS DATE)
    ORDER BY expiration_date
END;
GO

EXEC ExpiredProducts;
GO

-- b) Процедура, которая для заданной корзины формирует список лежащих в ней товаров 
-- в виде: название, количество, дата производства

CREATE PROCEDURE FoodBasket
    @sale_id INT
AS
BEGIN
    SELECT 
        p.name_product AS 'Название',
        CAST(si.quantity AS VARCHAR(10)) + ' ' + p.unit AS 'Количество',
        p.production_date AS 'Дата производства'
    FROM SaleItem si
    JOIN Products p ON si.product_id = p.id
    WHERE si.sale_id = @sale_id
END;
GO

EXEC FoodBasket @sale_id = 1;
GO

-- c) Процедура, на входе получающая % скидки для карты, выходной параметр – количество
-- карт с этой скидкой, по которым были сделаны покупки более чем на 1 000 р.

CREATE PROCEDURE CountCards
    @discount_rate DECIMAL(5,2),  
    @card_count INT OUTPUT        
AS
BEGIN
    SELECT @card_count = COUNT(DISTINCT dc.id)
    FROM DiscountCard dc
    JOIN Customer c ON dc.id = c.card_id
    JOIN Sale s ON c.id = s.customer_id
    WHERE dc.discount_rate = @discount_rate AND s.final_amount > 1000
END;
GO

DECLARE @result INT;
EXEC CountCards @discount_rate = 3.00, @card_count = @result OUTPUT;
PRINT 'Количество использованных карт: ' + CAST(@result AS VARCHAR);
GO

-- d) Процедура, вызывающая вложенную процедуру, которая находит за последний год день
-- с наибольшей выручкой. Главная процедура подсчитывает прибыль супермаркета за этот 
-- день (прибыль = выручка - суммарная закупочная стоимость товаров)

CREATE PROCEDURE MaxDay -- вложенная процедура
    @max_day DATE OUTPUT
AS
BEGIN
    SELECT TOP 1 @max_day = CAST(sale_datetime AS DATE)
    FROM Sale
    WHERE sale_datetime >= DATEADD(YEAR, -1, GETDATE())
    GROUP BY CAST(sale_datetime AS DATE)
    ORDER BY SUM(final_amount) DESC
END;
GO

CREATE PROCEDURE CalculateProfit -- главная процедура
    @date DATE OUTPUT,
    @day_profit DECIMAL(15,2) OUTPUT
AS
BEGIN
    DECLARE @revenue DECIMAL(15,2);
    DECLARE @purchase_cost DECIMAL(15,2);
    
    -- вызываем вложенную процедуру чтобы найти день
    EXEC MaxDay @max_day = @date OUTPUT;
    
    -- считаем выручку за этот день
    SELECT @revenue = SUM(final_amount)
    FROM Sale
    WHERE CAST(sale_datetime AS DATE) = @date
    
    -- считаем закупочную стоимость проданных товаров
    SELECT @purchase_cost = SUM(si.quantity * p.purchase_price)
    FROM SaleItem si  
    JOIN Products p ON si.product_id = p.id
    JOIN Sale s ON si.sale_id = s.id 
    WHERE CAST(s.sale_datetime AS DATE) = @date
    
    -- считаем прибыль
    SET @day_profit = @revenue - @purchase_cost;
END;
GO

DECLARE @day DATE, @profit DECIMAL(15,2);
EXEC CalculateProfit @date = @day OUTPUT, @day_profit = @profit OUTPUT;
SELECT @day AS 'Дата', @profit AS 'Прибыль';
GO


-- Создать 3 пользовательских функции:

 -- a) Скалярная функция, подсчитывающая прибыль супермаркета за заданный период
 -- (прибыль = выручка - суммарная закупочная стоимость товаров)

CREATE FUNCTION Profit (@start_date DATE, @end_date DATE)
RETURNS DECIMAL(15,2)
AS
BEGIN
    DECLARE @profit DECIMAL(15,2);
    
    SELECT @profit = 
        (SELECT SUM(final_amount) -- выручка
         FROM Sale
         WHERE CAST(sale_datetime AS DATE) BETWEEN @start_date AND @end_date) 
        - 
        (SELECT SUM(si.quantity * p.purchase_price) -- сумма закупки
         FROM SaleItem si
         JOIN Products p ON si.product_id = p.id
         JOIN Sale s ON si.sale_id = s.id
         WHERE CAST(s.sale_datetime AS DATE) BETWEEN @start_date AND @end_date)

    RETURN @profit;
END;
GO

SELECT dbo.Profit('2025-09-01', '2025-11-01') AS Прибыль;
GO

-- b) Inline-функция, по заданной карте возвращающая список производителей товаров, 
-- которые когда-либо покупались владельцем карты

CREATE FUNCTION Manufacturers
(
    @card_id INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT DISTINCT p.manufacturer AS Производитель
    FROM Sale s
    JOIN Customer c ON s.customer_id = c.id
    JOIN SaleItem si ON s.id = si.sale_id
    JOIN Products p ON si.product_id = p.id
    WHERE c.card_id = @card_id
);
GO

SELECT * FROM dbo.Manufacturers(1)
GO

-- c) Multi-statement-функция, выдающая список карт, суммарная стоимость покупок по которым 
-- превысила 10 000р., в виде: номер карты, % скидки, общая сумма покупок по карте

--IF OBJECT_ID('dbo.ListCards', 'TF') IS NOT NULL
--    DROP FUNCTION dbo.ListCards;
--GO

CREATE FUNCTION ListCards()
RETURNS @result TABLE 
(
    card_number INT,
    discount_rate DECIMAL(5,2),
    total_purchases DECIMAL(15,2)
)
AS
BEGIN
    INSERT INTO @result
    SELECT 
        dc.id AS card_number,
        dc.discount_rate,
        SUM(s.final_amount) AS total_purchases
    FROM DiscountCard dc
    JOIN Customer c ON dc.id = c.card_id
    JOIN Sale s ON c.id = s.customer_id
    GROUP BY dc.id, dc.discount_rate
    HAVING SUM(s.final_amount) > 10000
    
    RETURN;
END;
GO

SELECT * FROM dbo.ListCards();
GO


-- Создать  3 триггера:

-- a) Триггер любого типа на добавление корзины – если сумма товаров > 500р. и нет карты, 
-- то добавляем карту с 2%-ной скидкой, если сумма > 2000р. и нет карты, то добавляем 
-- карту с 4%-ной скидкой, если сумма > 2000р. и карта есть, то устанавливаем скидку в 4%

--DROP TRIGGER AddingCard;
--GO

--DBCC CHECKIDENT ('DiscountCard', RESEED, 15);  
--GO

--DBCC CHECKIDENT ('Sale', RESEED, 15);
--GO

CREATE TRIGGER AddingCard
ON Sale 
AFTER INSERT -- срабатывает после добавления записи
AS
BEGIN
    DECLARE @sale_id INT, @total_amount DECIMAL(12,2), 
    @customer_id INT, @card_id INT, @new_card_id INT;
    
    -- создание курсора
    DECLARE sale_cursor CURSOR FOR 
    SELECT id, total_amount, customer_id 
    FROM inserted
    
    OPEN sale_cursor
    FETCH NEXT FROM sale_cursor INTO @sale_id, @total_amount, @customer_id
    
    -- цикл для чтения данных
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- получаем card_id из Customer (если клиент существует)
        IF @customer_id IS NOT NULL
            BEGIN
                SELECT @card_id = card_id 
                FROM Customer 
                WHERE id = @customer_id;
            
                -- обработка корзины
                IF @total_amount > 2000 AND (@card_id IS NULL OR @customer_id IS NULL)
                    BEGIN
                        -- добавляем карту с 4% скидкой
                        INSERT INTO DiscountCard (discount_rate) VALUES (4.00)
                        SET @new_card_id = SCOPE_IDENTITY();
                        -- привязываем карту к клиенту (если клиент существует)
                        IF @customer_id IS NOT NULL
                            UPDATE Customer SET card_id = @new_card_id WHERE id = @customer_id    
                        PRINT 'Добавлена карта с 4% скидкой для корзины ID: ' + CAST(@sale_id AS VARCHAR);
                    END

                ELSE IF @total_amount > 500 AND (@card_id IS NULL OR @customer_id IS NULL)
                    BEGIN
                        -- Добавляем карту с 2% скидкой
                        INSERT INTO DiscountCard (discount_rate) VALUES (2.00)
                        SET @new_card_id = SCOPE_IDENTITY();
                
                        IF @customer_id IS NOT NULL
                            UPDATE Customer SET card_id = @new_card_id WHERE id = @customer_id;
                        PRINT 'Добавлена карта с 2% скидкой для корзины ID: ' + CAST(@sale_id AS VARCHAR);
                    END

                ELSE IF @total_amount > 2000 AND @card_id IS NOT NULL
                    BEGIN
                        -- Обновляем существующую карту на 4%
                        UPDATE DiscountCard SET discount_rate = 4.00 WHERE id = @card_id;
                        PRINT 'Обновлена карта на 4% скидку для корзины ID: ' + CAST(@sale_id AS VARCHAR);
                    END
            END

        ELSE
            PRINT 'Корзина ID: ' + CAST(@sale_id AS VARCHAR) + ' - нет клиента, карта не выдана';
      
        -- чтение следующей записи или конец
        FETCH NEXT FROM sale_cursor INTO @sale_id, @total_amount, @customer_id;
    END
    
    CLOSE sale_cursor;
    DEALLOCATE sale_cursor;
END;
GO

INSERT INTO Sale (total_amount, discount_amount, final_amount, customer_id, employee_id) VALUES 
(600, 0, 600, 15, 1),  -- карта 2%
(2500, 0, 2500, 3, 1),  -- карта 4%
(3000, 0, 3000, 1, 1),  -- обновит карту на 4%
(1000, 0, 1000, NULL, 1);  -- карта не выдана
GO

--DELETE FROM Sale WHERE CAST(sale_datetime AS DATE) = '2025-11-20'
--DELETE FROM DiscountCard WHERE id > 15
--UPDATE Customer SET card_id = NULL WHERE id = 3


-- b)  Последующий триггер на изменение цены продажи товара – если цена продажи меньше, чем 
-- закупочная цена, изменение отменяется, выводится соотв. сообщение

CREATE TRIGGER PriceChange
ON Products 
AFTER UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 
               FROM inserted i
               WHERE selling_price < purchase_price)
    BEGIN
        ROLLBACK TRANSACTION; -- отмена изменения
        RAISERROR('Цена продажи не может быть ниже закупочной цены! Изменение отменено.', 16, 1);
    END
END;
GO

-- цена закупки = 45
UPDATE Products 
SET selling_price = 40 -- ошибка
WHERE id = 1
GO

-- c) Замещающий триггер на операцию удаления – при удалении товара из корзины (возврат товара) вернуть 
-- его в супермаркет, пересчитать стоимость корзины

CREATE TRIGGER ReturnProduct
ON SaleItem 
INSTEAD OF DELETE -- выполняется вместо задания(удаления)
AS
BEGIN
    -- возвращаем товары на склад 
    UPDATE Products 
    SET stock_quantity = stock_quantity + d.quantity
    FROM Products p
    JOIN deleted d ON p.id = d.product_id;
    
    -- удаляем товары из корзины 
    DELETE FROM SaleItem 
    WHERE id IN (SELECT id FROM deleted);
    
    -- пересчитываем стоимость корзины
    UPDATE Sale
    SET total_amount = ISNULL(si.total_price, 0),
        final_amount = ISNULL(si.total_price, 0) - s.discount_amount
    FROM Sale s
    JOIN (SELECT sale_id, SUM(total_price) as total_price
          FROM SaleItem 
          GROUP BY sale_id) si ON s.id = si.sale_id
    WHERE s.id IN (SELECT sale_id FROM deleted);
    
    DECLARE @processed_count INT = (SELECT COUNT(*) FROM deleted);
    PRINT 'Удалено позиций: ' + CAST(@processed_count AS VARCHAR) + 
          '. Товары возвращены на склад, корзина пересчитана.';
END;
GO

DELETE FROM SaleItem WHERE sale_id = 2 AND product_id IN (2, 4);
GO