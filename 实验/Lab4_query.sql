-- 1.增加一张库存表 Inventory，包括：商品编号、价格、库存数量、入库时间（默认值为系统时间）。主码为商品编号和入库时间.
if exists (select * from sysobjects where name='Inventory') 
	drop table Inventory
create table Inventory(
    Goo_no char(8) not null,
    Inventory_prices money not null,
    Inventory_num int not null,
    Inventory_time date not null
)
if not exists (SELECT * FROM sysobjects WHERE name='PK_Inventory') 
    ALTER TABLE Inventory add constraint PK_Inventory primary key(Goo_no,Inventory_time) 
if not exists (select * from sysobjects where name='DF_Inventory_Inventory_time') 
	alter table Inventory add constraint DF_Inventory_Inventory_time default(getdate()) for Inventory_time

-- 2.从 Purchase (进货表)和 Sell(销售表)中备份空记录表: PurchaseBak 和 SellBak 。
if exists (select * from sysobjects where name='PurchaseBak') 
	drop table PurchaseBak
select * into PurchaseBak from Purchase
if exists (select * from sysobjects where name='SellBak') 
	drop table SellBak
select * into SellBak from Sell

-- 3.创建一个触发器。向销售表中插入一条记录时，这个触发器将更新库存表。
--库存量为原有库存量减去销售数量。如果库存数量少于是10，则显示”该商品库存数量少于10，请及时进货”, 
--并将对应的商品编码、商品名、库存数量存放到预警表中。；如果库存不足,则显示：“'库存不足'”。
--给出测试数据：
if exists (select * from sysobjects where name='Trigger_Sell_insert')  
	drop trigger Trigger_Sell_insert
go
create trigger Trigger_Sell_insert 
on Sell for insert 
as
	declare @Goo_no char(8) 
	declare @Sell_num int 
	declare @Inventory_num int
	set @Goo_no=(select i.Goo_no from inserted i)
	set @Sell_num=(select i.Sell_num from inserted i)
	set @Inventory_num=(select sum(Inventory_num) from Inventory where Goo_no=@Goo_no group by Goo_no) 
	if  @Sell_num>@Inventory_num begin
		print('库存不足')
		rollback
	end 
	if @Sell_num+10>@Inventory_num
		print('请及时进货')
	update Inventory set Inventory_num=@Inventory_num-@Sell_num where Goo_no=@Goo_no
go
--测试触发器
insert into Inventory values('JY0001',6000,45,'2019/11/17')
--insert into Sell values('A1001','2019/11/18',6200,50,'JY0001','1301')
insert into Sell values('A1001','2019/11/18',6200,40,'JY0001','1301')
--select * from Inventory
--恢复数据
if exists (select * from sysobjects where name='Sell') 
	drop table Sell
select * into Sell from SellBak

-- 4.创建一个触发器。向进货表中插入一条记录时，这个触发器都将更新库存表。
--如果库存有该类商品时，那么该商品的进价即为两次进价的平均值（因为每次的进价可能会不相同），
--库存量为原有库存加该次进货数量；（算法为：（库存商品进价*库存量+进货价*进货量）/（库存量+进货量）；
--如果没有该商品，则插入到库存表中。 
if exists (select * from sysobjects where name='Trigger_Purchase_insert')  
	drop trigger Trigger_Purchase_insert
go
create trigger Trigger_Purchase_insert 
on Purchase for insert 
as
	declare @Goo_no char(8) 
	declare @Purchase_num int 
	declare @Purchase_price int 
	declare @Inventory_num int
	set @Goo_no=(select i.Goo_no from inserted i)
	set @Purchase_num=(select i.Pur_num from inserted i)
	set @Purchase_price=(select i.Pur_price from inserted i)
	set @Inventory_num=(select sum(Inventory_num) from Inventory where Goo_no=@Goo_no group by Goo_no) 
	if exists (select * from Inventory where Goo_no=@Goo_no) 	begin 
		print('exists')
		update Inventory 
		set Inventory_prices=(Inventory_prices*Inventory_num+@Purchase_price*@Purchase_num)/(Inventory_num+@Purchase_num),Inventory_num=@Inventory_num+@Purchase_num
		where Goo_no=@Goo_no
	end else begin
		print('not exists')
		insert Inventory 
		select inserted.Goo_no,inserted.Pur_price,inserted.Pur_num,inserted.Pur_date
		from inserted	
	end
