USE AdventureWorks 
GO

SET NOCOUNT ON

DROP TABLE IF EXISTS #DailySalesSummary
DROP TABLE IF EXISTS #RollingPeriodTotals
DROP TABLE IF EXISTS #RollingPeriodTotalAvgs

CREATE TABLE #DailySalesSummary
(
	SaleDate DateTime,
	DailyTotal Money
)

INSERT INTO #DailySalesSummary
SELECT 
	ModifiedDate AS SaleDate,
	SUM(LineTotal) DailyTotal
FROM
	Sales.SalesOrderDetail
GROUP BY
	ModifiedDate
ORDER BY
	ModifiedDate



CREATE TABLE #RollingPeriodTotals
(
	 SaleDate DateTime
	,ThreeDaySum Money
	,FiveDaySum Money
	,SevenDaySum Money
	,TenDaySum Money
	,FourteenDaySum Money
	,TwentyOneDaySum Money
	,TwentyEightDaySum Money
	,ThirtyDaySum Money
)

INSERT INTO #RollingPeriodTotals
SELECT SaleDate DateTime
	  ,SUM(DailyTotal) OVER(ORDER BY SaleDate ROWS BETWEEN 2  PRECEDING AND CURRENT ROW) AS ThreeDaySum
	  ,SUM(DailyTotal) OVER(ORDER BY SaleDate ROWS BETWEEN 4  PRECEDING AND CURRENT ROW) AS FiveDaySum
	  ,SUM(DailyTotal) OVER(ORDER BY SaleDate ROWS BETWEEN 6  PRECEDING AND CURRENT ROW) AS SevenDaySum
	  ,SUM(DailyTotal) OVER(ORDER BY SaleDate ROWS BETWEEN 9  PRECEDING AND CURRENT ROW) AS TenDaySum
	  ,SUM(DailyTotal) OVER(ORDER BY SaleDate ROWS BETWEEN 13 PRECEDING AND CURRENT ROW) AS FourteenDaySum
	  ,SUM(DailyTotal) OVER(ORDER BY SaleDate ROWS BETWEEN 20 PRECEDING AND CURRENT ROW) AS TwentyOneDaySum
	  ,SUM(DailyTotal) OVER(ORDER BY SaleDate ROWS BETWEEN 27 PRECEDING AND CURRENT ROW) AS TwentyEightDaySum
	  ,SUM(DailyTotal) OVER(ORDER BY SaleDate ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS ThirtyDaySum
FROM 
	#DailySalesSummary

--SELECT *
--FROM #RollingPeriodTotals



CREATE TABLE #RollingPeriodTotalAvgs
(
	 SaleDate DateTime
	,ThreeDayAvg Money
	,FiveDayAvg Money
	,SevenDayAvg Money
	,TenDayAvg Money
	,FourteenDayAvg Money
	,TwentyOneDayAvg Money
	,TwentyEightDayAvg Money
	,ThirtyDayAvg Money
)

INSERT INTO #RollingPeriodTotalAvgs
SELECT SaleDate
	,AVG(ThreeDaySum) OVER(ORDER BY SaleDate ROWS BETWEEN 2  PRECEDING AND CURRENT ROW) AS ThreeDayAvg
	,AVG(FiveDaySum) OVER(ORDER BY SaleDate ROWS BETWEEN 4  PRECEDING AND CURRENT ROW) AS FiveDayAvg
	,AVG(SevenDaySum) OVER(ORDER BY SaleDate ROWS BETWEEN 6  PRECEDING AND CURRENT ROW) AS SevenDayAvg
	,AVG(TenDaySum) OVER(ORDER BY SaleDate ROWS BETWEEN 9  PRECEDING AND CURRENT ROW) AS TenDayAvg
	,AVG(FourteenDaySum) OVER(ORDER BY SaleDate ROWS BETWEEN 13 PRECEDING AND CURRENT ROW) AS FourteenDayAvg
	,AVG(TwentyOneDaySum) OVER(ORDER BY SaleDate ROWS BETWEEN 20 PRECEDING AND CURRENT ROW) AS TwentyOneDayAvg
	,AVG(TwentyEightDaySum) OVER(ORDER BY SaleDate ROWS BETWEEN 27 PRECEDING AND CURRENT ROW) AS TwentyEightDayAvg
	,AVG(ThirtyDaySum) OVER(ORDER BY SaleDate ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS ThirtyDayAvg
FROM 
	#RollingPeriodTotals


--SELECT *
--FROM #RollingPeriodTotalAvgs



/*Final selections below*/
DELETE FROM #RollingPeriodTotalAvgs
WHERE SaleDate IN
(
	SELECT TOP (60) SaleDate
	FROM #RollingPeriodTotalAvgs 
	ORDER BY SaleDate
)


SELECT SaleDate
	,FORMAT(ThreeDayAvg, 'C') ThreeDayAvg
	,FORMAT(FiveDayAvg, 'C') FiveDayAvg
	,FORMAT(SevenDayAvg, 'C') SevenDayAvg
	,FORMAT(TenDayAvg, 'C') TenDayAvg
	,FORMAT(FourteenDayAvg, 'C') FourteenDayAvg
	,FORMAT(TwentyOneDayAvg, 'C') TwentyOneDayAvg
	,FORMAT(TwentyEightDayAvg, 'C') TwentyEightDayAvg
	,FORMAT(ThirtyDayAvg, 'C') ThirtyDayAvg
FROM
	#RollingPeriodTotalAvgs


SELECT SaleDate
		,ThreeDayAvg
		,PERCENT_RANK() OVER (ORDER BY ThreeDayAvg) AS ThreeDayAvgTotalPctRank
FROM #RollingPeriodTotalAvgs
ORDER BY ThreeDayAvg




/*testing a massive pivot for fun*/
--DECLARE @PivotColumns AS NVARCHAR(MAX)
--DECLARE @PivotTableCols AS NVARCHAR(MAX)
--DECLARE @PivotQuery AS NVARCHAR(MAX)
--SELECT @PivotColumns = COALESCE(@PivotColumns + ',','') + QUOTENAME(SaleDate) FROM #RollingPeriodTotalAvgs
--SELECT @PivotTableCols = COALESCE(@PivotTableCols + ',','') + QUOTENAME(SaleDate) + ' money' FROM #RollingPeriodTotalAvgs
--SET @PivotQuery = N'
----CREATE TABLE #PivotedRollingPeriodTotalAvgs
----(
----	 TimeFrame NVARCHAR(MAX),'+@PivotTableCols+' 
----)
----INSERT INTO #PivotedRollingPeriodTotalAvgs






--SELECT TimeFrame,'+@PivotColumns+'
--FROM (SELECT ''3 Day Running Avg'' AS ''TimeFrame'',ThreeDayAvg,SaleDate
--		FROM #RollingPeriodTotalAvgs) x
--PIVOT (MAX(ThreeDayAvg) FOR SaleDate IN ('+@PivotColumns+')) pvt

--UNION ALL

--SELECT TimeFrame,'+@PivotColumns+'
--FROM (SELECT ''5 Day Running Avg'' AS ''TimeFrame'',FiveDayAvg,SaleDate
--		FROM #RollingPeriodTotalAvgs) x
--PIVOT (MAX(FiveDayAvg) FOR SaleDate IN ('+@PivotColumns+')) pvt

--UNION ALL

--SELECT TimeFrame,'+@PivotColumns+'
--FROM (SELECT ''7 Day Running Avg'' AS ''TimeFrame'',SevenDayAvg,SaleDate
--		FROM #RollingPeriodTotalAvgs) x
--PIVOT (MAX(SevenDayAvg) FOR SaleDate IN ('+@PivotColumns+')) pvt

--UNION ALL

--SELECT TimeFrame,'+@PivotColumns+'
--FROM (SELECT ''10 Day Running Avg'' AS ''TimeFrame'',TenDayAvg,SaleDate
--		FROM #RollingPeriodTotalAvgs) x
--PIVOT (MAX(TenDayAvg) FOR SaleDate IN ('+@PivotColumns+')) pvt

--UNION ALL

--SELECT TimeFrame,'+@PivotColumns+'
--FROM (SELECT ''14 Day Running Avg'' AS ''TimeFrame'',FourteenDayAvg,SaleDate
--		FROM #RollingPeriodTotalAvgs) x
--PIVOT (MAX(FourteenDayAvg) FOR SaleDate IN ('+@PivotColumns+')) pvt

--UNION ALL

--SELECT TimeFrame,'+@PivotColumns+'
--FROM (SELECT ''21 Day Running Avg'' AS ''TimeFrame'',TwentyOneDayAvg,SaleDate
--		FROM #RollingPeriodTotalAvgs) x
--PIVOT (MAX(TwentyOneDayAvg) FOR SaleDate IN ('+@PivotColumns+')) pvt

--UNION ALL

--SELECT TimeFrame,'+@PivotColumns+'
--FROM (SELECT ''28 Day Running Avg'' AS ''TimeFrame'',TwentyEightDayAvg,SaleDate
--		FROM #RollingPeriodTotalAvgs) x
--PIVOT (MAX(TwentyEightDayAvg) FOR SaleDate IN ('+@PivotColumns+')) pvt

--UNION ALL

--SELECT TimeFrame,'+@PivotColumns+'
--FROM (SELECT ''30 Day Running Avg'' AS ''TimeFrame'',ThirtyDayAvg,SaleDate
--		FROM #RollingPeriodTotalAvgs) x
--PIVOT (MAX(ThirtyDayAvg) FOR SaleDate IN ('+@PivotColumns+')) pvt

----SELECT * FROM #PivotedRollingPeriodTotalAvgs
--'

--EXEC sp_executesql @PivotQuery






--CALCULATE PERCENTILES
SELECT 'ThreeDayAvg PERCENTILE_CONT' AS 'TimeFrame'	
,[25th Percentile]  = FORMAT(MAX([25th Percentile]),'C')
    ,[50th Percentile]  = FORMAT(MAX([50th Percentile]),'C')
    ,[75th Percentile]  = FORMAT(MAX([75th Percentile]),'C')
    ,[100th Percentile] = FORMAT(MAX([100th Percentile]),'C') 
FROM
(
    SELECT [25th Percentile]  = PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY ThreeDayAvg) OVER ()
          ,[50th Percentile]  = PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY ThreeDayAvg) OVER ()
          ,[75th Percentile]  = PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ThreeDayAvg) OVER ()
          ,[100th Percentile] = PERCENTILE_CONT(1.00) WITHIN GROUP (ORDER BY ThreeDayAvg) OVER ()
    FROM #RollingPeriodTotalAvgs
) x
UNION ALL
SELECT 'FiveDayAvg PERCENTILE_CONT' AS 'TimeFrame'	
,[25th Percentile]  = FORMAT(MAX([25th Percentile]),'C')
    ,[50th Percentile]  = FORMAT(MAX([50th Percentile]),'C')
    ,[75th Percentile]  = FORMAT(MAX([75th Percentile]),'C')
    ,[100th Percentile] = FORMAT(MAX([100th Percentile]),'C') 
FROM
(
    SELECT [25th Percentile]  = PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY FiveDayAvg) OVER ()
          ,[50th Percentile]  = PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY FiveDayAvg) OVER ()
          ,[75th Percentile]  = PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY FiveDayAvg) OVER ()
          ,[100th Percentile] = PERCENTILE_CONT(1.00) WITHIN GROUP (ORDER BY FiveDayAvg) OVER ()
    FROM #RollingPeriodTotalAvgs
) x
UNION ALL
SELECT 'SevenDayAvg PERCENTILE_CONT' AS 'TimeFrame'	
,[25th Percentile]  = FORMAT(MAX([25th Percentile]),'C')
    ,[50th Percentile]  = FORMAT(MAX([50th Percentile]),'C')
    ,[75th Percentile]  = FORMAT(MAX([75th Percentile]),'C')
    ,[100th Percentile] = FORMAT(MAX([100th Percentile]),'C') 
FROM
(
    SELECT [25th Percentile]  = PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY SevenDayAvg) OVER ()
          ,[50th Percentile]  = PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY SevenDayAvg) OVER ()
          ,[75th Percentile]  = PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY SevenDayAvg) OVER ()
          ,[100th Percentile] = PERCENTILE_CONT(1.00) WITHIN GROUP (ORDER BY SevenDayAvg) OVER ()
    FROM #RollingPeriodTotalAvgs
) x
UNION ALL
SELECT 'TenDayAvg PERCENTILE_CONT' AS 'TimeFrame'	
,[25th Percentile]  = FORMAT(MAX([25th Percentile]),'C')
    ,[50th Percentile]  = FORMAT(MAX([50th Percentile]),'C')
    ,[75th Percentile]  = FORMAT(MAX([75th Percentile]),'C')
    ,[100th Percentile] = FORMAT(MAX([100th Percentile]),'C') 
FROM
(
    SELECT [25th Percentile]  = PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY TenDayAvg) OVER ()
          ,[50th Percentile]  = PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY TenDayAvg) OVER ()
          ,[75th Percentile]  = PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY TenDayAvg) OVER ()
          ,[100th Percentile] = PERCENTILE_CONT(1.00) WITHIN GROUP (ORDER BY TenDayAvg) OVER ()
    FROM #RollingPeriodTotalAvgs
) x
UNION ALL
SELECT 'FourteenDayAvg PERCENTILE_CONT' AS 'TimeFrame'	
,[25th Percentile]  = FORMAT(MAX([25th Percentile]),'C')
    ,[50th Percentile]  = FORMAT(MAX([50th Percentile]),'C')
    ,[75th Percentile]  = FORMAT(MAX([75th Percentile]),'C')
    ,[100th Percentile] = FORMAT(MAX([100th Percentile]),'C') 
