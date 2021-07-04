--1.查找读者借阅情况，包括没有借书的读者信息, 显示借书证号、姓名、图书编号。
select b.Read_no as  借书证号 ,b.Read_name as 姓名,a.Book_no as  图书编号
from  dbo.Reader b
left join dbo.Borrow a
on a.Read_no=b.Read_no;


--2.查找没有借过书的读者, 显示借书证号、姓名、单位
select a.Read_no as 借书证号 ,a.Read_name as 姓名,a.Read_dept as 单位
from dbo.Reader a
where a.Read_no not in (
	select b.Read_no
	from dbo.Borrow b
)


--3.统计每个单位当前借阅图书的人数。
select b.Read_dept as 单位, count ( *) as 借阅人数
from dbo.Borrow a , dbo.Reader b
where a.Read_no=b.Read_no
group by b.Read_dept


--4.统计各学院学生借阅图书的人数(注意：职工的借书证号4位数字，学生借书证号10位数字 ）
select b.Read_dept as 单位,COUNT(*)as 借阅人数
from dbo.Reader b ,(select a.Read_no 
	from dbo.Borrow a 
	where len(a.Read_no)>6
	group by a.Read_no )t
where b.Read_no=t.Read_no
group by  b.Read_dept 


--5.找出当前至少借阅了2本图书的读者借书证号、姓名及所在单位。
select  a.Read_no as 借书证号 ,b.Read_name as 姓名,  b.Read_dept as 单位
from dbo.Borrow a ,dbo.Reader b
where a.Read_no=b.Read_no 
group by a.Read_no,b.Read_name,b.Read_dept 
having count(*) >=2

----6.修改到期时间字段，要求：教职工的借期3个月，学生的借期1个月
---- 果续借状态为续借，则教职工的借期6个月，学生的借期2个月（给出多种方法）
update dbo.Borrow
set Due_time = dateadd (month,(case when len(Read_no)<6 then 3 else 1 end)*(case when  Renew_status = 1 then 2 else 1 end ),Borr_time)



--7.检索同时借阅了图书编号B1481539和B1547940两本书的借书证号（给出2 种方法）
select a.Read_no
from dbo.Borrow a ,dbo.Borrow b
where a.Read_no=b.Read_no and a.Book_no='B1481539' and b.Book_no='B1547940'

--8. 找出已到期的书名、图书编号、读者姓名、单位
select a.Book_no as 书名,a.Book_no as 图书编号,b.Read_name as 读者姓名 ,b.Read_dept as 单位
from  dbo.Borrow a ,dbo.Reader b
where (CONVERT(varchar, a.Due_time) >= CONVERT(varchar, GETDATE()))
	and a.Read_no=b.Read_no;

--9.对已到期的书没还的，生成一张罚款表，超期一天罚款0.5元。罚款表中的内容包含：借书证号，图书编号,借阅时间,罚款总金额
select a.Read_no as 借书证号, a.Book_no as 图书编号,a.Borr_time as 借阅时间,
0.5*DATEDIFF(day,a.Due_time,GETDATE()) as 罚款总金额
from dbo.Borrow a 


--10.  查找2020年借阅书最多的前2名书号、姓名、借阅数量
select top 2 a.Read_no as 书号,a.Read_name as 读者姓名, t.size as 借阅数量
from dbo.Reader a,(
	select top 10 b.Read_no,count(*) as size
	from dbo.Borrow b
	group by b.Read_no
) t
where a.Read_no =t.Read_no
order by size  desc,a.Read_no


--11.查找比‘清华大学出版社‘出版的最高价格还高的书的基本信息
select *
from dbo.Catalog a
where a.Price>all(
	select b.Price
	from dbo.Catalog b
	where b.Press='清华大学出版社'
)



--12.统计每位读者借阅数据结构、C++程序设计、SQL编程和Java Web 应用开发四本书借阅情况。
select  a.Read_no as 卡号 , sum (case when c.Bname='数据结构' then 1 else 0 end )as 'C++程序设计' ,
							sum (case when c.Bname='C++程序设计' then 1 else 0 end )as 'C++程序设计' ,
							sum (case when c.Bname='SQL 编程' then 1 else 0 end )as 'SQL 编程' ,
							sum (case when c.Bname='Java Web 应用开发' then 1 else 0 end )as 'Java Web 应用开发'
from dbo.Borrow a ,dbo.Catalog c,dbo.Book b
where b.Book_no=a.Book_no and b.ISBN=c.ISBN
group by a.Read_no 
