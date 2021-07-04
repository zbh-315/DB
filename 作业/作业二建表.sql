ALTER TABLE dbo.Admin alter column Adm_no	  varchar(15) not null 
ALTER TABLE dbo.Admin alter column Adm_name	   varchar(15) not null
ALTER TABLE dbo.Admin alter column Adm_sex	  varchar(15) not null
ALTER TABLE dbo.Admin alter column Adm_telephone  varchar(15) not null
--ALTER TABLE dbo.Admin add constraint Adminkey primary key(Adm_no) 
--ALTER TABLE dbo.Admin drop constraint  Adminkey


ALTER TABLE dbo.Book alter column Book_no     varchar(15) not null
ALTER TABLE dbo.Book alter column ISBN        varchar(30) not null
ALTER TABLE dbo.Book alter column B_status    varchar(15) not null
ALTER TABLE dbo.Book alter column Adm_no      varchar(15) not null
--ALTER TABLE dbo.Book add constraint Bookkey primary key(Book_no) 
--ALTER TABLE dbo.Book drop constraint Bookkey


ALTER TABLE dbo.Borrow alter column Read_no	      varchar(15) not null
ALTER TABLE dbo.Borrow alter column Book_no	      varchar(15) not null
ALTER TABLE dbo.Borrow alter column Borr_time	      date not null
ALTER TABLE dbo.Borrow alter column Due_time	      date not null
ALTER TABLE dbo.Borrow alter column Return_time	      date
ALTER TABLE dbo.Borrow alter column Renew_status      int not null


ALTER TABLE dbo.Catalog alter column ISBN	varchar(30) not null
ALTER TABLE dbo.Catalog alter column Bname	varchar(30) not null
ALTER TABLE dbo.Catalog alter column Author	varchar(30) not null
ALTER TABLE dbo.Catalog alter column Press	varchar(39) not null
ALTER TABLE dbo.Catalog alter column Price	double precision  not null
ALTER TABLE dbo.Catalog alter column Number	int not null
ALTER TABLE dbo.Catalog alter column Adm_no  varchar(15) not null



ALTER TABLE dbo.Reader alter column Read_no	 varchar(15) not null
ALTER TABLE dbo.Reader alter column Read_name	 varchar(15) not null
ALTER TABLE dbo.Reader alter column Read_sex	 varchar(15) not null
ALTER TABLE dbo.Reader alter column Read_dept	 varchar(15) not null
ALTER TABLE dbo.Reader alter column Email	 varchar(30) not null
ALTER TABLE dbo.Reader alter column Card_status varchar(15) not null




