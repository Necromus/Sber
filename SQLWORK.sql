--1 ЗАДАНИЕ
create table test (
id int, 
name varchar(10), 
age int)

insert into test values (1, 'Вася', 23)
insert into test values (2, 'Петя', 40)
insert into test values (3, 'Маша', 19)
insert into test values (4, 'Марина', 23)
insert into test values (5, 'Сергей', 34)

--1 Вариант
select top (3) name 
from test 
order by age asc  

--2 Вариант
select name
from test
order by age offset 0 rows fetch next 3 rows only

--3 Вариант
select name
from test
where age in (
  select top 3 age
  from test
  order by age
)
order by age

--4 Вариант
select t1.name
from test t1
join (
  select top 3 id
  from test
  order by age
) t2 on t1.id = t2.id order by age

--2 ЗАДАНИЕ
create table test2(
abonent bigint,
region_id int,
dttm datetime)


insert into test2 values 
(7072110988, 32722, '20210818 13:15:00'),
(7072110988, 32722,'20210818 14:00'), 
(7072110988,21534, '20210818 14:15'), 
(7072110988, 32722, '20210819 09:00'),
(7071107101, 12533, '20210819 09:15'), 
(7071107101, 32722, '20210819 09:27')

select i.abonent,
       region_id,
       i.dttm
from 
	(select abonent,
		 max(dttm) AS dttm
	from test2
	group by  abonent, convert(date, dttm)) as i
join test2 as b
	on i.dttm = b.dttm

--3 ЗАДАНИЕ
create table item_prices(
item_id int,
item_name nvarchar(150),
item_price float,
created_dttm datetime default GETDATE())

insert into item_prices values (1,'курочка', 120.22, '20230501 09:27')
insert into item_prices values (2,'манго', 13.22, '20230502 09:27')
insert into item_prices values (3,'яблоко', 10.22, '20230503 09:27')
insert into item_prices values (4,'киви', 132.22, '20230504 09:27')
insert into item_prices values (5,'помидоры', 23.22, '20230505 09:27')
insert into item_prices values (6,'колбаски', 333.22, '20230506 09:27')
insert into item_prices values (7,'сосиски', 533.22, '20230206 09:27')
insert into item_prices values (8,'морковь', 20.31, '20230209 09:27')


create table dict_item_prices(
item_id int,
item_name nvarchar(150),
item_price float,
valid_from_dt date,
valid_to_dt date)

create trigger item_prices_insert 
on item_prices after update 
as 
begin

declare @item_id int
select @item_id = item_id from deleted
declare @item_name nvarchar(150)
select @item_name = item_name from deleted
declare @item_price float
select @item_price = item_price from deleted
declare @created_dttm datetime
select @created_dttm = created_dttm from deleted

insert into dict_item_prices values (@item_id,@item_name, @item_price, cast(@created_dttm as date), Dateadd(Day, - 1, GETDATE()))

end


update item_prices set item_price = 122.22, created_dttm = GETDATE() where item_id = 3
update item_prices set item_price = 12.42, created_dttm = GETDATE() where item_id = 5

--4 ЗАДАНИЕ
create table transaction_details(
transaction_id int,
customer_id int,
item_id int,
item_number int,
transaction_dttm datetime)

insert into transaction_details values (1,1,1,10, getdate())
insert into transaction_details values (2,1,2,5, getdate())
insert into transaction_details values (3,1,5,7, '20230506 09:27')
insert into transaction_details values (4,1,7,2, '20230210 09:27')
insert into transaction_details values (5,2,6,2, '20230211 09:27')
insert into transaction_details values (6,2,6,12, getdate())

create table customer_aggr(
customer_id int,
amount_spent_1m float,
top_item_1m nvarchar(150))

CREATE PROCEDURE CustomerAggrProcedure AS

BEGIN

DECLARE @table1 TABLE(customer_id int, transaction_dttm datetime, item_name nVARCHAR(150), item_price float, sum_item_price float)

INSERT INTO @table1  (customer_id, transaction_dttm, item_name, item_price, sum_item_price) select transaction_details.customer_id, transaction_details.transaction_dttm, dip.item_name, dip.item_price, dip.item_price * transaction_details.item_number as sum_item_price from dict_item_prices as dip join transaction_details on dip.item_id = transaction_details.item_id where transaction_details.transaction_dttm between dip.valid_from_dt and dip.valid_to_dt union 
select transaction_details.customer_id, transaction_details.transaction_dttm, itp.item_name, itp.item_price, itp.item_price * transaction_details.item_number as sum_item_price from item_prices as itp join transaction_details on itp.item_id = transaction_details.item_id where (transaction_details.transaction_dttm between created_dttm and getdate()) and (transaction_dttm between Dateadd(Day, - 30, GETDATE()) and GETDATE())

insert into customer_aggr (customer_id, amount_spent_1m, top_item_1m) 
select bb.customer_id, bb.sum_all_item, gg.item_name from (select customer_id, SUM(sum_item_price) as sum_all_item from @table1 group by customer_id) as bb
join
(select uyu.customer_id, yuy.item_name from (select ii.customer_id, Max(ii.sum_item_price) as maxsum from @table1 as ii group by ii.customer_id)
as uyu join 
@table1
as yuy on uyu.maxsum = yuy.sum_item_price) as gg on bb.customer_id = gg.customer_id

END

exec CustomerAggrProcedure

--5 ЗАДАНИЕ
create table post(
id int,
created_at datetime,
title nvarchar(150))

create table results(
dt date,
[count] int,
prent_growth float)

insert into post values 
(1,'20220117 08:50:58','hh'), 
(2,'20220119 08:50:58','hh1'), 
(3,'20220121 08:50:58','hh2'), 
(4,'20220217 08:50:58','hh3'),
(5,'20220221 08:50:58','hh4'),
(6,'20220321 08:50:58','hh5'),
(7,'20220322 08:50:58','hh6'),
(8,'20220325 08:50:58','hh7'),
(9,'20220326 08:50:58','hh8')

select concat(Year(Created_at),'-',Month(Created_at),'-01') as dt, count(title) as count, concat(round((cast(count(title) as float(1))/lag(count(title)) over(order by Month(created_at)) - 1) * 100, 1),'','%') prev_growth  
from post 
group by Year(Created_at),Month(created_at)

