--alter table 借阅$ add 到期日期 date
update 借阅$ set 到期日期=
	dateadd(month,(case when len(借书证号)=5 then 3 else 1 end )*(case when 续借 = '1' then 2 else 1 end ),借书日期)
if exists (select * from sysobjects where name='pro_3') 
	drop procedure pro_3
go
create procedure pro_3
@leng int
as	
	update 借阅$ set 到期日期=dateadd(month,@leng,借书日期)
go 
--exec pro_3,1
update 借阅$ set 到期日期=dateadd(month,1,借书日期)

