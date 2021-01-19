IF OBJECT_ID ('uspDateDimPopulate', 'P') IS NOT NULL
    DROP PROCEDURE uspDateDimPopulate;
GO

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

GO

EXEC uspDateDimPopulate '20200101', '20201231';
GO