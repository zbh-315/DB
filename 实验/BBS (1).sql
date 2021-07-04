
CREATE TABLE bbsUsers 
(
   UID INT IDENTITY (1,1) NOT NULL , --�Զ���ţ���ʶ��
   Uname VARCHAR(15) NOT NULL ,      --�س�
   Upassword VARCHAR (10)  ,         --����
   Uemail VARCHAR (20)  ,            --�ʼ�
   Ubirthday DATETIME  ,             --����
   Usex BIT NOT NULL ,               --�Ա�
   Uclass INT   ,                    --���𣨼��Ǽ���
   Uremark VARCHAR (20) ,           --��ע
   UregDate DATETIME NOT NULL ,      --ע������
   Ustate INT NULL ,                 --״̬���Ƿ���Եȣ�
   Upoint INT NULL                   --���֣�������
) 
GO


/*--------���Լ��-------*/
ALTER TABLE bbsUsers ADD CONSTRAINT PK_UID PRIMARY KEY(UID) --����
ALTER TABLE bbsUsers ADD CONSTRAINT DF_Upassword  DEFAULT (8888) FOR Upassword --��ʼ��������Ϊ8888
ALTER TABLE bbsUsers ADD CONSTRAINT DF_Usex DEFAULT (1) FOR Usex  --�Ա�Ĭ��Ϊ�У�1��
ALTER TABLE bbsUsers ADD CONSTRAINT DF_Uclass DEFAULT (1) FOR Uclass --����Ĭ��Ϊ1�Ǽ�
ALTER TABLE bbsUsers ADD CONSTRAINT DF_UregDate DEFAULT (getDate( )) FOR UregDate --ע������Ĭ��Ϊ��ǰ����
ALTER TABLE bbsUsers ADD CONSTRAINT DF_Ustate DEFAULT (0) FOR Ustate --״̬Ĭ��Ϊ����
ALTER TABLE bbsUsers ADD CONSTRAINT DF_Upoint DEFAULT (20) FOR Upoint --Ĭ�ϻ���20��
ALTER TABLE bbsUsers ADD CONSTRAINT CK_Uemail CHECK (Uemail LIKE '%@%') --�������'@'�ַ�
ALTER TABLE bbsUsers ADD CONSTRAINT CK_Upassword CHECK (LEN(Upassword) >= 6) --����6λ
GO


--
/*�½�bbsSection��������*/
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
/*bbsSection��Լ��*/
alter table bbsSection add constraint PK_SID primary key (SID)  --����Լ��
alter table bbsSection add constraint DF_SclickCount default(0) for SclickCount --Ĭ��Լ��
alter table bbsSection add constraint DF_StopicCount default(0) for StopicCount --Ĭ��Լ��
alter table bbsSection add constraint FK_SmasterID foreign key (UID) references bbsUsers(UID)

--
/*�½�bbsTopic����������*/
go
create table bbsTopic
(
	TID INT IDENTITY (1, 1) NOT NULL , --���ӱ��
	SID INT NOT NULL ,  --�����
	UID INT NOT NULL ,  --������
	TreplyCount INT NULL ,  ---�ظ�����
	Tface INT NULL ,        --��������
	Ttopic VARCHAR(20) NOT NULL ,  	--����
	Tcontents VARCHAR(30) NOT NULL , --����
	Ttime DATETIME NULL,       --����ʱ��
	TclickCount INT NULL ,     --�����
	Tstate INT NOT NULL,       --״̬
	TlastReply DATETIME NULL 
)
go

/*��bbsTopicԼ��*/
alter table bbsTopic add constraint PK_TID primary key (TID)  --����Լ��
alter table bbsTopic add constraint FK_TsID foreign key (SID) references bbsSection(SID)  --���Լ��
alter table bbsTopic add constraint FK_TuID foreign key (UID) references bbsUsers (UID)    --���Լ��
alter table bbsTopic add constraint DF_TreplyCount default(0) for TreplyCount   --Ĭ��Լ��
alter table bbsTopic add constraint DF_Ttime default(getDate()) for Ttime          --Ĭ��Լ��
alter table bbsTopic add constraint DF_TclickCount default(0) for TclickCount   --Ĭ��Լ��
alter table bbsTopic add constraint DF_Tstate default(1) for Tstate             --Ĭ��Լ��
alter table bbsTopic add constraint CK_Tcontents check (LEN(Tcontents)>6)       --���Լ��
alter table bbsTopic add constraint CK_TlastReply check (TlastReply>Ttime AND TlastReply <= getdate()) --���Լ��
alter table bbsTopic add constraint CK_Ttime check (Ttime<=getDate())           


/*���� bbsReply��(������*/

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

/*����bbsReply Լ��*/
alter table bbsReply add constraint PK_RID primary key (RID)
alter table bbsReply add constraint FK_RtID foreign key (TID) references bbsTopic (TID)
alter table bbsReply add constraint FK_RsID foreign key (SID) references bbsSection (SID)
alter table bbsReply add constraint FK_RuID foreign key (UID) references bbsUsers (UID)
alter table bbsReply add constraint CK_Rcontents check (len(Rcontents)>6)
alter table bbsReply add constraint DF_Rtime default(getdate()) for Rtime

go