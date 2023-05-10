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

create table dict_item_prices(
item_id int,
item_name nvarchar(150),
item_price float,
valid_from_dt date,
valid_to_dt date)

create trigger item_pices_insert
on item_prices after insert
as
begin
declare @item_id int
select @item_id = item_id from inserted
declare @item_name nvarchar(150)
select @item_name = item_name from inserted
declare @item_price float
select @item_price = item_price from inserted
declare @created_dttm datetime
select @created_dttm = created_dttm from inserted

insert into dict_item_prices values (@item_id,@item_name, @item_price, cast(@created_dttm as date), '99991231')

end


create trigger item_pices_update
on item_prices after update
as
begin
declare @item_id int
declare @item_name nvarchar(150)
declare @item_price float
declare @created_dttm datetime

select @item_id = item_id from deleted
update dict_item_prices set valid_to_dt = Dateadd(Day, - 1, GETDATE()) where item_id = @item_id and valid_to_dt = '99991231'

select @item_id = item_id from inserted
select @item_name = item_name from inserted
select @item_price = item_price from inserted
select @created_dttm = created_dttm from inserted

insert into dict_item_prices values (@item_id,@item_name, @item_price, cast(@created_dttm as date), '99991231')

end


--4 ЗАДАНИЕ
create table transaction_details(
transaction_id int,
customer_id int,
item_id int,
item_number int,
transaction_dttm datetime)

create table customer_aggr(
customer_id int,
amount_spent_1m float,
top_item_1m nvarchar(150))

create procedure customer_aggr_procedure
as
begin

insert into customer_aggr (customer_id, amount_spent_1m, top_item_1m) 
select tablesum.customer_id, tablesum.sum_item_price_number, tablemaxname.item_name from (select i.customer_id, SUM(item_price_number) as sum_item_price_number from (select transaction_dttm, customer_id, td.item_id, item_price * item_number as item_price_number from transaction_details as td join dict_item_prices as dip on td.item_id = dip.item_id and td.transaction_dttm between dip.valid_from_dt and dip.valid_to_dt) as i where i.transaction_dttm between Dateadd(Day, - 30, GETDATE()) and GETDATE() group by i.customer_id)
as tablesum join 
(select tablemax.customer_id, tableall.item_name from (select  i.customer_id, MAX(item_price_number) as max_item_price_number from (select transaction_dttm, customer_id, td.item_id, item_price * item_number as item_price_number from transaction_details as td join dict_item_prices as dip on td.item_id = dip.item_id and td.transaction_dttm between dip.valid_from_dt and dip.valid_to_dt) as i where i.transaction_dttm between Dateadd(Day, - 30, GETDATE()) and GETDATE() group by i.customer_id)
as tablemax join 
(select transaction_dttm, customer_id, item_name, td.item_id, item_price * item_number as item_price_number from transaction_details as td join dict_item_prices as dip on td.item_id = dip.item_id and td.transaction_dttm between dip.valid_from_dt and dip.valid_to_dt where transaction_dttm between Dateadd(Day, - 30, GETDATE()) and GETDATE()) 
as tableall on tablemax.max_item_price_number = tableall.item_price_number) as tablemaxname on tablesum.customer_id = tablemaxname.customer_id

end

exec customer_aggr_procedure

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

