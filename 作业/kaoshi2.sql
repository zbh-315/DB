if exists (select * from sysobjects where name='Tri_Inster_����$') 
	drop  trigger Tri_Inster_����$
go
create trigger Tri_Inster_����$
on ����$ for insert 
as
	print('run  Tri_Inster_����$ is success!') 
	declare @����֤�� char(100),@�ܱ�� char(100)
	set @����֤��=(select i.����֤�� from inserted i)
	set @�ܱ��=(select i.�ܱ�� from inserted i)
	if (select count(*) from ����$ where ����֤��=@����֤�� group by ����֤��)>=3
		begin 
			print('���鲻�ܳ�������')
			rollback --�ع�
		end 
	else
		print('���ĳɹ�')
go
insert into ����$ values('81018','99999',getdate(),1);


delete from ����$ where ����֤��='1'
insert into ����$ values('1','1',getdate(),1);

