---������ͼ��������ݿ��������ϵģʽ:
--��Ŀ¼(ISBN��,�����,����,���浥λ,����,����)
--��(�ܱ��, ISBN��,����)
--��(����֤��, ��λ,�������Ա�ְ�ƣ���ַ)
--����(����֤�ţ� �ܱ��,������,����)
--1,�Ȍ�book__A.xls�ļ����ٵ��뵽SQL SERVER��MySQL�У��޸ı�ṹ
--Ҫ���������������ԼԼ��:
--1)����ÿ�����������;
--2)����޸Ķ��߱��н���֤��,�ı��еĽ���֤��Ҳ�Զ��޸ġ�
--3)���۱������0;
--4)��״̬Ĭ��Ϊ:δ�裬
--��������Ĭ��Ϊ��ǰϵͳʱ��
--���ɹ�ϵͼ��������ϵͼ������⿨�С�
--����4�ű��SQL���롣

--Ԥ�����޸ı�Ľṹ
--��Ŀ$
alter table ��Ŀ$ alter column ���� money
alter table ��Ŀ$ alter column ���� int
alter table ��Ŀ$ alter column ISBN�� char(30) not null
alter table ��Ŀ$ alter column ����� char(30)not null

--ͼ��$
alter table ͼ��$ alter column ISBN�� char(30) not null
alter table ͼ��$ alter column �ܱ�� char(30)not null

--����$
alter table ����$ alter column ����֤�� char(30) not null

--����$
alter table ����$ alter column �������� date
alter table ����$ alter column ����֤�� char(30)not null
alter table ����$ alter column �ܱ�� char(30)not null

----1)����ÿ�����������;
if not exists (SELECT * FROM sysobjects WHERE name='PK_��Ŀ$' and xtype='PK') 
    ALTER TABLE ��Ŀ$ add constraint PK_��Ŀ$ primary key(�����,ISBN��) 
if not exists (SELECT * FROM sysobjects WHERE name='PK_ͼ��$' and xtype='PK') 
    ALTER TABLE ͼ��$ add constraint PK_ͼ��$ primary key(�ܱ��,ISBN��) 
--	alter table ����$  drop primary key  PK_����$
if not exists (SELECT * FROM sysobjects WHERE name='PK_����$' and xtype='PK') 
    ALTER TABLE ����$ add constraint PK_����$ primary key(����֤��) 
if not exists (SELECT * FROM sysobjects WHERE name='PK_����$' and xtype='PK') 
    ALTER TABLE ����$ add constraint PK_����$ primary key(����֤��,�ܱ��) 

--2)����޸Ķ��߱��н���֤��,�ı��еĽ���֤��Ҳ�Զ��޸ġ�
	ʱ�䲻������ʱ��һ��

--3)���۱������0;
--��Ƽ��Լ��

if not exists(select * from sysobjects where name='check_��Ŀ$_����')
begin
    alter table ��Ŀ$
    with check     add constraint check_��Ŀ$_����
    check 
    not for replication 
    (����>0);
end
--4)��״̬Ĭ��Ϊ:δ�裬
--Ĭ��Լ��
if not exists (select * from sysobjects where name='DF_ͼ��$_����״̬' and xtype='D') 
	alter table ͼ��$ add constraint DF_Sell_date default('δ��') for ����״̬

