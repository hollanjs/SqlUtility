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



/*Final selections below - get max*/
DELETE FROM #RollingPeriodTotalAvgs
WHERE SaleDate IN
(
	SELECT TOP (60) SaleDate
	FROM #RollingPeriodTotalAvgs 
	ORDER BY SaleDate
)

SELECT MAX(ThreeDayAvg) MaxThreeDayTotalAvg
	  ,MAX(FiveDayAvg) MaxFiveDayTotalAvg
	  ,MAX(SevenDayAvg) MaxSevenDayTotalAvg
	  ,MAX(TenDayAvg) MaxTenDayTotalAvg
	  ,MAX(FourteenDayAvg) MaxFourteenDayTotalAvg
	  ,MAX(TwentyOneDayAvg) MaxTwentyOneDayTotalAvg
	  ,MAX(TwentyEightDayAvg) MaxTwentyEightDayTotalAvg
	  ,MAX(ThirtyDayAvg) MaxThirtyDayTotalAvg
FROM
	#RollingPeriodTotalAvgs

