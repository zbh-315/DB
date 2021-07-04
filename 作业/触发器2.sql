alter trigger Tri_updateBorrow
on dbo.Borrow for update
as
	print('run is success!') 
	update dbo.Borrow set Due_time = dateadd (month,(case when len(Read_no)<6 then 3 else 1 end)*(case when  Renew_status = 1 then 2 else 1 end ),Borr_time)		
	declare @Rno char(10)
	declare @Bno char(10)
	declare @Dtime datetime
	declare @Ntime datetime
	set @Rno=(select i.Read_no from inserted i)
	set @Bno=(select i.Book_no from inserted i)
	set @Dtime =(select b.Due_time from dbo.Borrow b where @Bno=b.Book_no)
	if DATEDIFF(day,@Dtime,GETDATE()) >0
		begin
			--罚款表
			--0.5*DATEDIFF(day,@Dtime,GETDATE()) 
			if not exists(select * from sysobjects where name='罚款表')
				begin 
					create table 罚款表 (
						Read_no varchar(15) not null,
						TheMoney int not null
					)
				end
			if exists(select * from 罚款表 f where f.Read_no=@Rno )
				begin
					update  罚款表 set TheMoney=TheMoney+0.5*DATEDIFF(day,@Dtime,GETDATE()) where Read_no=@Rno 
				end
			else 
				begin
					insert into 罚款表 values(@Rno,0.5*DATEDIFF(day,@Dtime,GETDATE()))
				end
			print('runIF is success!') 
		end
go
--drop table dbo.Borrow 
--select * into dbo.Borrow 
--from Borrow_bak
update dbo.Borrow set Borr_time ='2021-03-14' where Book_no='B1300945'
update dbo.Borrow set Borr_time ='2020-03-14' where Book_no='B1481537'
update dbo.Borrow set Return_time =GETDATE() where Book_no='B1300945'
update dbo.Borrow set Return_time =GETDATE() where Book_no='B1481537'
select *
from 罚款表
drop table 罚款表