FROM
(
    SELECT [25th Percentile]  = PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY FourteenDayAvg) OVER ()
          ,[50th Percentile]  = PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY FourteenDayAvg) OVER ()
          ,[75th Percentile]  = PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY FourteenDayAvg) OVER ()
          ,[100th Percentile] = PERCENTILE_CONT(1.00) WITHIN GROUP (ORDER BY FourteenDayAvg) OVER ()
    FROM #RollingPeriodTotalAvgs
) x
UNION ALL
SELECT 'TwentyOneDayAvg PERCENTILE_CONT' AS 'TimeFrame'	
,[25th Percentile]  = FORMAT(MAX([25th Percentile]),'C')
    ,[50th Percentile]  = FORMAT(MAX([50th Percentile]),'C')
    ,[75th Percentile]  = FORMAT(MAX([75th Percentile]),'C')
    ,[100th Percentile] = FORMAT(MAX([100th Percentile]),'C') 
FROM
(
    SELECT [25th Percentile]  = PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY TwentyOneDayAvg) OVER ()
          ,[50th Percentile]  = PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY TwentyOneDayAvg) OVER ()
          ,[75th Percentile]  = PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY TwentyOneDayAvg) OVER ()
          ,[100th Percentile] = PERCENTILE_CONT(1.00) WITHIN GROUP (ORDER BY TwentyOneDayAvg) OVER ()
    FROM #RollingPeriodTotalAvgs
) x
UNION ALL
SELECT 'TwentyEightDayAvg PERCENTILE_CONT' AS 'TimeFrame'	
,[25th Percentile]  = FORMAT(MAX([25th Percentile]),'C')
    ,[50th Percentile]  = FORMAT(MAX([50th Percentile]),'C')
    ,[75th Percentile]  = FORMAT(MAX([75th Percentile]),'C')
    ,[100th Percentile] = FORMAT(MAX([100th Percentile]),'C') 
