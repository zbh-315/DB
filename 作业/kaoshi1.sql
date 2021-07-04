---、现有图书管理数据库的三个关系模式:
--书目录(ISBN号,分类号,作者,出版单位,单价,数量)
--书(总编号, ISBN号,借阅)
--诸(借书证号, 单位,姓名，性别，职称，地址)
--借阅(借书证号， 总编号,借日期,续借)
--1,先將book__A.xls文件快速导入到SQL SERVER或MySQL中，修改表结构
--要求完成下列完整性约约束:
--1)设置每个表的主外码;
--2)如果修改读者表中借书证号,阅表中的借书证号也自动修改。
--3)单价必须大于0;
--4)阅状态默认为:未借，
--借书日期默认为当前系统时间
--生成关系图，并将关系图导入答题卡中。
--生成4张表的SQL代码。

--预处理：修改表的结构
--书目$
alter table 书目$ alter column 单价 money
alter table 书目$ alter column 数量 int
alter table 书目$ alter column ISBN号 char(30) not null
alter table 书目$ alter column 分类号 char(30)not null

--图书$
alter table 图书$ alter column ISBN号 char(30) not null
alter table 图书$ alter column 总编号 char(30)not null

--读者$
alter table 读者$ alter column 借书证号 char(30) not null

--借阅$
alter table 借阅$ alter column 借书日期 date
alter table 借阅$ alter column 借书证号 char(30)not null
alter table 借阅$ alter column 总编号 char(30)not null

----1)设置每个表的主外码;
if not exists (SELECT * FROM sysobjects WHERE name='PK_书目$' and xtype='PK') 
    ALTER TABLE 书目$ add constraint PK_书目$ primary key(分类号,ISBN号) 
if not exists (SELECT * FROM sysobjects WHERE name='PK_图书$' and xtype='PK') 
    ALTER TABLE 图书$ add constraint PK_图书$ primary key(总编号,ISBN号) 
--	alter table 读者$  drop primary key  PK_读者$
if not exists (SELECT * FROM sysobjects WHERE name='PK_读者$' and xtype='PK') 
    ALTER TABLE 读者$ add constraint PK_读者$ primary key(借书证号) 
if not exists (SELECT * FROM sysobjects WHERE name='PK_借阅$' and xtype='PK') 
    ALTER TABLE 借阅$ add constraint PK_借阅$ primary key(借书证号,总编号) 

--2)如果修改读者表中借书证号,阅表中的借书证号也自动修改。
	时间不够，暂时放一下

--3)单价必须大于0;
--设计检查约束

if not exists(select * from sysobjects where name='check_书目$_单价')
begin
    alter table 书目$
    with check     add constraint check_书目$_单价
    check 
    not for replication 
    (单价>0);
end
--4)阅状态默认为:未借，
--默认约束
if not exists (select * from sysobjects where name='DF_图书$_借阅状态' and xtype='D') 
	alter table 图书$ add constraint DF_Sell_date default('未借') for 借阅状态

