'''
This script creates a table DATE_DIM with 16 columns.
It is implemented as a SQL stored procedure for SQL Server, which is executed remotely from this script.
Note that this stored procedure (uspDateDimCreation) is reusable and will be also available for you
directly in SQL Server once you run this script successfully.
In order to populate it, run uspDateDimPopulate.py script.
'''

# pyodbc library will help us to connect to SQL Server
import pyodbc

'''
# Create Connection and Cursor objects for localhost with Windows Authentication only
# Type you server name/address and database name you want to create DATE_DIM table in
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
username = '[USERNAME] 
password = '[PASSWORD]' 
conn = pyodbc.connect('DRIVER={SQL Server};SERVER=' + server + ';DATABASE=' + db + ';UID='+username+';PWD='+ password)
cursor = conn.cursor()

# First we check if uspDateDimCreation stored procedure already exists in DB. If it does, we delete it.
# Note that we create queries, but will execute them all together later.
query_drop = """

IF OBJECT_ID ('uspDateDimCreation', 'P') IS NOT NULL
    DROP PROCEDURE uspDateDimCreation;
    
"""

# Now we'll create a query which will create a DATE_DIM table with 16 rows as shown below.
query_create = """

CREATE PROCEDURE uspDateDimCreation
AS
	SET NOCOUNT ON;

	DROP TABLE IF EXISTS DATE_DIM;
	CREATE TABLE DATE_DIM
	(
		date VARCHAR(10) NOT NULL,
		year INT NOT NULL,
		month VARCHAR(16) NOT NULL,
		day INT NOT NULL,
		quarter INT NOT NULL,
		month_num INT NOT NULL,
		firstday_of_month VARCHAR(16) NOT NULL,
		lastday_of_month VARCHAR(16) NOT NULL,
		days_till_end_of_month INT NOT NULL,
		days_till_end_of_year INT NOT NULL,
		week_num INT NOT NULL,
		daynum_in_year INT NOT NULL,
		weekday VARCHAR(16) NOT NULL,
		weekday_num INT NOT NULL,
		days_ago INT NOT NULL,
		written_date VARCHAR(32) NOT NULL,
	);


"""

# This query will execute our stored procedure
query_exec = """

    EXEC uspDateDimCreation;
    
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

# Now let's check how it all works and create a query that shows us columns we've just created
query_check = """

    SELECT * FROM DATE_DIM;
    
"""

# Executing our check query
try:
    cursor.execute(query_check)
except pyodbc.Error as ex:
    sqlstate = ex.args[1]
    print(sqlstate)

# This will print out our columns
column = [column[0] for column in cursor.description]
print('The following columns were created: \n')

counter = 1
for i in column: 
    print(str(counter) + '. ' + i)
    counter = counter + 1
