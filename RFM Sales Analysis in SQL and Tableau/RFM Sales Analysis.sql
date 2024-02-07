
-- Inspecting Data
SELECT * FROM sales_data_sample;

-- Checking distinct values
SELECT DISTINCT status 
FROM sales_data_sample; -- data to plot

SELECT DISTINCT year_id 
FROM sales_data_sample;

SELECT DISTINCT PRODUCTLINE
FROM sales_data_sample; -- data to plot

SELECT DISTINCT COUNTRY
FROM sales_data_sample; -- data to plot

SELECT DISTINCT DEALSIZE
FROM sales_data_sample; -- data to plot

SELECT DISTINCT TERRITORY
FROM sales_data_sample; -- data to plot

-- Analysis

-- Grouping sales by productline
SELECT PRODUCTLINE,
	SUM(SALES) AS Revenue
FROM dbo.sales_data_sample
GROUP BY PRODUCTLINE
ORDER BY 2 DESC;

-- Grouping sales by year
SELECT YEAR_ID,
	SUM(SALES) AS Revenue
FROM dbo.sales_data_sample
GROUP BY YEAR_ID
ORDER BY 2 DESC; -- Highest revenue on 2004

SELECT DISTINCT MONTH_ID
FROM sales_data_sample
WHERE year_id = 2005; /* A high drop in total sales revenue in 2005 because 
data only covers a span of five months */

-- Grouping sales by dealsizes
SELECT DEALSIZE,
	SUM(SALES) AS Revenue
FROM sales_data_sample
GROUP BY DEALSIZE
ORDER BY 2 DESC;

-- What was the best month for sales in each year? How much was earned that month?
SELECT MONTH_ID,
	SUM(SALES) AS Revenue,
	COUNT(ORDERNUMBER) AS Frequency
FROM sales_data_sample
WHERE YEAR_ID = 2003
GROUP BY MONTH_ID
ORDER BY 2 DESC; -- November is the best month in 2003

SELECT MONTH_ID,
	SUM(SALES) AS Revenue,
	COUNT(ORDERNUMBER) AS Frequency
FROM sales_data_sample
WHERE YEAR_ID = 2004
GROUP BY MONTH_ID
ORDER BY 2 DESC; -- November is also the best month in 2004

SELECT MONTH_ID,
	SUM(SALES) AS Revenue,
	COUNT(ORDERNUMBER) AS Frequency
FROM sales_data_sample
WHERE YEAR_ID = 2005
GROUP BY MONTH_ID
ORDER BY 2 DESC; -- May is the best month so far in 2005

-- What product do they sell in November 2003?
SELECT MONTH_ID,
	PRODUCTLINE,
	SUM(SALES) AS Revenue,
	COUNT(ORDERNUMBER) AS Frequency
FROM sales_data_sample
WHERE YEAR_ID = 2003 AND MONTH_ID = 11
GROUP BY MONTH_ID, PRODUCTLINE
ORDER BY 3 DESC; /* Classic Cars is the product with the most 
revenue and order frequency in November 2003 */

-- What product do they sell in November 2004?
SELECT MONTH_ID,
	PRODUCTLINE,
	SUM(SALES) AS Revenue,
	COUNT(ORDERNUMBER) AS Frequency
FROM sales_data_sample
WHERE YEAR_ID = 2004 AND MONTH_ID = 11
GROUP BY MONTH_ID, PRODUCTLINE
ORDER BY 3 DESC; /* Classic Cars is also the product with the most 
revenue and order frequency in November 2004 */

-- What product do they sell in May 2005?
SELECT MONTH_ID,
	PRODUCTLINE,
	SUM(SALES) AS Revenue,
	COUNT(ORDERNUMBER) AS Frequency
FROM sales_data_sample
WHERE YEAR_ID = 2005 AND MONTH_ID = 5
GROUP BY MONTH_ID, PRODUCTLINE
ORDER BY 3 DESC; /* Classic Cars is also the product with the most 
revenue and order frequency in May 2005 */

