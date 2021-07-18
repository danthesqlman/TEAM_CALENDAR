USE FOO;
GO
SET NOCOUNT ON
IF EXISTS ( SELECT 1 FROM SYS.TABLES WHERE NAME = 'CALENDAR')
BEGIN
	DROP TABLE DBO.[CALENDAR]
END
GO
CREATE TABLE [CALENDAR]
(
	THEDATE DATE  PRIMARY KEY,
	THEDAY TINYINT NOT NULL,
	THEDAYNAME CHAR(9) NOT NULL,
	THEWEEKNUM TINYINT NOT NULL,
	THEISOWEEKNUM TINYINT NOT NULL,
	THEDAYOFWEEK TINYINT NOT NULL,
	THEMONTHNUM TINYINT NOT NULL,
	THEMONTHNAME VARCHAR(9) NOT NULL,
	THEQUARTER TINYINT NOT NULL,
	THEYEAR SMALLINT NOT NULL,
	THEFIRSTOFMONTH DATE NOT NULL,
	THELASTOFYEAR DATE NOT NULL,
	THEDAYOFYEAR SMALLINT NOT NULL,
	GROUPNUMBER SMALLINT NULL,
	ISHOLIDAY BIT DEFAULT CAST(0 AS BIT)
)
	   



GO

CREATE OR ALTER PROCEDURE POPULATE_CALENDAR @STARTDATE DATE
AS 
/*
	EXEC DBO.POPULATE_CALENDAR '2021-10-01'
	CODE 'STOLEN' FROM AARON BERTRAND
	https://www.mssqltips.com/sqlservertip/4054/creating-a-date-dimension-or-calendar-table-in-sql-server/
*/
BEGIN
DECLARE @NUMBEROFYEARS INT = 10


		DECLARE @CutoffDate date = DATEADD(DAY, -1, DATEADD(YEAR, @NUMBEROFYEARS, @StartDate));
		SET DATEFIRST 1;
		;WITH seq(n) AS 
		(
		  SELECT 0 UNION ALL SELECT n + 1 FROM seq
		  WHERE n < DATEDIFF(DAY, @StartDate, @CutoffDate)
		),
		d(d) AS 
		(
		  SELECT DATEADD(DAY, n, @StartDate) FROM seq
		),
		src AS
		(
		  SELECT
			TheDate         = CONVERT(date, d),
			TheDay          = DATEPART(DAY,       d),
			TheDayName      = DATENAME(WEEKDAY,   d),
			TheWeek         = DATEPART(WEEK,      d),
			TheISOWeek      = DATEPART(ISO_WEEK,  d),
			TheDayOfWeek    = DATEPART(WEEKDAY,   d),
			TheMonth        = DATEPART(MONTH,     d),
			TheMonthName    = DATENAME(MONTH,     d),
			TheQuarter      = DATEPART(Quarter,   d),
			TheYear         = DATEPART(YEAR,      d),
			TheFirstOfMonth = DATEFROMPARTS(YEAR(d), MONTH(d), 1),
			TheLastOfYear   = DATEFROMPARTS(YEAR(d), 12, 31),
			TheDayOfYear    = DATEPART(DAYOFYEAR, d)
		  FROM d
		)
		INSERT INTO DBO.CALENDAR(
		TheDate         
		,TheDay          
		,TheDayName      
		,TheWeekNUM         
		,TheISOWeekNUM      
		,TheDayOfWeek    
		,TheMonthNUM        
		,TheMonthName    
		,TheQuarter      
		,TheYear         
		,TheFirstOfMonth 
		,TheLastOfYear   
		,TheDayOfYear    
		)

		SELECT 
		TheDate         
		,TheDay          
		,TheDayName      
		,TheWeek         
		,TheISOWeek      
		,TheDayOfWeek    
		,TheMonth        
		,TheMonthName    
		,TheQuarter      
		,TheYear         
		,TheFirstOfMonth 
		,TheLastOfYear   
		,TheDayOfYear    	
		
		FROM src
		  ORDER BY TheDate
		  OPTION (MAXRECURSION 0);
END
GO

		EXEC DBO.POPULATE_CALENDAR '2021-01-01'

