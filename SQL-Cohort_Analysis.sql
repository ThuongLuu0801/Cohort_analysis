
-- CREATE TABLE INCLUDING CUSTOMER TIER

CREATE TABLE CuzTier(Tier int,
				     Lower_value int,
					 Upper_value int)
-- UPDATE VALUE TO CUSTOMER TIER
INSERT INTO CuzTier
VALUES (3,0,200),(2,200,1000),(1,1000,100000)

SELECT * FROM CuzTier

-- Calculating number of new cuz by tier and by month-year

SELECT first_year,
	   first_month,
	   MAX(CASE WHEN tier = 1 THEN Newcuz ELSE 0 END) AS NewCuz_Tier1,
	   MAX(CASE WHEN tier = 2 THEN Newcuz ELSE 0 END) AS NewCuz_Tier2,
	   MAX(CASE WHEN tier = 3 THEN Newcuz ELSE 0 END) AS NewCuz_Tier3
FROM
(
SELECT SubQ1.first_year,
	   SubQ1.first_month,
	   SubQ1.trans_month,
	   SubQ2.Tier,
	  COUNT(DISTINCT SubQ1.CustomerID) AS NewCuz
	FROM
	(
		SELECT A.CustomerID,
			   MONTH(B.first_date) AS first_month,
			   YEAR(B.first_date) AS first_year,
			   A.trans_year,
			   A.trans_month,
			   A.rev
		FROM
		(
			(
			SELECT CustomerID,
				   YEAR(TransDate) AS trans_year,
				   MONTH(transDate) AS trans_month,
				   SUM(Amount) AS rev
			FROM SampleData
			GROUP BY CustomerID,YEAR(TransDate),MONTH(transDate)
			) A
			INNER JOIN
			(
			SELECT CustomerID,
				   MIN(Transdate) AS first_date
			FROM SampleData
			GROUP BY CustomerID
			) B
			ON A.CustomerID = B.customerID
		)
	) SubQ1
	INNER JOIN CuzTier SubQ2
	ON SubQ1.rev >= SubQ2.Lower_value AND SubQ1.rev < SubQ2.Upper_value -- NOT USING BETWEEN SINCE it includes lower and upper value
	GROUP BY first_year,first_month,SubQ2.Tier,SubQ1.trans_month
	HAVING first_month = trans_month
) SubQ2
GROUP BY first_year,first_month

-- Creating procedure to show new cuz by tier

ALTER PROCEDURE GetNewCuz_byTier
				 (@tier1 int,
				  @Lower_value1 int,
				  @Upper_value1 int,
				  @tier2 int,
				  @lower_value2 int,
				  @upper_value2 int,
				  @tier3 int,
				  @lower_value3 int,
				  @upper_value3 int)
AS
CREATE TABLE Cuz_ValRange (Tier int,Lower_value int, Upper_value int)
INSERT INTO Cuz_ValRange
VALUES(@tier1,@lower_value1,@Upper_value1),(@tier2,@lower_value2,@upper_value2),(@tier3,@lower_value3,@upper_value3)


IF OBJECT_ID(N'dbo.Cuz_ValRange',N'U') IS NOT NULL
DROP TABLE Cuz_ValRange
EXEC GetNewCuz_byTier 3,0,200,2,200,1000,1,1000,100000
SELECT * FROM Cuz_ValRange

-- THEN CALCULATING NUMBER OF NEW CUZ BASED ON TIER (USING PROC)


SELECT first_year,
	   first_month,
	   MAX(CASE WHEN tier = 1 THEN Newcuz ELSE 0 END) AS NewCuz_Tier1,
	   MAX(CASE WHEN tier = 2 THEN Newcuz ELSE 0 END) AS NewCuz_Tier2,
	   MAX(CASE WHEN tier = 3 THEN Newcuz ELSE 0 END) AS NewCuz_Tier3
