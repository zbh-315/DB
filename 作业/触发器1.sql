create trigger Tri_InsterBorrow 
on dbo.Borrow for insert 
as
	--select *
	--from inserted i
	print('run is success!') 
	declare @Rno char(10)
	declare @Bno char(10)
	set @Rno=(select i.Read_no from inserted i)
	set @Bno=(select i.Book_no from inserted i)
	if (select r.Card_status 	from dbo.Reader r 	where r.Read_no=@Rno ) like '挂失'
		begin 
			print('卡丢失，借书失败')
			rollback
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
--drop table dbo.Book
--drop table dbo.Borrow 
--select * into dbo.Book
--from dbo.Book_bak
--select * into dbo.Borrow 
--from Borrow_bak

insert into dbo.Borrow values ('2016811002','B1547939','2020-03-14 00:00:00.000','2020-12-14 00:00:00.000',NULL,1  ) 
insert into dbo.Borrow values ('81099','B1300945','2020-03-14 00:00:00.000','2020-12-14 00:00:00.000',NULL,1  ) 
insert into dbo.Borrow values ('81099','B1547939','2020-03-14 00:00:00.000','2020-12-14 00:00:00.000',NULL,1  ) 
delete from dbo.Borrow where Read_no='81099'


