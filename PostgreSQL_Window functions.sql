--Задание 1
/*1. Выведет названия городов в алфавитном порядке и их номер, тоже исходя из алфавитного порядка. Команда Distinct
не работает с Row_number, поэтому уникальность не будет обеспечена, только нарушится порядок строк, который восстановится
через order by. 
2. Выведет названия городов в алфавитном порядке и их номер, тоже исходя из алфавитного порядка.
Логика rownum в данном случае ранжирование городов по названию
3. Выведет неотсортированные названия стран, с присвоенными номерами исходя из алфавитного порядка, уникальности не будет,
т.к. Distinct в данном случае не работает.
4. Выведет города отсортированные по присвоенным номерам исходя из алфавитного порядка названий стран этих городов.*/

--Задание 2
--Получаем максимальное с помощью MAX
with emp as (
select  o.industry AS industry_with_max, c.first_name as name_ighest_sal FROM
(select industry, MAX (salary)
from "Salary"
GROUP BY industry) o Left JOIN
(select first_name, salary, industry
from "Salary") c ON o.industry = c.industry and o.MAX = c.salary)

select first_name, last_name, salary, s.industry, emp.name_ighest_sal
FROM "Salary" s Left JOIN emp ON s.industry = emp.industry_with_max

--Получаем максимальное с помощью FIRST_VALUE
with emp as (
select  o.industry AS industry_with_max, c.first_name as name_ighest_sal FROM
(SELECT DISTINCT industry, FIRST_VALUE(salary)
 OVER (PARTITION BY industry ORDER BY salary DESC
       RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
FROM "Salary") o Left JOIN
(select first_name, salary, industry
from "Salary") c ON o.industry = c.industry and o.FIRST_VALUE = c.salary)

select first_name, last_name, salary, s.industry, emp.name_ighest_sal
FROM "Salary" s Left JOIN emp ON s.industry = emp.industry_with_max

--Получаем минимальное с помощью MIN 
with emp as (
select  o.industry AS industry_with_min, c.first_name as name_ighest_sal FROM
(select industry, MIN (salary)
from "Salary"
GROUP BY industry) o Left JOIN
(select first_name, salary, industry
from "Salary") c ON o.industry = c.industry and o.Min = c.salary)

select first_name, last_name, salary, s.industry, emp.name_ighest_sal
FROM "Salary" s Left JOIN emp ON s.industry = emp.industry_with_min

--Получаем минимальное с помощью LAST_VALUE 
with emp as (
select  o.industry AS industry_with_min, c.first_name as name_ighest_sal FROM
(SELECT DISTINCT industry, LAST_VALUE(salary)
 OVER (PARTITION BY industry ORDER BY salary DESC
       RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
FROM "Salary") o Left JOIN
(select first_name, salary, industry
from "Salary") c ON o.industry = c.industry and o.LAST_VALUE = c.salary)

select first_name, last_name, salary, s.industry, emp.name_ighest_sal
FROM "Salary" s Left JOIN emp ON s.industry = emp.industry_with_min

--Задание 3
-- Для выполнения задания таблицы сконвертированы из xlsx в csv
select DISTINCT "SHOPNUMBER", "CITY", "ADDRESS", 
sum("QTY") over (partition by "SHOPNUMBER") as SUM_QTY,
sum(CAST("QTY" AS int) * "PRICE") over (partition by "SHOPNUMBER") as SUM_QTY_PRICE
from "SALES"
LEFT JOIN "GOODS" USING("ID_GOOD")
LEFT JOIN "SHOPS" USING("SHOPNUMBER")
where "DATE" = '1/2/2016'
ORDER by "SHOPNUMBER"

--Задание 4
select DISTINCT "DATE", "CITY",
round(sum(CAST("QTY" AS int) * "PRICE") over (partition by  "CITY", "DATE")* 100.0 /
      sum(CAST("QTY" AS int) * "PRICE") over (partition by  "CITY"), 1) as SUM_SALES_REL
from "SALES" 
LEFT JOIN "SHOPS" USING("SHOPNUMBER")
LEFT JOIN "GOODS" USING("ID_GOOD")
where "CATEGORY" = 'ЧИСТОТА'
order by "CITY"

--Задание 5
SELECT "DATE", "SHOPNUMBER", "ID_GOOD"
from
(select "DATE", "SHOPNUMBER", "ID_GOOD",
row_number() over (partition by "SHOPNUMBER", "DATE" order by "QTY" desc) as ranking
from "SALES" 
LEFT JOIN "SHOPS" USING("SHOPNUMBER"))
where ranking <4;

--Задание 6
with emp as (select DISTINCT "DATE", "SHOPNUMBER", "CATEGORY",
sum(CAST("QTY" AS int) * "PRICE") over (partition by "SHOPNUMBER", "CATEGORY","DATE") AS SUM_CATEGORY
from "SALES" 
LEFT JOIN "SHOPS" USING("SHOPNUMBER")
LEFT JOIN "GOODS" USING("ID_GOOD")
where "CITY" = 'СПб'
order by "DATE")

select "DATE", "SHOPNUMBER", "CATEGORY",
LAG(SUM_CATEGORY, 1) over (partition by "SHOPNUMBER", "CATEGORY" order by "DATE") AS PREV_SALES
from emp
order by "DATE"

--Задание 7
-- Если делать исходя из рекомендаций по query, 3 условие не будет выполняться,
-- может так и нужно из-за возможных пересечений с другим условием
CREATE TABLE query 
(
	searchid SMALLINT PRIMARY KEY,
    year SMALLINT NOT NULL,
    month  VARCHAR NOT NULL,
    day SMALLINT NOT NULL,
    userid SMALLINT NOT NULL,
    ts int NOT NULL,
    devicetype VARCHAR NOT NULL,
    deviceid SMALLINT NOT NULL,
	query TEXT NOT NULL
);

INSERT INTO query VALUES
    (1, 2023, 'october', 12, 123, 1697107800, 'android', 1234, 'найти'),
    (2, 2023, 'october', 12, 123, 1697107850, 'android', 1234, 'найти место'),
    (3, 2023, 'october', 12, 123, 1697107970, 'android', 1234, 'найти место для отдыха'),
    (4, 2023, 'october', 12, 123, 1697108030, 'android', 1234, 'найти место для отдыха с детьми'),
    (5, 2023, 'october', 12, 124, 1697140430, 'android', 1235, 'под'),
    (6, 2023, 'october', 12, 124, 1697144030, 'android', 1235, 'подарок маме'),
    (7, 2023, 'october', 15, 125, 1697403590, 'android', 1236, 'машина'),
    (8, 2023, 'october', 15, 126, 1697403593, 'IOS', 1237, 'календарь'),
    (9, 2023, 'november', 23, 127, 1700747993, 'IOS', 1238, 'Москва'),
    (10, 2023, 'november', 23, 127, 1700747998, 'android', 1239, 'Шла'),
    (11, 2023, 'november', 23, 127, 1700748048, 'android', 1239, 'Шла Саша'),
    (12, 2023, 'november', 23, 127, 1700748055, 'android', 1239, 'Шла Саша по'),
    (13, 2023, 'november', 23, 127, 1700748175, 'android', 1239, 'Шла Саша по шоссе'),
    (14, 2023, 'november', 23, 127, 1700748415, 'android', 1239, 'Шла Саша по шоссе и'),
    (15, 2023, 'november', 23, 127, 1700748419, 'android', 1239, 'Шла Саша по шоссе и кушала'),
    (16, 2023, 'november', 23, 127, 1700748539, 'android', 1239, 'Шла Саша по шоссе и кушала вкусный'),
    (17, 2023, 'november', 23, 127, 1700748599, 'android', 1239, 'Шла Саша по шоссе и кушала вкусный пряник'),
    (18, 2023, 'november', 29, 128, 1701274199, 'IOS', 1240, 'Как'),
    (19, 2023, 'november', 29, 128, 1701274799, 'IOS', 1240, 'Как выйти'),
    (20, 2023, 'november', 29, 128, 1701275399, 'IOS', 1240, 'Как выйти из дома');
    
SELECT year, month, day, userid, ts, devicetype, deviceid, query, next_query, is_final
From
(SELECT year, month, day, userid, ts, devicetype, deviceid, query,
lead(query, 1) over (partition by userid order by ts) AS next_query,
(CASE WHEN lead(query, 1, '0') over (partition by userid, devicetype order by ts) = '0'
 THEN 1 WHEN lead(ts, 1) over (partition by userid, devicetype order by ts) - ts > 180
 THEN 1 WHEN lead(ts, 1) over (partition by userid, devicetype order by ts)- ts > 60
 and LENGTH(query) > LENGTH(lead(query, 1) over (partition by userid, devicetype order by ts))
 THEN 2 ELSE 0 END) AS is_final
from query
WHERE year = 2023 and month = 'october' and day = 12 and devicetype = 'android')
WHERE is_final = 1 or is_final = 2