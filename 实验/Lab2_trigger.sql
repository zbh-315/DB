--��������������Sell������ʱ������������ݵ���������С��0�����벻�ɹ���
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

