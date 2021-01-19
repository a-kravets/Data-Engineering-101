IF OBJECT_ID ('uspDateDimCreation', 'P') IS NOT NULL
    DROP PROCEDURE uspDateDimCreation;
GO

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
GO

EXEC uspDateDimCreation;
GO