FROM
(
SELECT SubQ1.first_year,
	   SubQ1.first_month,
	   SubQ1.trans_month,
	   SubQ2.Tier,
	  COUNT(DISTINCT SubQ1.CustomerID) AS NewCuz
	FROM
	(
		SELECT A.CustomerID,
			   MONTH(B.first_date) AS first_month,
			   YEAR(B.first_date) AS first_year,
			   A.trans_year,
			   A.trans_month,
			   A.rev
		FROM
		(
			(
			SELECT CustomerID,
				   YEAR(TransDate) AS trans_year,
				   MONTH(transDate) AS trans_month,
				   SUM(Amount) AS rev
			FROM SampleData
			GROUP BY CustomerID,YEAR(TransDate),MONTH(transDate)
			) A
			INNER JOIN
			(
			SELECT CustomerID,
				   MIN(Transdate) AS first_date
			FROM SampleData
			GROUP BY CustomerID
			) B
			ON A.CustomerID = B.customerID
		)
	) SubQ1
	INNER JOIN Cuz_ValRange SubQ2
	ON SubQ1.rev >= SubQ2.Lower_value AND SubQ1.rev < SubQ2.Upper_value -- NOT USING BETWEEN SINCE it includes lower and upper value
	GROUP BY first_year,first_month,SubQ2.Tier,SubQ1.trans_month
	HAVING first_month = trans_month
) SubQ2
GROUP BY first_year,first_month


-- Calculating rev of new cuz by tier and by month-year
SELECT first_year,
	   first_month,
	   MAX(CASE WHEN tier = 1 THEN Newcuz ELSE 0 END) AS NewCuz_Tier1,
	   MAX(CASE WHEN tier = 2 THEN Newcuz ELSE 0 END) AS NewCuz_Tier2,
	   MAX(CASE WHEN tier = 3 THEN Newcuz ELSE 0 END) AS NewCuz_Tier3,
	   MAX(CASE WHEN tier = 1 THEN Newrev ELSE 0 END) AS NewRev_tier1,
	   MAX(CASE WHEN tier = 2 THEN Newrev ELSE 0 END) AS NewRev_tier2,
	   MAX(CASE WHEN tier = 3 THEN Newrev ELSE 0 END) AS NewRev_tier3
FROM
(
	SELECT SubQ1.first_year,
	       SubQ1.first_month,
		   SubQ1.trans_year,
		   SubQ1.trans_month,
		   SubQ2.Tier,
		   COUNT(DISTINCT SubQ1.CustomerID) AS Newcuz,
		   SUM(SubQ1.rev) AS Newrev
	FROM
	 (
		SELECT A.CustomerID,
			   A.trans_year,
			   A.trans_month,
			   A.rev,
			   MONTH(B.first_date) AS first_month,
			   YEAR (B.first_Date) AS first_year

		FROM
			(
			SELECT CustomerID,
				   YEAR(TransDate) AS trans_year,
				   MONTH(transDate) AS trans_month,
				   SUM(Amount) AS rev
			FROM SampleData
			GROUP BY CustomerID,YEAR(TransDate),MONTH(transDate)
			) A
			INNER JOIN
			(
			SELECT CustomerID,
				   MIN(Transdate) AS first_date
			FROM SampleData
			GROUP BY CustomerID
			) B
			ON A.CustomerID = B.customerID
	  )SubQ1
	INNER JOIN Cuz_Valrange SubQ2
	ON SubQ1.rev >= SubQ2.Lower_value AND SubQ1.rev < SubQ2.Upper_value
	GROUP BY SubQ1.first_year,SubQ1.first_month,SubQ1.trans_year,
		   SubQ1.trans_month,SubQ2.Tier
	HAVING SubQ1.first_year = SubQ1.trans_year
     AND   SubQ1.first_month = SubQ1.trans_month
) SubQT
GROUP BY first_year, first_month
	       
-- Cohort Analysis badsed on tier and time-based (month)

CREATE PROCEDURE GetCohort_ByTier (@Tier int)
AS

