-- Задание 1: Транзакции --


-- Исходные данные в таблице Employee
SELECT * FROM Employee;



-- Начинаем транзакцию
BEGIN TRANSACTION;

-- Добавляем нового сотрудника
INSERT INTO Employee (employee_fio, role) VALUES 
('Борисова Екатерина Андреевна', 'Стажёр');

-- Создаем точку сохранения
SAVE TRANSACTION save_point;

-- Добавляем ещё одного сотрудника
INSERT INTO Employee (employee_fio, role) VALUES 
('Цветков Евгений Иванович', 'Товаровед');

-- Проверяем, что данные новых сотрудников добавлены
SELECT * FROM Employee WHERE role IN ('Стажёр', 'Товаровед');



-- Откатываем транзакцию до точки сохранения
ROLLBACK TRANSACTION save_point;

-- Проверяем, что данные первого сотрудника остались, а данные 
-- второго сотрудника были удалены после отката
SELECT * FROM Employee WHERE role IN ('Стажёр', 'Товаровед');



-- После отката снова добавляем ещё одного сотрудника
INSERT INTO Employee (employee_fio, role) VALUES 
('Цветков Евгений Иванович', 'Товаровед');

-- Завершаем транзакцию
COMMIT TRANSACTION;

-- Проверяем, что данные обоих сотрудников были сохранены
SELECT * FROM Employee WHERE role IN ('Стажёр', 'Товаровед');