-- Who is the best customer? (Using RFM Analysis)
DROP TABLE IF EXISTS #rfm;
WITH rfm AS
(
	SELECT CUSTOMERNAME,
		SUM(SALES) AS MonetaryValue,
		AVG(SALES) AS AvgMonetaryValue,
		COUNT(ORDERNUMBER) AS Frequency,
		MAX(ORDERDATE) AS last_order_date,
		(SELECT MAX(ORDERDATE) FROM sales_data_sample) AS max_order_date,
		DATEDIFF(DD, MAX(ORDERDATE), (SELECT MAX(ORDERDATE) FROM sales_data_sample)) AS Recency
	FROM sales_data_sample
	GROUP BY CUSTOMERNAME
),
rfm_calc AS
(
	SELECT *,
		NTILE(4) OVER (ORDER BY Recency DESC) AS rfm_recency,
		NTILE(4) OVER (ORDER BY Frequency) AS rfm_frequency,
		NTILE(4) OVER (ORDER BY AvgMonetaryValue) AS rfm_monetary
	FROM rfm
)
SELECT *,
	rfm_recency + rfm_frequency + rfm_monetary AS rfm_cell,
	CAST(rfm_recency AS varchar) + CAST(rfm_frequency AS varchar) + CAST(rfm_monetary AS varchar) AS rfm_cell_string
INTO #rfm
FROM rfm_calc

SELECT CUSTOMERNAME, rfm_recency, rfm_frequency, rfm_monetary,
	CASE
		WHEN rfm_cell_string IN (111, 112, 121, 122, 123, 132, 131, 114, 141, 142) THEN 'lost customers'
		WHEN rfm_cell_string IN (133, 134, 143, 244, 334, 343, 344, 144) THEN 'slipping away, cannot lose' -- Big spenders who haven't purchased lately
		WHEN rfm_cell_string IN (311, 411, 331, 211, 212, 312, 113, 314, 214, 414) THEN 'new customers'
		WHEN rfm_cell_string IN (222, 223, 233, 322, 231, 241, 234, 224, 221) THEN 'potential churners'
		WHEN rfm_cell_string IN (323, 333, 321, 422, 421, 332, 432, 341, 441, 442, 342) THEN 'active' -- Customer who buy often & recently, but at low price points
		WHEN rfm_cell_string IN (433, 434, 443, 444, 424) THEN 'loyal'
	END rfm_segment
FROM #rfm;

-- What products are most often sold together?
SELECT *
FROM sales_data_sample
WHERE ORDERNUMBER = 10411

SELECT DISTINCT ORDERNUMBER, STUFF(

	(SELECT ',' + PRODUCTCODE
	FROM sales_data_sample AS data
	WHERE ORDERNUMBER IN 
		(
			SELECT ORDERNUMBER
			FROM (
				SELECT ORDERNUMBER, COUNT(*) AS num_of_shipped
				FROM sales_data_sample
				WHERE STATUS = 'Shipped'
				GROUP BY ORDERNUMBER
			) AS Shipped
			WHERE num_of_shipped = 2
		)
		AND data.ORDERNUMBER = product.ORDERNUMBER
		FOR xml path (''))
		, 1, 1, '') AS ProductCodes

FROM sales_data_sample AS product
ORDER BY 2 DESC;
/* Based on the query, product code S18_2325 with S24_1937, 
and S18_1342 with S18_1367 from Vintage often sold together */

-- What city has the highest number of sales in each country?
WITH CitySales AS 
(
	SELECT COUNTRY,
		CITY,
		SUM(SALES) AS Revenue,
		ROW_NUMBER() OVER(PARTITION BY Country ORDER BY SUM(Sales) DESC) AS RowNum
	FROM sales_data_sample
	GROUP BY COUNTRY, CITY
)
SELECT COUNTRY,
	CITY, 
	REVENUE
FROM CitySales
WHERE RowNum = 1
ORDER BY 3 DESC;
/* It shows that Madrid has the highest revenue among
all cities, being 1.082.551 */

-- What is the best product in Madrid?
SELECT CITY,
	YEAR_ID,
	PRODUCTLINE,
	SUM(SALES) AS Revenue
FROM sales_data_sample
WHERE CITY = 'Madrid'
GROUP BY CITY, YEAR_ID, PRODUCTLINE
ORDER BY 4 DESC;
/* Classic Cars is the product line with the highest 
revenue in Madrid, 209.568 in 2004 */