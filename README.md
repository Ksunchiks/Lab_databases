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

<h3 align="center">
  <a href="#client"></a>
Вариант №9: Автоматизация супермаркета
</h3>

Примеры сущностей:
- Товары: код, название товара, цена продажи, закупочная цена, единица измерения (шт., кг.), производитель, дата производства, срок годности, количество;
- Карточки, выданные покупателям: Код карточки, размер скидки в %.
- Корзина: Товары, которые набрал покупатель и предъявляет к оплате на кассе, дата покупки, фамилия кассира;


Реализовать:
- Вывод товаров с истекшим сроком годности
- Подсчет выручки супермаркета за заданный период.
- Подсчет стоимости корзины
- Определение скидки для корзины (если предъявлена карта, сумму уменьшаем на размер скидки; если карта не предъявлена и если сумма > 2000руб., выписываем карту со скидкой 4%, если сумма > 500руб., выписываем карту 2%);


# <img src="https://github.com/user-attachments/assets/e080adec-6af7-4bd2-b232-d43cb37024ac" width="20" height="20"/> Lab1
[Назад](#content)
<h3 align="left">
  <a href="#client"></a>
</h3>
Разработать ER-модель данной предметной области: выделить сущности, их атрибуты, связи между сущностями. 
Для каждой сущности указать ее имя, атрибут (или набор атрибутов), являющийся первичным ключом, список остальных атрибутов.
Для каждого атрибута указать его тип, ограничения, может ли он быть пустым, является ли он первичным ключом.

Для каждой связи между сущностями указать: 
- тип связи (1:1, 1:M, M:N)
- обязательность

ER-модель д.б. представлена в виде ER-диаграммы (картинка)
По имеющейся ER-модели создать реляционную модель данных и отобразить ее в виде списка сущностей с их атрибутами и типами атрибутов,  для атрибутов указать, явл. ли он первичным или внешним ключом 

<h3 align="left">
  <a href="#client"></a>
1.1 ER-модель
  
![image](https://github.com/Ksunchiks/Lab_databases/blob/main/Lab%201/er_model.png)
 
1.2 Реляционная модель

![image](https://github.com/Ksunchiks/Lab_databases/blob/main/Lab%201/реляционная%20модель.png)

# <img src="https://github.com/user-attachments/assets/e080adec-6af7-4bd2-b232-d43cb37024ac" width="20" height="20"/> Lab2
[Назад](#content) 
<h3 align="left"> 
  <a href="#client"></a>
</h3>

В соответствии с реляционной моделью данных, разработанной в Лаб.№1, создать реляционную БД на учебном сервере БД :
- создать таблицы, определить первичные ключи и иные ограничения
- определить связи между таблицами
- создать диаграмму
- заполнить все таблицы адекватной информацией (не меньше 10 записей в таблицах, наличие примеров для связей типа 1:M )

<h3 align="left">
  <a href="#client"></a>
1.1 Diagram supermarket
  
![image](https://github.com/Ksunchiks/Lab_databases/blob/main/Lab%202/diagram_supermarket.png)
