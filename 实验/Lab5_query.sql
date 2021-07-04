--Lab5.query.sql

-- 1. 设计安全机制使得用户王明只能查找财务部的职工。
--exec	sp_addlogin '王明' ,'123456'
--exec  sp_grantdbaccess '王明','王明'
--exec	sp_droplogin '王明'
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
		where Dep_name like '财务部'
	)
go
GRANT SELECT  ON  View_Caiwubu to  王明
select * from View_Caiwubu --查看视图
	

-- 2. 设计角色“Role_Emp”，该角色可以查看雇员编号、雇员姓名。并将用户王明作为成员加入到该角色。
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
exec sp_addrolemember 'Role_Emp' ,'王明'
select * from View_Emp_no_name

-- 3. 用户张明拥有以下权力：他只能查进货表中的信息，并拥有对自已进货的信息修改的权限，其它表的信息无权查看。如何设置？请给 出SQL代码。 
--exec sp_addlogin '张明','123456'
--exec sp_grantdbaccess '张明','张明'
if exists (select * from sysobjects where name='view_Purchase_ZhangMing') 
    drop view view_Purchase_ZhangMing
go
create view view_Purchase_ZhangMing
as
	select * from Purchase 
	where Emp_no in(select Emp_no from Employees
               where Emp_name='张明')
go
Grant select on Purchase to 张明
Grant update on view_Purchase_ZhangMing to 张明

-- 4. 如何使得采购部门的员工都具有这样的权限：能查看进货表的信息，并拥有对自已采购信息的修改，其它的信息无权查看。
--（要求：编写存储过程 proc_emp_grant，其作用：输入参数为员工姓名，从进货表中查找该员工所进货的产品，
--如果没有则返回，有的话则相应的在 login 表中添加账号和密码。并且，创建相应的登录账号和数据库用户）
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
exec proc_emp_grant '王燕'
-- 5. 银行转账问题.  写出用事务解决银行转账的存储过程：
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

-- 6. 数据库字段的加密和解密
--1)创建读者表的空表名为: 读者_bak, 增加一字段: 身份证号;
if exists (select * from sysobjects where name='Reader_bak') 
	drop table Reader_bak
select * into Reader_bak from Reader where 1=2
alter table Reader_bak add [身份证号]  varbinary(500) not null
--2)创建数据库主密钥;
--if exists(SELECT * FROM sys.symmetric_keys)
--	drop master key
--create master key encryption by password='123456'

--3)建立证书一,该证书使用数据库主密钥来加密
go
 
drop certificate Cert_Demo1
create certificate Cert_Demo1  
with
	 subject=N'cert encryption by database master key',
	 start_date='2021-1-1',
	 expiry_date='2021-12-30'
go
--4)对读者bak表做插入一条记录，借书证号为: 210, 身份证号为:'350211199611020045'
insert into Reader_bak(Read_no,身份证号) values('210',encryptbycert(cert_id(N'Cert_Demo1'),N'350211199611020045'))

--5)将加密的身份证号解密显示出来
select * from Reader_bak
select convert(nvarchar(500),decryptbycert(cert_id(N'Cert_Demo1'),身份证号))
from Reader_bak
--6)总结对数据库字段加密和解密的理解。



--  7. 给出一个用户表，创建表的代码如下：
if exists (select * from sysobjects where name='users') 
	drop table users
 create table users
 (
 	Unumber	int identity(1,1),	--自动编号，标识列
 	Uname		varchar(20),		--昵称
 	sex		char(2),			--性别
 	Upassword	varchar(32),		--密码
 	CONSTRAINT PK_Unum	PRIMARY KEY(Unumber),
 	CONSTRAINT CK_sex CHECK(sex='男' or sex='女'),
 	CONSTRAINT CK_Upassword CHECK (LEN(Upassword)>=6)
 )
-- 要求创建一个存储过程，实现插入用户表（users）数据时，插入的密码要求自动转换为密文（提示：用 
-- SQL 内置函数实现 MD5 加密），在存储过程中捕捉 Check 约束或触发器约束中抛出异常。这样可以比较方便的实现数据校验，并且减少在存储过程中的过多对数据的判断。
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
exec proc_insert_user '小张','男','156'
exec proc_insert_user '小张','1','12156'