SELECT first_year,
       first_month,
	   Tier,
	   Period,
	   COUNT(DISTINCT CustomerID) AS NewCuz,
	   SUM(Rev) AS NewRev,
	   SUM(Orders) AS NewOrders
FROM
(
	SELECT SubQ1.CustomerID,
		   SubQ1.first_year,
		   SubQ1.first_month,
		   SubQ1.trans_year,
		   SubQ1.trans_month,
		   SubQ1.rev,
		   SubQ1.orders,
		   SubQ2.Tier,
		   DATEDIFF(MONTH,DATEFROMPARTS(first_year,first_month,1),DATEFROMPARTS(trans_year,trans_month,1)) AS Period
	FROM
		 (
			SELECT A.CustomerID,
				   A.trans_year,
				   A.trans_month,
				   A.rev,
				   A.orders,
				   MONTH(B.first_date) AS first_month,
				   YEAR (B.first_Date) AS first_year

			FROM
				(
				SELECT CustomerID,
					   YEAR(TransDate) AS trans_year,
					   MONTH(transDate) AS trans_month,
					   SUM(Amount) AS rev,
					   COUNT(TransDate) AS Orders
				FROM SampleData
				GROUP BY CustomerID,YEAR(TransDate),MONTH(transDate)
				) A
				INNER JOIN
				(
				SELECT CustomerID,
					   MIN(Transdate) AS first_date
				FROM SampleData
				GROUP BY CustomerID
				) B
				ON A.CustomerID = B.customerID
		  )SubQ1
		INNER JOIN Cuz_Valrange SubQ2
		ON SubQ1.rev >= SubQ2.Lower_value AND SubQ1.rev < SubQ2.Upper_value
) SubQ
GROUP BY first_year,first_month,Tier,Period
HAVING Tier = @Tier

--USING PROC TO MAKE cohort analysis


IF OBJECT_ID(N'tempdb..#CuzBytier',N'U') IS NOT NULL DROP TABLE #CuzByTier

CREATE TABLE #CuzByTier (
						first_year int,
						first_month int,
						tier int,
						period int,
						newcuz int,
						newrev int,
						neworders int)

  
INSERT INTO #CuzByTier
EXEC GetCohort_ByTier 1

 -- Getting cohort in term of # of customer

SELECT first_year,
       first_month,
	   MAX(CASE WHEN period = 0 THEN newcuz ELSE 0 END) AS NewCuz_0,
	   MAX(CASE WHEN period = 1 THEN newcuz ELSE 0 END) AS NewCuz_1,
	   MAX(CASE WHEN period = 2 THEN newcuz ELSE 0 END) AS NewCuz_2,
	   MAX(CASE WHEN period = 3 THEN newcuz ELSE 0 END) AS NewCuz_3,
	   MAX(CASE WHEN period = 4 THEN newcuz ELSE 0 END) AS NewCuz_4,
	   MAX(CASE WHEN period = 5 THEN newcuz ELSE 0 END) AS NewCuz_5,
	   MAX(CASE WHEN period = 6 THEN newcuz ELSE 0 END) AS NewCuz_6,
	   MAX(CASE WHEN period = 7 THEN newcuz ELSE 0 END) AS NewCuz_7,
	   MAX(CASE WHEN period = 8 THEN newcuz ELSE 0 END) AS NewCuz_8,
	   MAX(CASE WHEN period = 9 THEN newcuz ELSE 0 END) AS NewCuz_9,
	   MAX(CASE WHEN period = 10 THEN newcuz ELSE 0 END) AS NewCuz_10,
	   MAX(CASE WHEN period = 11 THEN newcuz ELSE 0 END) AS NewCuz_11,
	   MAX(CASE WHEN period = 12 THEN newcuz ELSE 0 END) AS NewCuz_12
FROM #CuzByTier
GROUP BY first_year,
         first_month


 -- Getting cohort in term of # of rev

