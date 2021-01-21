
# INTRODUCTION

**What?** Reusable solution which can be applied across all databases used in our department and integrated to our CI/CD pipelines. This solution should create a table called DATE_DIM (so called calendar dimension) for data analysis purposes and populate it with data. Everything is done remotely, running few Python scripts.

**Grain:** 1 day

**Database:** SQL Server

**Technical details:** solution was split into 2 parts.


* 1 part: First script creates a table DATE_DIM with 16 columns. It is implemented as a SQL stored procedure for SQL Server, which is executed remotely from Python script. Note that this stored procedure (`uspDateDimCreation`) is reusable and will be also available for you directly in SQL Server once you run this script successfully. In order to populate it, run the second script.

* 2 part: Second script populates a table DATE_DIM with 16 columns, which was created by previous script. It is implemented as a SQL stored procedure for SQL Server, which is executed remotely from this script. Note that this stored procedure (`uspDateDimPopulate`) is reusable and will be also available for you directly in SQL Server once you run this script successfully.

# FILES

* `uspDateDimCreation.py` is a Python script which creates a table DATE_DIM with 16 columns
* `uspDateDimPopulate.py` is a Python script populates a table DATE_DIM
* `uspDateDimCreation.sql` is a SQL source script which creates a table DATE_DIM with 16 columns (used in `uspDateDimCreation.py`)
* `uspDateDimPopulate.sql` is a SQL source script which populates a table DATE_DIM (used in `uspDateDimPopulate.py`)
* `CreateLoginUserPermission.sql` is script that creates login and user for accessing SQL Server remotely


# IMPLEMENTATION

## Database Access & Permissions

First thing first. In order to implement this solution you need to have access, credentials and permissions for the database you want to work with. <ins>If you have those, you may skip this step and jump to the next one</ins>.

The script below creates login and user for accessing SQL Server remotely (you may find it in the file called `CreateLoginUserPermission.sql`:

```sql
--Change 'DATABASE_NAME' to a db you want new login/user have access to
USE [DATABASE_NAME]

--Change 'AdminUser' to your preferred login/user name and do the same with 'PASSWORD'
--Once it's done and you run this script, you may use these credentials to access the db
CREATE LOGIN AdminUser WITH PASSWORD = 'PASSWORD';
CREATE USER AdminUser FROM LOGIN AdminUser; 

--This stored procedure grans permissions as db owner
--Don't forget to change 'AdminUser' to the one you've written above (if you did)
EXEC sp_addrolemember N'db_owner', N'AdminUser'
```

You need to run this script inside SQL Server in the database you want to get access to.

## Let's Create a Table

Now we may create a DATE_DIM table. In order to do so, we'll run our first Python script (you may find it in file called `uspDateDimCreation.py`).

Before running this script we need to enter our credentials to access our target database (username and password), as well as server and database name.

```python
server = '[SERVER NAME]'
db = '[DATABASE NAME]'
username = '[USERNAME] 
password = '[PASSWORD]' 
```

You may find server name in the login window when you're connecting to your SQL Server as shown below:

![Server name](https://github.com/a-kravets/Data-Engineering-101/blob/master/Scripts/dim_calendar/server_name.PNG)

As to database name, it's just a name of the database you want to get access to, which you may find in Object Explorer window in your DBMS (for example AdventureWorks2017 as shown below).

![Database name](https://github.com/a-kravets/Data-Engineering-101/blob/master/Scripts/dim_calendar/dbname.PNG)
