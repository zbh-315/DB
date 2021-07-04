-- 1.创建一个新表名为：总金额表 。字段包含：商品名称, 总金额, 返回的结果集行的百分比为50.
if exists(select * from sysobjects where name='总金额表'  )  drop table 总金额表 
    select top 50 percent * into 总金额表 from (select Goods.Goo_name as 商品名称,Purchase.Pur_num*Purchase.Pur_price as 总金额 
    from Goods,Purchase
    where Goods.Goo_no=Purchase.Goo_no
)t
select * from 总金额表


-- 2.统计2019年，销售总金额最高的员工号，销售总金额。
select  top 1 Sell.Emp_no as 雇员号, sum(Sell_prices*Sell_num) as 销售总金额
from Sell
where  YEAR(Sell_date)=2019
group by Sell.Emp_no
order by  销售总金额 DESC


-- 3..查询同一商品进货的总数量。（进货数量等于当前进货数量+销售数量）
select Sell.Goo_no as 商品编号,sum(Purchase.Pur_num+Sell.Sell_num) as 进货数量
from Purchase,Sell
where Sell.Goo_no=Purchase.Goo_no
group by Sell.Goo_no


-- 4.  统计每个员工，2020年2月之前，员工号, 姓名, 销售总金额.并显示销售部门未销售的员工。
select Employees.Emp_no as 员工号,Employees.Emp_name as 姓名,sum(Sell.Sell_num*Sell.Sell_prices)  as 销售总金额
from Employees
left join Sell
on Sell.Emp_no=Employees.Emp_no and Sell.Sell_date<('2020-2-1')
group by Employees.Emp_no,Employees.Emp_name


-- 5. 统计2019年第4季度员工的销售总金额,并按降序排序
select Employees.Emp_no as 员工号,sum(Sell.Sell_num*Sell.Sell_prices) as 销售总金额
from Employees,Sell
where Sell.Emp_no=Employees.Emp_no and Sell.Sell_date>=('2019-9-1') and Sell.Sell_date<('2020-1-1')
group by Employees.Emp_no
order by sum(Sell.Sell_num*Sell.Sell_prices) desc


-- 6. 查询商品名称,销售数量，包括没有销售的商品名称。
select Goods.Goo_name as 商品名称,sum(Sell.Sell_num) as 销售数量
from Goods
left join Sell
on Goods.Goo_no=Sell.Goo_no
group by Goods.Goo_name


-- 7. 显示如下结果，应如何实现
select Employees.Dep_no as 部门号, Employees.Emp_sex as 性别, count(*) as 员工人数
from Employees
group by Employees.Emp_sex,Employees.Dep_no 


-- 8. 显示如下结果，应如何实现
select Employees.Dep_no as 部门号, Employees.Emp_sex as 性别, count(*) as 员工人数
from Employees
group by Employees.Dep_no, Employees.Emp_sex
with rollup


-- 9. 在销售数据库中查询每个员工在2019年12月的销售商品利润，并发布提成，销售额低于10万的提成1%；10万到50万之间的提成2% ；高于50万的，提成3%。
select Employees.Emp_no as 编号,Employees.Emp_name as 姓名,s.sum_sale as 总销售额,
	(case
	when sum_sale< 100000 then sum_sale *0.01
	when sum_sale< 500000 and sum_sale> 100000 then sum_sale*0.02
	when sum_sale> 500000 then sum_sale *0.03
	end
	) as 提成
from Employees,	(select Sell.Emp_no,sum(Sell_num *Sell_prices) as sum_sale
	from Sell
	where
	YEAR(Sell.Sell_date)=2019 and MONTH(Sell.Sell_date)=12
	group by Sell.Emp_no) s
where Employees.Emp_no = s.Emp_no



-- 10、创建视图v1，要求查询'佳能公司'，2019年12月份商品的销售情况和每一笔销售的纯利润，并对视图v1加密：
if exists (select * from sysobjects where name='V1') 
    drop view V1
go
create view V1 with encryption
as
select Sell_no as 销售编号,
    Sell.Goo_no as 商品编码,
    Goo_name as 商品名称,
    Pur_price as 进货价,
    Sell_prices as 销售价,
    Sell_num as 销售数量,
(Sell_prices - Pur_price) * Sell_num as 销售纯利润
from (
        Sell
        inner join Purchase 
		on Sell.Goo_no = Purchase.Goo_no
    )
    inner join Goods 
	on Goods.Goo_no = Sell.Goo_no
where YEAR(Sell.Sell_date)=2019 and MONTH(Sell.Sell_date)=12 
    and Goods.Goo_no in (
        select Goods.Goo_no
        from Goods --           
        where Goods.Pro_name = '佳能公司'
    )
 go
select *
from V1 


-- 11．根据销售表Shell的数据,分别显示员工2019年第4季度销售总金额。
select Emp_no as 员工号,
    sum (
        case when YEAR(Sell_date) = 2019 and MONTH(Sell_date)=10 
            then (Sell_prices * Sell_num)
        else 0
        end
    ) as '2019年10月销售总金额',
    sum (
        case when YEAR(Sell_date) = 2019 and MONTH(Sell_date)=11 
            then (Sell_prices * Sell_num)
        else 0
        end
    ) as '2019年11月销售总金额',
    sum (
        case when YEAR(Sell_date) = 2019 and MONTH(Sell_date)=12 
            then (Sell_prices * Sell_num)
        else 0
        end
    ) as '2019年12月销售总金额'
from Sell 
group by Emp_no


-- 12. 为新建的表创建一个唯一性聚集索引：
if exists (select * from sysobjects where name='公司')
	drop table 公司
 create table 公司 (
 编号      int identity(1,1) not null,
         名称      varchar(30) not null,
 法人代表  varchar(8),
 地址      varchar(50)
 )

 if not exists (SELECT * FROM sysobjects WHERE name='PK_公司' and xtype='PK') 
    ALTER TABLE 公司 add constraint PK_公司 primary key(编号,名称)





