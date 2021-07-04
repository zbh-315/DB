--Lab5.query.sql

-- 1. ��ư�ȫ����ʹ���û�����ֻ�ܲ��Ҳ��񲿵�ְ����
--exec	sp_addlogin '����' ,'123456'
--exec  sp_grantdbaccess '����','����'
--exec	sp_droplogin '����'
if exists (select * from sysobjects where name='View_Caiwubu') 
    drop view View_Caiwubu
go
create view View_Caiwubu with encryption
as
	select *
	from Employees
	where Dep_no in (
		select Dep_no
		from Department
		where Dep_name like '����'
	)
go
GRANT SELECT  ON  View_Caiwubu to  ����
select * from View_Caiwubu --�鿴��ͼ
	

-- 2. ��ƽ�ɫ��Role_Emp�����ý�ɫ���Բ鿴��Ա��š���Ա�����������û�������Ϊ��Ա���뵽�ý�ɫ��
--exec sp_addrole 'Role_Emp'
if exists (select * from sysobjects where name='View_Emp_no_name') 
    drop view View_Emp_no_name
go
create view View_Emp_no_name with encryption
as
	select Emp_no,Emp_name
	from Employees
go
grant select on View_Emp_no_name to Role_Emp
exec sp_addrolemember 'Role_Emp' ,'����'
select * from View_Emp_no_name

-- 3. �û�����ӵ������Ȩ������ֻ�ܲ�������е���Ϣ����ӵ�ж����ѽ�������Ϣ�޸ĵ�Ȩ�ޣ����������Ϣ��Ȩ�鿴��������ã���� ��SQL���롣 
--exec sp_addlogin '����','123456'
--exec sp_grantdbaccess '����','����'
if exists (select * from sysobjects where name='view_Purchase_ZhangMing') 
    drop view view_Purchase_ZhangMing
go
create view view_Purchase_ZhangMing
as
	select * from Purchase 
	where Emp_no in(select Emp_no from Employees
               where Emp_name='����')
go
Grant select on Purchase to ����
Grant update on view_Purchase_ZhangMing to ����

-- 4. ���ʹ�òɹ����ŵ�Ա��������������Ȩ�ޣ��ܲ鿴���������Ϣ����ӵ�ж����Ѳɹ���Ϣ���޸ģ���������Ϣ��Ȩ�鿴��
--��Ҫ�󣺱�д�洢���� proc_emp_grant�������ã��������ΪԱ���������ӽ������в��Ҹ�Ա���������Ĳ�Ʒ��
--���û���򷵻أ��еĻ�����Ӧ���� login ��������˺ź����롣���ң�������Ӧ�ĵ�¼�˺ź����ݿ��û���
if exists (select * from sysobjects where name='proc_emp_grant') 
	drop procedure proc_emp_grant
go
create procedure proc_emp_grant
@name varchar(10)
as	
	if exists (select * from Purchase 
		where Emp_no in (
			select Emp_no from Employees
		    where Emp_name=@name)
	)
	begin
		declare @s char(400), @view_name char(20)
		set @view_name='View_'+@name
		
		if exists (select * from sysobjects where name=@view_name) 
		begin
			set @s='drop view '+@view_name
			exec (@s)
		end	 
		set @s= 'create view '+@view_name+'
				as
					select * from Purchase 
					where Emp_no in(select Emp_no from Employees
               			where Emp_name= '''+@name+''' )'
						--print(@s)
		exec (@s)
		--exec sp_addlogin @name,'123456'
		--exec sp_grantdbaccess @name,@name
		set @s='Grant select on Purchase to '+@name
		--exec (@s)
		set @s='Grant update on '+@name+' to '+ @name
		--exec (@s)	
	end
	else 
		print((@name +' not exist'))
go
exec proc_emp_grant 'ttt'
exec proc_emp_grant '����'
-- 5. ����ת������.  д��������������ת�˵Ĵ洢���̣�
if exists (select * from sysobjects where name='Deposits') 
	drop table Deposits