SELECT first_year,
       first_month,
	   MAX(CASE WHEN period = 0 THEN newrev ELSE 0 END) AS Newrev_0,
	   MAX(CASE WHEN period = 1 THEN newrev ELSE 0 END) AS Newrev_1,
	   MAX(CASE WHEN period = 2 THEN newrev ELSE 0 END) AS Newrev_2,
	   MAX(CASE WHEN period = 3 THEN newrev ELSE 0 END) AS Newrev_3,
	   MAX(CASE WHEN period = 4 THEN newrev ELSE 0 END) AS Newrev_4,
	   MAX(CASE WHEN period = 5 THEN newrev ELSE 0 END) AS Newrev_5,
	   MAX(CASE WHEN period = 6 THEN newrev ELSE 0 END) AS Newrev_6,
	   MAX(CASE WHEN period = 7 THEN newrev ELSE 0 END) AS Newrev_7,
	   MAX(CASE WHEN period = 8 THEN newrev ELSE 0 END) AS Newrev_8,
	   MAX(CASE WHEN period = 9 THEN newrev ELSE 0 END) AS Newrev_9,
	   MAX(CASE WHEN period = 10 THEN newrev ELSE 0 END) AS Newrev_10,
	   MAX(CASE WHEN period = 11 THEN newrev ELSE 0 END) AS Newrev_11,
	   MAX(CASE WHEN period = 12 THEN newrev ELSE 0 END) AS Newrev_12

FROM #CuzByTier
GROUP BY first_year,
         first_month

 -- Getting cohort in term of # of orders
 SELECT first_year,
       first_month,
	   MAX(CASE WHEN period = 0 THEN neworders ELSE 0 END) AS Neworders_0,
	   MAX(CASE WHEN period = 1 THEN neworders ELSE 0 END) AS Neworders_1,
	   MAX(CASE WHEN period = 2 THEN neworders ELSE 0 END) AS Neworders_2,
	   MAX(CASE WHEN period = 3 THEN neworders ELSE 0 END) AS Neworders_3,
	   MAX(CASE WHEN period = 4 THEN neworders ELSE 0 END) AS Neworders_4,
	   MAX(CASE WHEN period = 5 THEN neworders ELSE 0 END) AS Neworders_5,
	   MAX(CASE WHEN period = 6 THEN neworders ELSE 0 END) AS Neworders_6,
	   MAX(CASE WHEN period = 7 THEN neworders ELSE 0 END) AS Neworders_7,
	   MAX(CASE WHEN period = 8 THEN neworders ELSE 0 END) AS Neworders_8,
	   MAX(CASE WHEN period = 9 THEN neworders ELSE 0 END) AS Neworders_9,
	   MAX(CASE WHEN period = 10 THEN neworders ELSE 0 END) AS Neworders_10,
	   MAX(CASE WHEN period = 11 THEN neworders ELSE 0 END) AS Neworders_11,
	   MAX(CASE WHEN period = 12 THEN neworders ELSE 0 END) AS Neworders_12
FROM #CuzByTier
GROUP BY first_year,
         first_month

-- Cohorts in transaction volume per client
SELECT first_year,
       first_month,
	   ISNULL([0],0) AS [0],
	   ISNULL([1],0) AS [1],
	   ISNULL([2],0) AS [2],
	   ISNULL([3],0) AS [3],
	   ISNULL([4],0) AS [4],
	   ISNULL([5],0) AS [5],
	   ISNULL([6],0) AS [6],
	   ISNULL([7],0) AS [7],
	   ISNULL([8],0) AS [8]
FROM
	(
	SELECT first_year,
		   first_month,
		   period,
		   Rev_per_cuz_ARPA
	FROM
		(
			SELECT *,
				  Neworders*1.0/newcuz AS Order_Per_Cuz_AFPR,
				  Newrev*1.0/newcuz AS Rev_per_cuz_ARPA,
				  Newrev*1.0/neworders AS Rev_per_Ode_AOV
			FROM #CuzByTier
		)SubQ1
	) AS Source_table
PIVOT 
(
MAX(Rev_per_cuz_ARPA)
FOR period IN ([0],[1],[2],[3],[4],[5],[6],[7],[8])
) Result_table

