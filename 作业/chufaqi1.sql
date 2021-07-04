alter trigger Tri_InsterBorrow on dbo.Borrow for
insert as
select *
from inserted i
where 1 = 1 print('test') begin if (1 = 1) begin rollback
end
end
go
insert into dbo.Borrow
values (
        '81099',
        'B1300945',
        '2020-03-14 00:00:00.000',
        '2020-12-14 00:00:00.000',
        NULL,
        1
    ) delete dbo.Borrow
where '81099' = Read_no