FROM
(    SELECT [25th Percentile]  = PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY TwentyEightDayAvg) OVER ()
           ,[50th Percentile]  = PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY TwentyEightDayAvg) OVER ()
           ,[75th Percentile]  = PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY TwentyEightDayAvg) OVER ()
           ,[100th Percentile] = PERCENTILE_CONT(1.00) WITHIN GROUP (ORDER BY TwentyEightDayAvg) OVER ()
    FROM #RollingPeriodTotalAvgs
) x
UNION ALL
SELECT 'ThirtyDayAvg PERCENTILE_CONT' AS 'TimeFrame'	
,[25th Percentile]  = FORMAT(MAX([25th Percentile]),'C')
    ,[50th Percentile]  = FORMAT(MAX([50th Percentile]),'C')
    ,[75th Percentile]  = FORMAT(MAX([75th Percentile]),'C')
    ,[100th Percentile] = FORMAT(MAX([100th Percentile]),'C') 
FROM
(
    SELECT [25th Percentile]  = PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY ThirtyDayAvg) OVER ()
		  ,[50th Percentile]  = PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY ThirtyDayAvg) OVER ()
          ,[75th Percentile]  = PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ThirtyDayAvg) OVER ()
          ,[100th Percentile] = PERCENTILE_CONT(1.00) WITHIN GROUP (ORDER BY ThirtyDayAvg) OVER ()
    FROM #RollingPeriodTotalAvgs
) x






SELECT FORMAT(MIN(ThreeDayAvg),'C') MinThreeDayTotalAvg
	  ,FORMAT(MIN(FiveDayAvg),'C') MinFiveDayTotalAvg
	  ,FORMAT(MIN(SevenDayAvg),'C') MinSevenDayTotalAvg
	  ,FORMAT(MIN(TenDayAvg),'C') MinTenDayTotalAvg
	  ,FORMAT(MIN(FourteenDayAvg),'C') MinFourteenDayTotalAvg
	  ,FORMAT(MIN(TwentyOneDayAvg),'C') MinTwentyOneDayTotalAvg
	  ,FORMAT(MIN(TwentyEightDayAvg),'C') MinTwentyEightDayTotalAvg
	  ,FORMAT(MIN(ThirtyDayAvg),'C') MinThirtyDayTotalAvg
FROM
	#RollingPeriodTotalAvgs

