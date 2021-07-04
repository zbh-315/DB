
CREATE TABLE bbsUsers 
(
   UID INT IDENTITY (1,1) NOT NULL , --自动编号，标识列
   Uname VARCHAR(15) NOT NULL ,      --呢称
   Upassword VARCHAR (10)  ,         --密码
   Uemail VARCHAR (20)  ,            --邮件
   Ubirthday DATETIME  ,             --生日
   Usex BIT NOT NULL ,               --性别
   Uclass INT   ,                    --级别（几星级）
   Uremark VARCHAR (20) ,           --备注
   UregDate DATETIME NOT NULL ,      --注册日期
   Ustate INT NULL ,                 --状态（是否禁言等）
   Upoint INT NULL                   --积分（点数）
) 
GO


/*--------添加约束-------*/
ALTER TABLE bbsUsers ADD CONSTRAINT PK_UID PRIMARY KEY(UID) --主键
ALTER TABLE bbsUsers ADD CONSTRAINT DF_Upassword  DEFAULT (8888) FOR Upassword --初始密码密码为8888
ALTER TABLE bbsUsers ADD CONSTRAINT DF_Usex DEFAULT (1) FOR Usex  --性别默认为男（1）
ALTER TABLE bbsUsers ADD CONSTRAINT DF_Uclass DEFAULT (1) FOR Uclass --级别默认为1星级
ALTER TABLE bbsUsers ADD CONSTRAINT DF_UregDate DEFAULT (getDate( )) FOR UregDate --注册日期默认为当前日期
ALTER TABLE bbsUsers ADD CONSTRAINT DF_Ustate DEFAULT (0) FOR Ustate --状态默认为离线
ALTER TABLE bbsUsers ADD CONSTRAINT DF_Upoint DEFAULT (20) FOR Upoint --默认积分20点
ALTER TABLE bbsUsers ADD CONSTRAINT CK_Uemail CHECK (Uemail LIKE '%@%') --必须包含'@'字符
ALTER TABLE bbsUsers ADD CONSTRAINT CK_Upassword CHECK (LEN(Upassword) >= 6) --至少6位
GO


--
/*新建bbsSection（版块表）表*/
if exists(select * from sysobjects where name = 'bbsSection')
  drop table bbsSection
GO
create table bbsSection
(
	SID INT IDENTITY (1, 1) NOT NULL ,
	Sname VARCHAR (32) NOT NULL ,
	UID INT NOT NULL ,
	Sprofile VARCHAR (255) NULL ,
	SclickCount INT NULL ,
	StopicCount INT NULL 
)
go
/*bbsSection表约束*/
alter table bbsSection add constraint PK_SID primary key (SID)  --主键约束
alter table bbsSection add constraint DF_SclickCount default(0) for SclickCount --默认约束
alter table bbsSection add constraint DF_StopicCount default(0) for StopicCount --默认约束
alter table bbsSection add constraint FK_SmasterID foreign key (UID) references bbsUsers(UID)

--
/*新建bbsTopic（主贴表）表*/
go
create table bbsTopic
(
	TID INT IDENTITY (1, 1) NOT NULL , --帖子编号
	SID INT NOT NULL ,  --版块编号
	UID INT NOT NULL ,  --发帖人
	TreplyCount INT NULL ,  ---回复数量
	Tface INT NULL ,        --发帖表情
	Ttopic VARCHAR(20) NOT NULL ,  	--标题
	Tcontents VARCHAR(30) NOT NULL , --正文
	Ttime DATETIME NULL,       --发帖时间
	TclickCount INT NULL ,     --点击数
	Tstate INT NOT NULL,       --状态
	TlastReply DATETIME NULL 
)
go

/*建bbsTopic约束*/
alter table bbsTopic add constraint PK_TID primary key (TID)  --主键约束
alter table bbsTopic add constraint FK_TsID foreign key (SID) references bbsSection(SID)  --外键约束
alter table bbsTopic add constraint FK_TuID foreign key (UID) references bbsUsers (UID)    --外键约束
alter table bbsTopic add constraint DF_TreplyCount default(0) for TreplyCount   --默认约束
alter table bbsTopic add constraint DF_Ttime default(getDate()) for Ttime          --默认约束
alter table bbsTopic add constraint DF_TclickCount default(0) for TclickCount   --默认约束
alter table bbsTopic add constraint DF_Tstate default(1) for Tstate             --默认约束
alter table bbsTopic add constraint CK_Tcontents check (LEN(Tcontents)>6)       --检查约束
alter table bbsTopic add constraint CK_TlastReply check (TlastReply>Ttime AND TlastReply <= getdate()) --检查约束
alter table bbsTopic add constraint CK_Ttime check (Ttime<=getDate())           


/*建表 bbsReply（(回贴表）*/

GO
create table bbsReply
(
	RID INT IDENTITY (1, 1) NOT NULL ,
	TID INT NOT NULL ,
	SID INT NOT NULL ,
	UID INT NOT NULL ,
	Rface INT NULL,
	Rcontents VARCHAR(30) NOT NULL ,
	Rtime DATETIME NULL ,
	RclickCount INT NULL 
)
go

/*建表bbsReply 约束*/
alter table bbsReply add constraint PK_RID primary key (RID)
alter table bbsReply add constraint FK_RtID foreign key (TID) references bbsTopic (TID)
alter table bbsReply add constraint FK_RsID foreign key (SID) references bbsSection (SID)
alter table bbsReply add constraint FK_RuID foreign key (UID) references bbsUsers (UID)
alter table bbsReply add constraint CK_Rcontents check (len(Rcontents)>6)
alter table bbsReply add constraint DF_Rtime default(getdate()) for Rtime

go