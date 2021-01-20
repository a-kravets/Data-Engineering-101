--The script below creates login and user for accessing SQL Server remotely

--Change 'AdventureWorks2019_Kravets' to a db you want new login/user have access to
USE [AdventureWorks2019_Kravets]

--Change 'AdminUser' to your preferred login/user name and do the same with password
--Once it's done and you run this script, you may use these credentials to access the db
CREATE LOGIN AdminUser WITH PASSWORD = '@340$Uuxwp7Mcxo7Khy';
CREATE USER AdminUser FROM LOGIN AdminUser; 

--This stored procedure grans permissions as db owner
EXEC sp_addrolemember N'db_owner', N'AdminUser'