go
--测试
select * from Inventory
insert into Purchase values(120,'2019/11/8',1000,	20,	'JY0996','1001') 
select * from Inventory
insert into Purchase values(121,'2019/11/8',2000,	20,	'JY0996','1001') 
select * from Inventory
--delete from PurchaseBak where Pur_no=120 OR Pur_no=121
--恢复备份
if exists (select * from sysobjects where name='Purchase') 
	drop table Purchase
select * into Purchase from PurchaseBak

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

-- 6.创建一个带有输入和输出参数的存储过程 proc_GNO，查询指定厂商指定名称的商品所对应的商品编号。给出测试数据：
if exists (select * from sysobjects where name='proc_GNO') 
	drop procedure proc_GNO
go
create procedure proc_GNO
@Goo_no		char(8) output,
@Goo_name	nvarchar(40),
@Pro_name	nvarchar(20)
as	
	select @Goo_no	='NULL'
	select @Goo_no=Goo_no from Goods 
	where @Goo_name=Goo_name and @Pro_name=Pro_name
go
declare @Goo_no char(8)
exec proc_GNO  @Goo_no output,'iPhone 6S','苹果公司'
select @Goo_no as '商品编号'

-- 7.创建带有参数和返回值的存储过程：在Sales数据库中创建存储过程ProcSumByPurchase。
--查询指定厂商('联想公司')指定名称(拯救者15.6英寸轻薄游戏本)商品在2020年1月的总销售量。 
if exists (select * from sysobjects where name='ProcSumByPurchase') 
	drop procedure ProcSumByPurchase
go
create procedure ProcSumByPurchase
@Goo_name	nvarchar(40),
@Pro_name	nvarchar(20),
@Sell_num	int output
as	
	declare @Goo_no char(8)
	exec proc_GNO  @Goo_no output,@Goo_name,@Pro_name
	set @sell_num=(
		select sumnum
		from (
			select Goo_no, sum(Sell_num) as sumnum
			from Sell
			where YEAR(Sell_date)=2020 and MONTH(Sell_date)=1 and @Goo_no=Goo_no
			group by Goo_no
		)t
	)
go
declare @cnt char(8)
exec ProcSumByPurchase  '拯救者15.6英寸轻薄游戏本','联想公司',@cnt output
select @cnt as '总销售量'

-- 8.在 Sales 数据库创建名为 Purchase_Total 的自定义函数，用于统计某一时间段内的进货情况。
--测试：SELECT * FROM Purchase_Total('2020-1-1','2020-3-1')从返回结果可以看到 1，2 月份的记录。
if exists (select * from sysobjects where name='Purchase_Total') 
	drop FUNCTION Purchase_Total
go
create FUNCTION Purchase_Total(
	@datestart date,
	@dateend date
)
RETURNS    @t table (
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

-- 9.创建一个带有二个输入参数的存储过程 proc_page, 实现显示进货表中第 N 条到第 M 条记录。
--测试：exec proc_page(5,9) --表示显示记录从5~9条。 
if exists (select * from sysobjects where name='proc_page') 
	drop procedure proc_page
go
create procedure proc_page
	@head	int,
	@tail	int
as	
	select top (@tail-@head+1) * from Purchase where Pur_no not IN(select top (@head-1) Pur_no from Purchase)
go
select  * from Purchase
exec proc_page 5,9

-- 10.根据业务需求自拟存储过程和触发器一题。
--创建触发器，在Sell表插入的时候，如果插入数据的销售数量小于0，插入不成功。
if exists (select * from sysobjects where name='Lab4_Trigger') 
	drop procedure Lab4_Trigger
go
create trigger Lab4_Trigger
on Sell for insert 
as
	declare @num int
	set @num=(select inserted.Sell_num from inserted)
	if @num<0
	begin
		print('ERROR: Sell_num <0')	
		rollback
	end
go
insert into Sell values('A1001',	'2019/11/18',6000,	-10	,'JY0001'	,'1301')
