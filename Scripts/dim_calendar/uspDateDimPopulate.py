'''
This script populates a table DATE_DIM with 16 columns, which was created by uspDateDimCreation.py script.
It is implemented as a SQL stored procedure for SQL Server, which is executed remotely from this script.
Note that this stored procedure (uspDateDimCreation) is reusable and will be also available for you
directly in SQL Server once you run this script successfully.
'''

# pyodbc library will help us to connect to SQL Server
import pyodbc

# type you server name/address and database name you want to create DATE_DIM table in
server = '[SERVER NAME]'
db = '[DATABASE NAME]'

# create Connection and Cursor objects for localhost
# Note that you may have other DRIVER, for example 'DRIVER={ODBC Driver 17 for SQL Server}'
# If this script raises connection error, check what it says and try to write other driver you have at your PC
conn = pyodbc.connect('DRIVER={SQL Server};SERVER=' + server + ';DATABASE=' + db + ';Trusted_Connection=yes')
cursor = conn.cursor()

'''
# create Connection and Cursor objects for server not in localhost
server = '[SERVER NAME]'
db = '[DATABASE NAME]'
username = '[myusername]' 
password = '[mypassword]' 
cursor = pyodbc.connect('DRIVER={SQL Server};SERVER=' + server + ';DATABASE=' + db + ';UID='+username+';PWD='+ password)
'''

# First we check if uspDateDimPopulate stored procedure already exists in DB. If it does, we delete it.
# Note that we create queries, but will execute them all together later.
query_drop = """

IF OBJECT_ID ('uspDateDimPopulate', 'P') IS NOT NULL
    DROP PROCEDURE uspDateDimPopulate;
    
"""

# Now we'll create a query which will populate our columns in DATE_DIM table with 16 rows as shown below.
query_create = """

CREATE PROCEDURE uspDateDimPopulate
	@StartDate date,
	@EndDate date
AS
	SET NOCOUNT ON;

	--DECLARE @StartDate date = '20200101';
	--DECLARE @EndDate date = '20201231';

	WITH CTE_SEQUENCE(n) AS 
	(
	  SELECT 0 UNION ALL SELECT n + 1 FROM CTE_SEQUENCE
	  WHERE n < DATEDIFF(DAY, @StartDate, @EndDate)
	),

	CTE_DAYS(d) AS 
	(
	  SELECT DATEADD(DAY, n, @StartDate) FROM CTE_SEQUENCE
	),

	CTE_POPULATE AS
	(
	  SELECT
		CONVERT(VARCHAR, d, 101) AS date,
		DATEPART(YEAR, d) AS year,
		DATENAME(MONTH, d) AS month,
		DATEPART(DAY, d) AS day,
		DATEPART(Quarter, d) AS quarter,
		DATEPART(MONTH, d) AS month_num,
		DATEFROMPARTS(YEAR(d),MONTH(d),1) AS firstday_of_month,
		EOMONTH(d) AS lastday_of_month,
		DATEDIFF(DAY, DATEPART(DAY, EOMONTH(d)), DATEPART(DAY, d)) * (-1) AS days_till_end_of_month,
		DATEDIFF(DAY, DATEFROMPARTS(YEAR(d),12,31), d) * (-1) AS days_till_end_of_year,
		DATEPART(WEEK, d) AS week_num,
		DATEPART(DY, d) AS daynum_in_year,
		DATENAME(WEEKDAY, d) AS weekday,
		DATEPART(WEEKDAY, d) AS weekday_num,
		DATEDIFF(d, d, GETDATE()) AS days_ago,
		CONCAT(DATENAME(MONTH, d), ' ', DATEPART(DAY, d), ',', ' ', DATEPART(YEAR, d)) AS written_date

	  FROM CTE_DAYS
	)

	INSERT INTO DATE_DIM
	SELECT * FROM CTE_POPULATE
	OPTION (MAXRECURSION 0);


"""

# This query will execute our stored procedure
query_exec = """

    EXEC uspDateDimPopulate '20200101', '20201231';
    
"""

# Since we've created all three queries we need, we may execute them
try:
    cursor.execute(query_drop)
    cursor.execute(query_create)
    cursor.execute(query_exec)
    conn.commit()
except pyodbc.Error as ex:
    sqlstate = ex.args[1]
    print(sqlstate)

# Now let's check how it all works and create a query that shows us one row from the table we've populated
query_check = """

    SELECT TOP 1 * FROM DATE_DIM;
    
"""

# Executing our check query
try:
    cursor.execute(query_check)
except pyodbc.Error as ex:
    sqlstate = ex.args[1]
    print(sqlstate)

column = [column[0] for column in cursor.description]

# This will print out one row
print("Here's a sample of data we've just populated our table with: \n")
for row in cursor.fetchall():
    counter = 0
    for i in column: 
        print(str(counter+1) + '. ' + i + ': ' + str(row[counter]))
        counter = counter + 1
