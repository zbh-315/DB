--alter table ����$ add �������� date
update ����$ set ��������=
	dateadd(month,(case when len(����֤��)=5 then 3 else 1 end )*(case when ���� = '1' then 2 else 1 end ),��������)
if exists (select * from sysobjects where name='pro_3') 
	drop procedure pro_3
go
create procedure pro_3
@leng int
as	
	update ����$ set ��������=dateadd(month,@leng,��������)
go 
--exec pro_3,1
update ����$ set ��������=dateadd(month,1,��������)

