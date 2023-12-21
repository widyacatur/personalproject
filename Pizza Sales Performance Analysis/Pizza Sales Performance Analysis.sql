-- KPI's Requirement

-- Total Revenue: The sum of the total price of all pizza orders

SELECT SUM(total_price) AS Total_Revenue FROM pizza_sales

-- Average Order by Value: The average amount spent per order, calculated by dividing the total revenue by the total number of orders

SELECT SUM(total_price) / COUNT(DISTINCT order_id) AS Avg_Order_Value FROM pizza_sales

-- Total Pizzas Sold: The sum of the quantities of all pizzas sold

SELECT SUM(quantity) AS Total_Pizza_Sold FROM pizza_sales

-- Total Orders: The total number of orders placed

SELECT COUNT(DISTINCT order_id) AS Total_orders FROM pizza_sales

-- Average Pizzas per Order: The average number of pizzas sold per order, calculated by dividing the total number of pizzas sold by the total number of orders

SELECT CAST(CAST(SUM(quantity) AS DECIMAL(10,2)) / 
			CAST(COUNT(DISTINCT order_id) AS DECIMAL(10,2)) 
		AS DECIMAL(10,2)) 
		AS Avg_Pizza_Order 
FROM pizza_sales

--==========================

-- CHARTS REQUIREMENT

-- Daily Trend for Total Orders

SELECT DATENAME(DW, order_date) AS order_day,
		COUNT(DISTINCT order_id) AS Total_orders
FROM pizza_sales
GROUP BY DATENAME(DW, order_date) 

-- Monthly Trend for Total Orders

SELECT DATENAME(MONTH, order_date) AS Month_Name,
		COUNT(DISTINCT order_id) AS Total_orders
FROM pizza_sales
GROUP BY DATENAME(MONTH, order_date)
ORDER BY Total_orders DESC

-- Percentage of Sales by Pizza Category

SELECT pizza_category,
		SUM(total_price) AS total_sales,
		SUM(total_price) * 100 / (SELECT sum(total_price)
									FROM pizza_sales) AS perc_of_sales
FROM pizza_sales
GROUP BY pizza_category

-- filtering for january

SELECT pizza_category,
		SUM(total_price) AS total_sales,
		SUM(total_price) * 100 / (SELECT sum(total_price)
									FROM pizza_sales
									WHERE MONTH(order_date) = 1) AS perc_of_sales
FROM pizza_sales
WHERE MONTH(order_date) = 1 -- (filtering for january)
GROUP BY pizza_category

-- Percentage of Sales by Pizza Size

SELECT pizza_size,
		SUM(total_price) AS total_sales,
		SUM(total_price) * 100 / (SELECT sum(total_price)
									FROM pizza_sales) AS perc_of_sales
FROM pizza_sales
GROUP BY pizza_size
ORDER BY perc_of_sales DESC

--refining decimals

SELECT pizza_size,
		CAST(SUM(total_price) AS decimal(10,2)) AS total_sales,
		CAST(SUM(total_price) * 100 / (SELECT sum(total_price)
									FROM pizza_sales) AS decimal(10,2)) AS perc_of_sales
FROM pizza_sales
GROUP BY pizza_size
ORDER BY perc_of_sales DESC

--for 1st quarter

SELECT pizza_size,
		CAST(SUM(total_price) AS decimal(10,2)) AS total_sales,
		CAST(SUM(total_price) * 100 / (SELECT sum(total_price)
										FROM pizza_sales 
										WHERE DATEPART(quarter, order_date)=1) AS decimal(10,2)) AS perc_of_sales
FROM pizza_sales
WHERE DATEPART(quarter, order_date) = 1
GROUP BY pizza_size
ORDER BY perc_of_sales DESC

-- Top & Worst 5 Best Sellers by Revenue, Total Quantity, and Total Orders

SELECT TOP 5 pizza_name, 
			SUM(total_price) as total_revenue
FROM pizza_sales
GROUP BY pizza_name
ORDER BY total_revenue DESC

SELECT TOP 5 pizza_name, 
			SUM(total_price) as total_revenue
FROM pizza_sales
GROUP BY pizza_name
ORDER BY total_revenue ASC

SELECT TOP 5 pizza_name, 
			SUM(quantity) as total_quantity
FROM pizza_sales
GROUP BY pizza_name
ORDER BY total_quantity DESC

SELECT TOP 5 pizza_name, 
			SUM(quantity) as total_quantity
FROM pizza_sales
GROUP BY pizza_name
ORDER BY total_quantity ASC

SELECT TOP 5 pizza_name, 
			COUNT(DISTINCT order_id) as total_orders
FROM pizza_sales
GROUP BY pizza_name
ORDER BY total_orders DESC

SELECT TOP 5 pizza_name, 
			COUNT(DISTINCT order_id) as total_orders
FROM pizza_sales
GROUP BY pizza_name
ORDER BY total_orders ASC

 
