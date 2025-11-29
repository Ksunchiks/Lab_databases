-- Создание пользователей 
CREATE LOGIN User_Administrator WITH PASSWORD = '1234567'
CREATE USER User_Administrator FOR LOGIN User_Administrator 

CREATE LOGIN User_Cashier WITH PASSWORD = '1234567'
CREATE USER User_Cashier FOR LOGIN User_Cashier 

-- Создание ролей
CREATE ROLE Role_Administrator -- для администраторов 
CREATE ROLE Role_Cashier -- для обычных кассиров

-- Добавляем пользователей к ролям 
ALTER ROLE Role_Administrator ADD MEMBER User_Administrator
ALTER ROLE Role_Cashier ADD MEMBER User_Cashier


-- Выдаем права администратору  --

-- Права на работу с таблицами 
GRANT SELECT, INSERT, UPDATE ON Employee TO Role_Administrator
DENY DELETE ON Employee TO Role_Administrator -- запрет на удаление (нужно архивировать)

GRANT SELECT, INSERT, UPDATE ON Customer TO Role_Administrator WITH GRANT OPTION
DENY DELETE ON Customer TO Role_Administrator 

GRANT SELECT, INSERT, UPDATE ON DiscountCard TO Role_Administrator WITH GRANT OPTION
DENY DELETE ON DiscountCard TO Role_Administrator 

GRANT SELECT ON Products TO Role_Administrator WITH GRANT OPTION -- другие смогут только читать
GRANT INSERT, UPDATE, DELETE ON Products TO Role_Administrator

GRANT SELECT ON Sale TO Role_Administrator WITH GRANT OPTION 
GRANT INSERT, UPDATE, DELETE ON Sale TO Role_Administrator

GRANT SELECT ON SaleItem TO Role_Administrator WITH GRANT OPTION 
GRANT INSERT, UPDATE, DELETE ON SaleItem TO Role_Administrator

-- Права на выполнение процедур
GRANT EXECUTE ON CalculateProfit TO Role_Administrator -- прибыль за день с наибольшей выручкой
GRANT EXECUTE ON CountCards TO Role_Administrator -- кол-во кард со скидкой, по которым купили > на 1000р
GRANT EXECUTE ON ExpiredProducts TO Role_Administrator WITH GRANT OPTION -- список товаров с истёкшим сроком годности
GRANT EXECUTE ON FoodBasket TO Role_Administrator WITH GRANT OPTION -- список товаров из корзины(имя, дата, кол-во)
GRANT EXECUTE ON MaxDay TO Role_Administrator -- день с наибольшей выручкой за последний год

-- Права на выполнение функций
GRANT EXECUTE ON Profit TO Role_Administrator -- прибыль за период
GRANT SELECT ON Manufacturers TO Role_Administrator -- список производителей, котрые когда либо покупались владельцем карты
GRANT SELECT ON ListCards TO Role_Administrator WITH GRANT OPTION -- список карт, суммарная стоимость покупок по которым превысила 10 000р.

-- Права на представления
GRANT SELECT ON Product_unit_purchase TO Role_Administrator -- кол-во товара куплено и выручка
GRANT SELECT ON Selling TO Role_Administrator WITH GRANT OPTION -- вывод сотрудника и номер оформленной продажи


-- Выдаем права кассиру --

-- Права на работу с таблицами 
DENY SELECT, INSERT, UPDATE, DELETE ON Employee TO Role_Cashier
GRANT SELECT, INSERT ON Customer TO Role_Cashier   
GRANT SELECT, INSERT, UPDATE ON DiscountCard TO Role_Cashier  
GRANT SELECT ON Products TO Role_Cashier  
GRANT SELECT, INSERT ON Sale TO Role_Cashier         
GRANT SELECT, INSERT ON SaleItem TO Role_Cashier  

-- Права на выполнение процедур             
GRANT EXECUTE ON ExpiredProducts TO Role_Cashier           
GRANT EXECUTE ON FoodBasket TO Role_Cashier   
DENY EXECUTE ON CalculateProfit TO Role_Cashier                
DENY EXECUTE ON CountCards TO Role_Cashier           
DENY EXECUTE ON MaxDay TO Role_Cashier 

-- Права на выполнение функций
GRANT SELECT ON ListCards TO Role_Cashier     
DENY SELECT ON Manufacturers TO Role_Cashier    
DENY EXECUTE ON Profit TO Role_Cashier

-- Права на представления
GRANT SELECT ON Selling TO Role_Cashier 
DENY SELECT ON Product_unit_purchase TO Role_Cashier
