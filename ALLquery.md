~~顺序结构有点凌乱，敬请见谅~~ 
@[TOC]( )
# 元组的增删改查
## 增 -> INSERT
### ①声明列
其他未声明的列取默认值

```sql
insert into '表'（'列名1'，'列名2'...） values ('数据1','数据2'...)
insert into region(RegionID,RegionDescription) values(5,'Center')
```

### ②不声明列
按照属性（列）的顺序填写数据。

```sql
insert into '表' values ('数据1','数据2'...) --这里得包含所有的列的数据
insert into Sell values('A1001','2019/11/18',6000,-10,'JY0001','1301')
```

## 删 -> delete

```sql
delete from '表' where '条件' 
delete from customers where City='London'
```

## 改 -> update

```sql
update ‘表’ set ‘修改’ where ‘条件’
update orders set Freight=Freight*0.95 where EmployeeID=3 or EmployeeID=4
```

## 查 -> select 
### ①查询所有

```sql
select * from '表'
select * from orders
```

### ②分组
group by

```sql
select  CustomerID,avg(Freight) as avgFreight 
from orders
group by CustomerID
```

### ③排序
order by
默认排序从小到大，desc从大到小
```sql
select productid
from orderdetails
order by quantity
```

### ④限定查询
top x 前x条记录
```sql
select top 10 b.Read_no,count(*)
from dbo.Borrow b
group by b.Read_no
```
top x percent 前x%条记录
```sql
select top 20 percent * from table
```

### ⑤条件
where是对当前表的条件控制
having是对新的列的条件控制

```sql
--5.找出当前至少借阅了2本图书的读者借书证号、姓名及所在单位。
select  a.Read_no as 借书证号 ,b.Read_name as 姓名,  b.Read_dept as 单位
from dbo.Borrow a ,dbo.Reader b
where a.Read_no=b.Read_no 
group by a.Read_no,b.Read_name,b.Read_dept 
having count(*) >=2
```


# 表的操作
## 建表

```sql
create table Inventory(
    Goo_no char(8) not null,
    price money not null,
    num int not null,
    In_time date not null
)
```
## 修改表的结构
### 增加字段

```sql
alter table 表名 add 新增字段名 字段类型 默认值…
alter table [stu] add [jj] int default 0
```

### 删除字段
```sql
ALTER TABLE 表名 DROP COLUMN 字段名;
alter table [stu] drop column [jj]
```

### 修改字段类型

```sql
alter table 表名 alter column 字段名 type
alter table [stu] alter column [jj] VARCHAR(200)
```

### 修改字段名
```sql
exec sp_rename ‘表名.原字段名’,‘新字段名’
exec sp_rename 'stu.jj','gg'
```

## 备份表
先确保没有这个表


```sql
if exists (select * from sysobjects where name='PurchaseBak') 
	drop table PurchaseBak
```



### 表不存在
```sql

select * into PurchaseBak from Purchase

```

### 表存在
先建立表的结构，再插入
```sql
select * into PurchaseBak from Purchase where 1=2
insert into PurchaseBak select * from Purchase
select * from PurchaseBak
```
## 删除表
drop table 表名 


# 功能
## 触发器
以插入数据为例
```sql
create trigger Tri_InsterBorrow 
on dbo.Borrow for insert 
as
	print('run is success!') 
	declare @Rno char(10)
	declare @Bno char(10)
	set @Rno=(select i.Read_no from inserted i)
	set @Bno=(select i.Book_no from inserted i)
	if (select r.Card_status 	from dbo.Reader r 	where r.Read_no=@Rno ) like '挂失'
		begin 
			print('卡丢失，借书失败')
			rollback --回滚
		end 
	else if (select b.B_status 	from dbo.Book b 	where b.Book_no=@Bno ) like '已借'
		begin 
			print('书已经被借，借书失败')
			rollback
		end 
	else
		begin 
			print('借书成功')
			update dbo.Book  set B_status = '已借'	where Book_no=@Bno
		end 
go
```
## 存储过程
有output的是输出参数，没有output的是输入参数
```sql
-- 5.创建一个带有输入参数的存储过程 proc_Purchase1，查询指定员工所进商品信息。如果员工不存在，返回值为 1。给出测试数据。
if exists (select * from sysobjects where name='proc_Purchase1') 
	drop procedure proc_Purchase1
go
create procedure proc_Purchase1
@Emp_no varchar(10),
@ret int output
as	
	if not exists(select * from Purchase where Purchase.Emp_no=@Emp_no)
		set @ret=1
	else begin
		select * from Purchase where Purchase.Emp_no=@Emp_no
	end		
go
declare @t int 
exec proc_Purchase1  '1001',@t output
if @t=1
	print('1001 not exists')
exec proc_Purchase1  '2001',@t output
if @t=1
	print('2001 not exists')
```
## 视图

```sql
-- 10、创建视图v1，要求查询'佳能公司'，2019年12月份商品的销售情况和每一笔销售的纯利润，并对视图v1加密：
if exists (select * from sysobjects where name='V1') 
    drop view V1
go
create view V1 with encryption
as
select Sell_no as 销售编号,
    Sell.Goo_no as 商品编码,
    Goo_name as 商品名称,
    Pur_price as 进货价,
    Sell_prices as 销售价,
    Sell_num as 销售数量,
(Sell_prices - Pur_price) * Sell_num as 销售纯利润
from (
        Sell
        inner join Purchase 
		on Sell.Goo_no = Purchase.Goo_no
    )
    inner join Goods 
	on Goods.Goo_no = Sell.Goo_no
where YEAR(Sell.Sell_date)=2019 and MONTH(Sell.Sell_date)=12 
    and Goods.Goo_no in (
        select Goods.Goo_no
        from Goods --           
        where Goods.Pro_name = '佳能公司'
    )
 go
select * from V1 --查看视图
```
## 函数
### 返回一个动态表

