--1.���Ҷ��߽������������û�н���Ķ�����Ϣ, ��ʾ����֤�š�������ͼ���š�
select b.Read_no as  ����֤�� ,b.Read_name as ����,a.Book_no as  ͼ����
from  dbo.Reader b
left join dbo.Borrow a
on a.Read_no=b.Read_no;


--2.����û�н����Ķ���, ��ʾ����֤�š���������λ
select a.Read_no as ����֤�� ,a.Read_name as ����,a.Read_dept as ��λ
from dbo.Reader a
where a.Read_no not in (
	select b.Read_no
	from dbo.Borrow b
)


--3.ͳ��ÿ����λ��ǰ����ͼ���������
select b.Read_dept as ��λ, count ( *) as ��������
from dbo.Borrow a , dbo.Reader b
where a.Read_no=b.Read_no
group by b.Read_dept


--4.ͳ�Ƹ�ѧԺѧ������ͼ�������(ע�⣺ְ���Ľ���֤��4λ���֣�ѧ������֤��10λ���� ��
select b.Read_dept as ��λ,COUNT(*)as ��������
from dbo.Reader b ,(select a.Read_no 
	from dbo.Borrow a 
	where len(a.Read_no)>6
	group by a.Read_no )t
where b.Read_no=t.Read_no
group by  b.Read_dept 


--5.�ҳ���ǰ���ٽ�����2��ͼ��Ķ��߽���֤�š����������ڵ�λ��
select  a.Read_no as ����֤�� ,b.Read_name as ����,  b.Read_dept as ��λ
from dbo.Borrow a ,dbo.Reader b
where a.Read_no=b.Read_no 
group by a.Read_no,b.Read_name,b.Read_dept 
having count(*) >=2

----6.�޸ĵ���ʱ���ֶΣ�Ҫ�󣺽�ְ���Ľ���3���£�ѧ���Ľ���1����
---- ������״̬Ϊ���裬���ְ���Ľ���6���£�ѧ���Ľ���2���£��������ַ�����
update dbo.Borrow
set Due_time = dateadd (month,(case when len(Read_no)<6 then 3 else 1 end)*(case when  Renew_status = 1 then 2 else 1 end ),Borr_time)



--7.����ͬʱ������ͼ����B1481539��B1547940������Ľ���֤�ţ�����2 �ַ�����
select a.Read_no
from dbo.Borrow a ,dbo.Borrow b
where a.Read_no=b.Read_no and a.Book_no='B1481539' and b.Book_no='B1547940'

--8. �ҳ��ѵ��ڵ�������ͼ���š�������������λ
select a.Book_no as ����,a.Book_no as ͼ����,b.Read_name as �������� ,b.Read_dept as ��λ
from  dbo.Borrow a ,dbo.Reader b
where (CONVERT(varchar, a.Due_time) >= CONVERT(varchar, GETDATE()))
	and a.Read_no=b.Read_no;

--9.���ѵ��ڵ���û���ģ�����һ�ŷ��������һ�췣��0.5Ԫ��������е����ݰ���������֤�ţ�ͼ����,����ʱ��,�����ܽ��
select a.Read_no as ����֤��, a.Book_no as ͼ����,a.Borr_time as ����ʱ��,
0.5*DATEDIFF(day,a.Due_time,GETDATE()) as �����ܽ��
from dbo.Borrow a 


--10.  ����2020�����������ǰ2����š���������������
select top 2 a.Read_no as ���,a.Read_name as ��������, t.size as ��������
from dbo.Reader a,(
	select top 10 b.Read_no,count(*) as size
	from dbo.Borrow b
	group by b.Read_no
) t
where a.Read_no =t.Read_no
order by size  desc,a.Read_no


--11.���ұȡ��廪��ѧ�����确�������߼۸񻹸ߵ���Ļ�����Ϣ
select *
from dbo.Catalog a
where a.Price>all(
	select b.Price
	from dbo.Catalog b
	where b.Press='�廪��ѧ������'
)



--12.ͳ��ÿλ���߽������ݽṹ��C++������ơ�SQL��̺�Java Web Ӧ�ÿ����ı�����������
select  a.Read_no as ���� , sum (case when c.Bname='���ݽṹ' then 1 else 0 end )as 'C++�������' ,
							sum (case when c.Bname='C++�������' then 1 else 0 end )as 'C++�������' ,
							sum (case when c.Bname='SQL ���' then 1 else 0 end )as 'SQL ���' ,
							sum (case when c.Bname='Java Web Ӧ�ÿ���' then 1 else 0 end )as 'Java Web Ӧ�ÿ���'
from dbo.Borrow a ,dbo.Catalog c,dbo.Book b
where b.Book_no=a.Book_no and b.ISBN=c.ISBN
group by a.Read_no 
