
# INTRODUCTION

**What?** Reusable solution which can be applied across all databases used in our department and integrated to our CI/CD pipelines. This solution should create a table called DATE_DIM (so called calendar dimension) for data analysis purposes and populate it with data.
**Grain:** 1 day
**Database:** SQL Server
**Technical details:** solution was split into 2 parts.

* 1 part: First script creates a table DATE_DIM with 16 columns. It is implemented as a SQL stored procedure for SQL Server, which is executed remotely from Python script. Note that this stored procedure (`uspDateDimCreation`) is reusable and will be also available for you directly in SQL Server once you run this script successfully. In order to populate it, run the second script.

* 2 part: Second script populates a table DATE_DIM with 16 columns, which was created by previous script. It is implemented as a SQL stored procedure for SQL Server, which is executed remotely from this script. Note that this stored procedure (`uspDateDimCreation`) is reusable and will be also available for you directly in SQL Server once you run this script successfully.
