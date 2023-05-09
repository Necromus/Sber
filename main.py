import pypyodbc

SERVER_NAME = 'DESKTOP-DQ90HMP\SQLEXPRESS'
DATABASE_NAME = 'Work'

connection_string = f"""
    DRIVER={{SQL Server}};
    SERVER={SERVER_NAME};
    DATABASE={DATABASE_NAME};
    Trusted_Connection=yes;
"""

#Курсор
connection_to_db = pypyodbc.connect(connection_string)

cursor = connection_to_db.cursor()

#Задание:необходимо найти 3-х самых молодых сотрудников в коллективе и выдать их имена,
#предварительно отсортировав. Задачу требуется решить несколькими способами (чем больше, тем
#лучше).
#Реализация SQL запроса
print('Задание 1:')
print('1 вариант')
cursor.execute('select top (3) name from test order by age asc  ')
data = cursor.fetchall()
print(data)
connection_to_db.commit()

print('2 вариант')
cursor.execute('select name from test order by age offset 0 rows fetch next 3 rows only')
data = cursor.fetchall()

print(data)
connection_to_db.commit()

print('3 вариант')
cursor.execute('select name from test where age in ( select top 3 age from test order by age) order by age')
data = cursor.fetchall()

print(data)
connection_to_db.commit()

print('4 вариант')
cursor.execute('select t.name from test t join ( select top 3 id from test order by age ) tt on t.id = tt.id order by age')
data = cursor.fetchall()

print(data)
connection_to_db.commit()

print('\n')

#Задание:нужно для каждого дня определить последнее местоположение абонента.
#Реализация SQL запроса
print('Задание 2:')
cursor.execute('select i.abonent, region_id, i.dttm from  (select abonent, max(dttm) as dttm from test2 group by  abonent, convert(date, dttm)) as i join test2 as b on i.dttm = b.dttm')
data = cursor.fetchall()

for i in range(0, len(data)):
    print(data[i])
connection_to_db.commit()

print('\n')

#Задание:рассчитать количество публикаций в месяц с указанием первой даты месяца и долей
#увеличения количества сообщений (публикаций) относительно предыдущего месяца.
#Реализация SQL запроса
print('Задание 5')
cursor.execute("select concat(Year(Created_at),'-',Month(Created_at),'-01') as dt, count(title) as count, concat(round((cast(count(title) as float(1))/lag(count(title)) over(order by Month(created_at)) - 1) * 100, 1),'','%') prev_growth  from post group by Year(Created_at),Month(created_at)")
data = cursor.fetchall()

for i in range(0, len(data)):
    print(data[i])
connection_to_db.commit()

