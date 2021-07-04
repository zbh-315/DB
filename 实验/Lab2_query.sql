--5.1
if not exists(select * from sysobjects where name='IX_EmployeesTeNo' and xtype='UQ')
	alter table Employees add constraint IX_EmployeesTeNo unique (Empp_phone) 

--5.2
if not exists(select * from information_schema.constraint_column_usage where CONSTRAINT_NAME='CK_EmpNo' )
	alter table Employees with check add constraint CK_EmpNo 
    check 
    not for replication --当复制代理在表中插入或更新数据时，禁用该约束。
    (Emp_no like '[0-9][0-9][0-9][0-9]');

--5.3
if not exists (select * from sysobjects where name='DF_Sell_date' and xtype='D') 
	alter table Sell add constraint DF_Sell_date default(getdate()) for Sell_date

--5.4
if not exists(select * from syscolumns where id=object_id('Employees') and name='邮箱') 
begin
    ALTER TABLE Employees ADD 邮箱 varchar(20) 
		if not exists(select * from sysobjects where name='UN_postcode' )
			alter table Employees with nocheck add constraint UN_postcode unique(邮箱)
end

--6
if not exists (select * from sysobjects where name='Employees2') 
	select * into Employees2 from Employees where Employees.Emp_sex='男'
select * from Employees2

--8
if exists (select * from sysobjects where name='Purchase_bak') 
	drop table Purchase_bak
select * into Purchase_bak from Purchase where 1=2
insert into Purchase_bak select * from Purchase where Pur_num =0
select * from Purchase_bak

--9
if not exists (select * from sysobjects where name='StartPurchase') 
	select * into StartPurchase from Purchase
select * from StartPurchase
select Goods.Pro_name,StartPurchase.Pur_price
from Goods,StartPurchase
where Goods.Goo_no=StartPurchase.Goo_no 
if exists (select *from Purchase where Pur_no='100' and Pur_price=5600)
begin
	update Purchase
	set Pur_price = Pur_price *(
		case 
			when Goods.Pro_name='佳能公司' then 0.9 
			else 
				case when  Goods.Pro_name='惠普公司' then 0.8	
					else 0.95 
				end
		end
	)
	from Goods
	where Goods.Goo_no=Purchase.Goo_no 
end
select Goods.Pro_name,Purchase.Pur_price
from Goods,Purchase
where Goods.Goo_no=Purchase.Goo_no 



