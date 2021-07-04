if exists (select * from sysobjects where name='Tri_Inster_借阅$') 
	drop  trigger Tri_Inster_借阅$
go
create trigger Tri_Inster_借阅$
on 借阅$ for insert 
as
	print('run  Tri_Inster_借阅$ is success!') 
	declare @借书证号 char(100),@总编号 char(100)
	set @借书证号=(select i.借书证号 from inserted i)
	set @总编号=(select i.总编号 from inserted i)
	if (select count(*) from 借阅$ where 借书证号=@借书证号 group by 借书证号)>=3
		begin 
			print('借书不能超过三本')
			rollback --回滚
		end 
	else
		print('借阅成功')
go
insert into 借阅$ values('81018','99999',getdate(),1);


delete from 借阅$ where 借书证号='1'
insert into 借阅$ values('1','1',getdate(),1);

