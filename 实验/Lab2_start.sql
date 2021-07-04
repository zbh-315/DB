--Department
ALTER TABLE Department alter column Dep_no	       char(3) not null
ALTER TABLE Department alter column Dep_name	   nvarchar(50) not null
ALTER TABLE Department alter column Dep_Phone      char(14) not null
if not exists (SELECT * FROM sysobjects WHERE name='PK_Department' and xtype='PK') 
   ALTER TABLE Department add constraint PK_Department primary key(Dep_no)

--Employees 
CREATE TYPE Telephone from varchar(11) not null 
ALTER TABLE Employees alter column Emp_no			char(4) not null 
ALTER TABLE Employees alter column Emp_name			nvarchar(20) not null 
ALTER TABLE Employees alter column Emp_sex			nchar(2) not null 
ALTER TABLE Employees alter column Dep_no			char(3) not null 
ALTER TABLE Employees alter column Empp_phone	    Telephone 
ALTER TABLE Employees alter column Emp_address	    nvarchar(40) not null 
ALTER TABLE Employees alter column Emp_email		varchar(20) 
if not exists (SELECT * FROM sysobjects WHERE name='PK_Employees' and xtype='PK') 
    ALTER TABLE Employees add constraint PK_Employees primary key(Emp_no)
if not exists (SELECT * FROM sysobjects WHERE name='FK_Employees' and xtype='F') 
	ALTER TABLE Employees add constraint FK_Employees foreign key(Dep_no) references Department(Dep_no)

--Goods
ALTER TABLE Goods alter column Goo_no char(8) not null 
ALTER TABLE Goods alter column Goo_name nvarchar(40) not null 
ALTER TABLE Goods alter column Pro_name		    nvarchar(20) not null 
if not exists (SELECT * FROM sysobjects WHERE name='PK_Goods' and xtype='PK') 
    ALTER TABLE Employees add constraint PK_Goods primary key(Goo_no)


--Purchase
ALTER TABLE Purchase alter column Pur_no    int not null
ALTER TABLE Purchase alter column Pur_price money not null 	
ALTER TABLE Purchase alter column Pur_num   int not null 	
ALTER TABLE Purchase alter column Pur_date  date not null 	
ALTER TABLE Purchase alter column Goo_no    char(8) not null 	
ALTER TABLE Purchase alter column Emp_no    char(4) not null 
if not exists (SELECT * FROM sysobjects WHERE name='PK_Purchase' and xtype='PK') 
    ALTER TABLE Purchase add constraint PK_Purchase primary key(Pur_no) 
if not exists (SELECT * FROM sysobjects WHERE name='FK_Purchase1' and xtype='F') 
	ALTER TABLE Purchase add constraint FK_Purchase1 foreign key(Goo_no) references Goods(Goo_no)
if not exists (SELECT * FROM sysobjects WHERE name='FK_Purchase2' and xtype='F') 
	ALTER TABLE Purchase add constraint FK_Purchase2 foreign key(Emp_no) references Employees(Emp_no)


--Sell
ALTER TABLE Sell alter column Sell_no char(10) not null 	
ALTER TABLE Sell alter column Sell_num int not null 	
ALTER TABLE Sell alter column Sell_date date 
ALTER TABLE Sell alter column Sell_prices money not null 	
ALTER TABLE Sell alter column Goo_no char(8) not null 	
ALTER TABLE Sell alter column Emp_no char(4) not null 
if not exists (SELECT * FROM sysobjects WHERE name='FK_Sell1' and xtype='F') 
	ALTER TABLE Sell add constraint FK_Sell1 foreign key(Goo_no) references Goods(Goo_no)
if not exists (SELECT * FROM sysobjects WHERE name='FK_Sell2' and xtype='F') 
	ALTER TABLE Sell add constraint FK_Sell2 foreign key(Emp_no) references Employees(Emp_no)
if not exists(select * from sysobjects where name='check_Sell')
begin
    alter table Sell
    with check --该约束是否应用于现有数据，with check表示应用于现有数据，with nocheck表示不应用于现有数据
    add constraint check_Sell
    check 
    not for replication --当复制代理在表中插入或更新数据时，禁用该约束。
    (Sell_no like '[A-Z,a-z]%');
end