create table Deposits (
	ID char(20) not null,
	name char(10) not null,
	num money not null
)
alter table Deposits with check add constraint check_Deposits check (num>=0)

if exists (select * from sysobjects where name='Procedure_OutDeposits') 
	drop procedure Procedure_OutDeposits
go 
create procedure Procedure_OutDeposits
@ID char(20),
@outnum int
as
	begin try
		begin tran
			update Deposits set num=num-@outnum  where @ID=ID
			print('out success')
		commit tran
	end try
	begin catch
		print('out defeat')
		rollback tran
	end catch
go

insert into Deposits values('001','Wang',500)
exec Procedure_OutDeposits '001',100

-- 6. ���ݿ��ֶεļ��ܺͽ���
--1)�������߱�Ŀձ���Ϊ: ����_bak, ����һ�ֶ�: ���֤��;
if exists (select * from sysobjects where name='Reader_bak') 
	drop table Reader_bak
select * into Reader_bak from Reader where 1=2
alter table Reader_bak add [���֤��]  varbinary(500) not null
--2)�������ݿ�����Կ;
--if exists(SELECT * FROM sys.symmetric_keys)
--	drop master key
--create master key encryption by password='123456'

--3)����֤��һ,��֤��ʹ�����ݿ�����Կ������
go
 
drop certificate Cert_Demo1
create certificate Cert_Demo1  
with
	 subject=N'cert encryption by database master key',
	 start_date='2021-1-1',
	 expiry_date='2021-12-30'
go
--4)�Զ���bak��������һ����¼������֤��Ϊ: 210, ���֤��Ϊ:'350211199611020045'
insert into Reader_bak(Read_no,���֤��) values('210',encryptbycert(cert_id(N'Cert_Demo1'),N'350211199611020045'))

--5)�����ܵ����֤�Ž�����ʾ����
select * from Reader_bak
select convert(nvarchar(500),decryptbycert(cert_id(N'Cert_Demo1'),���֤��))
from Reader_bak
--6)�ܽ�����ݿ��ֶμ��ܺͽ��ܵ���⡣



--  7. ����һ���û���������Ĵ������£�
if exists (select * from sysobjects where name='users') 
	drop table users
 create table users
 (
 	Unumber	int identity(1,1),	--�Զ���ţ���ʶ��
 	Uname		varchar(20),		--�ǳ�
 	sex		char(2),			--�Ա�
 	Upassword	varchar(32),		--����
 	CONSTRAINT PK_Unum	PRIMARY KEY(Unumber),
 	CONSTRAINT CK_sex CHECK(sex='��' or sex='Ů'),
 	CONSTRAINT CK_Upassword CHECK (LEN(Upassword)>=6)
 )
-- Ҫ�󴴽�һ���洢���̣�ʵ�ֲ����û���users������ʱ�����������Ҫ���Զ�ת��Ϊ���ģ���ʾ���� 
-- SQL ���ú���ʵ�� MD5 ���ܣ����ڴ洢�����в�׽ Check Լ���򴥷���Լ�����׳��쳣���������ԱȽϷ����ʵ������У�飬���Ҽ����ڴ洢�����еĹ�������ݵ��жϡ�
if exists (select * from sysobjects where name='proc_insert_user') 
	drop proc proc_insert_user
go
create proc proc_insert_user
@name varchar(20),
@sex char(2),
@pw char(10)
as
	begin try
		insert into users values(@name,@sex,@pw)
		update users set @pw= substring(sys.fn_sqlvarbasetostr (HashBytes('MD5',@pw)),3,32) where @name=Uname and @sex=sex
	end try
	begin catch				
		print(ERROR_MESSAGE())
	end catch
go
exec proc_insert_user 'С��','��','156'
exec proc_insert_user 'С��','1','12156'