```sql
-- 8.在 Sales 数据库创建名为 Purchase_Total 的自定义函数，用于统计某一时间段内的进货情况。
--测试：SELECT * FROM Purchase_Total('2020-1-1','2020-3-1')从返回结果可以看到 1，2 月份的记录。
if exists (select * from sysobjects where name='Purchase_Total') 
	drop FUNCTION Purchase_Total
go
create FUNCTION Purchase_Total(
	@datestart date,
	@dateend date
)
RETURNS @t table (
	Pur_no    int,
	Pur_date  date ,
	Pur_price money ,
	Pur_num   int ,
	Goo_no    char(8) ,
	Emp_no    char(4) 
)
AS
BEGIN
	insert @t
	select * from Purchase where Purchase.Pur_date>=@datestart AND Purchase.Pur_date<@dateend	
	return
END
go
SELECT * FROM Purchase_Total('2020-1-1','2020-3-1')
```
### 返回标量函数

```sql
CREATE FUNCTION dbo.Foo()
RETURNS int
AS 
BEGIN
    declare @n int
    select @n=3
    return @n
END
```



# 键与约束
## 主键
```sql
if not exists (SELECT * FROM sysobjects WHERE name='PK_Purchase' and xtype='PK') 
    ALTER TABLE Purchase add constraint PK_Purchase primary key(Pur_no) 
```

## 外键

```sql
if not exists (SELECT * FROM sysobjects WHERE name='FK_Purchase1' and xtype='F') 
	ALTER TABLE Purchase add constraint FK_Purchase1 foreign key(Goo_no) references Goods(Goo_no)

if not exists (SELECT * FROM sysobjects WHERE name='FK_Purchase2' and xtype='F') 
	ALTER TABLE Purchase add constraint FK_Purchase2 foreign key(Emp_no) references Employees(Emp_no)

```

## 检查性约束

```sql
if not exists(select * from sysobjects where name='check_Sell')
begin
    alter table Sell
    with check --该约束是否应用于现有数据，with check表示应用于现有数据，with nocheck表示不应用于现有数据
    add constraint check_Sell
    check 
    not for replication --当复制代理在表中插入或更新数据时，禁用该约束。
    (Sell_no like '[A-Z,a-z]%');
end
```

## 唯一约束

```sql
if not exists(select * from sysobjects where name='IX_EmployeesTeNo' and xtype='UQ')
	alter table Employees add constraint IX_EmployeesTeNo unique (Empp_phone) 
```
## 默认约束

```sql
if not exists (select * from sysobjects where name='DF_Sell_date' and xtype='D') 
	alter table Sell add constraint DF_Sell_date default(getdate()) for Sell_date
```

# 基础操作
## 基本函数
最基本的一些函数，如avg，sum,min,max,count。

```sql
select  CustomerID,avg(Freight) as avgFreight 
from orders
group by CustomerID
```
## 查询是否存在表或键
在 sysobjects  中查询
```sql
if exists (select * from sysobjects where name='Purchase_bak') 
```


## 定义变量和使用
定义用declare, @变量名 即使用， set 可以修改变量的值
```sql
declare @num int
set @num=(select inserted.Sell_num from inserted)
```

## 条件分支
case when '条件' then '条件真的时候的值' else '条件为假的时候的值' end

```sql
--12.统计每位读者借阅数据结构、C++程序设计、SQL编程和Java Web 应用开发四本书借阅情况。
select  a.Read_no as 卡号 , 
	sum (case when c.Bname='数据结构' then 1 else 0 end )as 'C++程序设计' ,
	sum (case when c.Bname='C++程序设计' then 1 else 0 end )as 'C++程序设计' ,
	sum (case when c.Bname='SQL 编程' then 1 else 0 end )as 'SQL 编程' ,
	sum (case when c.Bname='Java Web 应用开发' then 1 else 0 end )as 'Java Web 应用开发'
from dbo.Borrow a ,dbo.Catalog c,dbo.Book b
where b.Book_no=a.Book_no and b.ISBN=c.ISBN
group by a.Read_no 
```

## 时间操作
### 简单的时间函数
year,month,day返回值为int行，分别返回哪年，哪月，哪日

```sql
select Sell.Emp_no,sum(Sell_num *Sell_prices) as sum_sale
from Sell
where YEAR(Sell.Sell_date)=2019 and MONTH(Sell.Sell_date)=12
group by Sell.Emp_no
```
### 简单的时间比较
直接用符号进行比较
```sql
select Employees.Emp_no as 员工号,sum(Sell.Sell_num*Sell.Sell_prices) as 销售总金额
from Employees,Sell
where Sell.Emp_no=Employees.Emp_no and Sell.Sell_date>=('2019-9-1') and Sell.Sell_date<('2020-1-1')
group by Employees.Emp_no
order by sum(Sell.Sell_num*Sell.Sell_prices) desc
```





