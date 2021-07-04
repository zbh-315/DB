--创建触发器，在Sell表插入的时候，如果插入数据的销售数量小于0，插入不成功。
alter trigger Lab2_Trigger
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

