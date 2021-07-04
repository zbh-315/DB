--  1. 用系统内置的存储过程sp_addumpdevice创建一个备份设备SalesDatabase_Bak，保存在D盘根目录下，查看系统中有哪些备份设备。
exec sp_addumpdevice 'disk', 'SalesDatabase_Bak', 'D:\workspace\ALL\数据库\实验\DBdata\Sale_bak'
exec sp_helpdevice


-- 2. 为销售管理数据库设置一个备份计划，名为SaleBackPlan，要求每天在上午 12:00:00 和下午 12:00:00 之间每2小时执行数据库日志备份。


--3.  新建一个数据库Sa1es1，使用DTS向导将前面已建的Sales数据库中的所有表导入到Sales1数据库中。要求不立即运行，而是创建一个Sales备份包，然后再执行运行。

--4．管理员对数据库执行了一次完整备份和多次日志备份，并且备份文件保持良好。某天数据文件遭到破坏，管理员需要尽快恢复数据。验证数据是否和破坏前一致，自已给出测试数据。







