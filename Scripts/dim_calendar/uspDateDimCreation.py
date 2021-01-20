'''
This script creates a table DATE_DIM with 16 columns.
It is implemented as a SQL stored procedure for SQL Server.
In order to populate it, run uspDateDimPopulate.py script.
'''

import pyodbc

server = '[SERVER NAME]'
db = '[DATABASE NAME]'

# create Connection and Cursor objects for localhost
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


query_drop = """

IF OBJECT_ID ('uspDateDimCreation', 'P') IS NOT NULL
    DROP PROCEDURE uspDateDimCreation;
    
"""

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

query_exec = """

    EXEC uspDateDimCreation;
    
"""

try:
    cursor.execute(query_drop)
    cursor.execute(query_create)
    cursor.execute(query_exec)
    conn.commit()
except pyodbc.Error as ex:
    sqlstate = ex.args[1]
    print(sqlstate)

query_check = """

    SELECT * FROM DATE_DIM;
    
"""

try:
    cursor.execute(query_check)
except pyodbc.Error as ex:
    sqlstate = ex.args[1]
    print(sqlstate)

column = [column[0] for column in cursor.description]
print('The following columns were created: \n')

counter = 1
for i in column: 
    print(str(counter) + '. ' + i)
    counter = counter + 1
