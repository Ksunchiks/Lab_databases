<h1 name="content" align="center"><a href=""><img src="https://github.com/user-attachments/assets/e080adec-6af7-4bd2-b232-d43cb37024ac" width="20" height="20"/></a> MSSQL</h1>

<p align="center">
  <a href="#-lab1"><img alt="lab1" src="https://img.shields.io/badge/Lab1-blue"></a> 
  <a href="#-lab2"><img alt="lab2" src="https://img.shields.io/badge/Lab2-red"></a>
  <a href="#-lab3"><img alt="lab3" src="https://img.shields.io/badge/Lab3-green"></a>
  <a href="#-lab4"><img alt="lab4" src="https://img.shields.io/badge/Lab4-yellow"></a>
  <a href="#-lab5"><img alt="lab5" src="https://img.shields.io/badge/Lab5-gray"></a>
  <a href="#-lab6"><img alt="lab6" src="https://img.shields.io/badge/Lab6-orange"></a> 
  <a href="#-lab7"><img alt="lab7" src="https://img.shields.io/badge/Lab7-brown"></a>
  <a href="#-lab8"><img alt="lab8" src="https://img.shields.io/badge/Lab8-purple"></a>
  <a href="#-lab9"><img alt="lab9" src="https://img.shields.io/badge/Lab9-violet"></a> 
</p>

# <img src="https://github.com/user-attachments/assets/e080adec-6af7-4bd2-b232-d43cb37024ac" width="20" height="20"/> Lab1
[Назад](#content)
<h3 align="center">
  <a href="#client"></a>
  1.1 Формулировка лабораторной работы, например: "Разработать представления или хранимые процедуры для выполнения заданий."
</h3>

#### №6. Текст задания: Вывести все таблицы SQL Server без столбца identity.
```tsql
--- 
SELECT 1 
```

```tsql
-- Использование
EXEC GetTestData;
```

| DatabaseName | SchemaName | TableName | ObjectId |
| :--- | :--- | :--- | :--- |
| master | dbo | spt\_fallback\_db | 117575457 |
| master | dbo | spt\_fallback\_dev | 133575514 |
| master | dbo | spt\_fallback\_usg | 149575571 |
| master | dbo | spt\_monitor | 1803153469 |
| master | dbo | MSreplication\_options | 2107154552 |

| DatabaseName | SchemaName | TableName | ObjectId |
| :--- | :--- | :--- | :--- |
| Northwind | dbo | Customers | 901578250 |
| Northwind | dbo | Order Details | 965578478 |

| DatabaseName | SchemaName | TableName | ObjectId |
| :--- | :--- | :--- | :--- |
| msdb | dbo | sysssispackages | 231671873 |
| msdb | dbo | sysssispackagefolders | 311672158 |
| msdb | dbo | sysutility\_ucp\_aggregated\_mi\_health\_internal | 361768346 |
| msdb | dbo | syspolicy\_execution\_internal | 432720594 |
| ...  |

# <img src="https://github.com/user-attachments/assets/e080adec-6af7-4bd2-b232-d43cb37024ac" width="20" height="20"/> Lab2
[Назад](#content) 
<h3 align="center"> 
  <a href="#client"></a>
  2 Создать процедуру, которая принимает в качестве параметров имя таблицы и имена двух полей этой таблице и добавляет содержимое первого поля к содержимому второго. 
  Если второе поле пустое, то просто копируется содержимое поля 1 в содержимое поля 2 и наоборот.
</h3>

```tsql
-- После использования
SELECT * FROM SampleTable;
```

| ID | Field1 | Field2 |
| :--- | :--- | :--- |
| 1 | Hello | Hello |
| 2 | World | World |
| 3 | Goodbye | EveryoneGoodbye |
| 4 | null | null |

![image](/sources/yargu.png)
