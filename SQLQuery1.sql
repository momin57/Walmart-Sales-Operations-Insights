SELECT * FROM Walmart.dbo.walmart_sales;

SELECT COUNT(*) FROM Walmart.dbo.walmart_sales;

-- 1. Analyze Payment Methods and Sales
-- Question: What are the different payment methods, and how many transactions and items were sold with each method?

SELECT payment_method, COUNT(*) as total_transactions, SUM(quantity) as total_items_sold FROM walmart_sales
GROUP BY payment_method;

-- 2. Identify the Highest-Rated Category in Each Branch
-- Question: Which category received the highest average rating in each branch?

SELECT *
FROM 
(
	SELECT branch, category, ROUND(AVG(rating), 2) as avg_rating, RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) as rank
	FROM walmart_sales
	GROUP BY category, branch
) as ranked_data
WHERE rank = 1;

--  3. Determine the Busiest Day for Each Branch
-- Question: What is the busiest day of the week for each branch based on transaction volume?

-- 'date' is in VARCHAR datatype so created a 'formatted_date' column instead

ALTER TABLE walmart_sales
ADD formatted_date DATE;

UPDATE walmart_sales
SET formatted_date = TRY_PARSE(date AS DATE USING 'en-GB');
---------

SELECT *
FROM 
(
	SELECT branch, DATENAME(WEEKDAY, formatted_date) AS day_name, count(*)  as num_transactions,
	RANK() OVER (PARTITION BY branch ORDER BY count(*) DESC) as rank
	FROM walmart_sales
	GROUP BY branch, DATENAME(WEEKDAY, formatted_date)
) AS day_ranked_data
WHERE rank = 1;

-- 4. Calculate Total Quantity Sold by Payment Method
-- Question: How many items were sold through each payment method?

SELECT payment_method, SUM(quantity) as total_items_sold FROM walmart_sales
GROUP BY payment_method;

-- 5. Analyze Category Ratings by City
-- Question: What are the average, minimum, and maximum ratings for each category in each city?

SELECT city, ROUND(AVG(rating), 2) as avg_rating, MAX(rating) as max_rating, MIN(rating) as min_rating
FROM walmart_sales
GROUP BY city
ORDER BY avg_rating DESC;

--  6. Calculate Total Profit by Category
-- Question: What is the total profit for each category, ranked from highest to lowest?
-- lets create a column 'profit' so we can use it in future

ALTER TABLE walmart_sales
ADD profit FLOAT;

UPDATE walmart_sales
SET profit = ROUND((profit_margin * total), 2);

SELECT category, ROUND(SUM(total), 2) as total_revenue, ROUND(SUM(profit), 2) as total_profit, RANK() OVER (ORDER BY SUM(profit) DESC) as rank
FROM walmart_sales
GROUP BY category;

-- 7. Determine the Most Common Payment Method per Branch
-- Question: What is the most frequently used payment method in each branch?

SELECT *
FROM (
SELECT branch, payment_method, count(*) as num_transactions,
RANK() OVER (PARTITION BY branch ORDER BY count(*) DESC) as rank
FROM walmart_sales
GROUP BY branch, payment_method
) as ranked_payment_data
WHERE rank = 1
ORDER BY branch;

-- 8. Analyze Sales Shifts Throughout the Day
-- Question: How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?

WITH time_of_day_table AS
(
	select branch,  
	CASE WHEN CAST(time as TIME) >= '06:00:00' AND CAST(time as TIME) < '12:00:00' THEN 'morning'
	WHEN CAST(time as TIME) >= '12:00:00' AND CAST(time as TIME) < '18:00:00' THEN 'afternoon'
	WHEN CAST(time as TIME) >= '18:00:00' AND CAST(time as TIME) <= '23:59:50' THEN 'evening'
	ELSE 'night' 
	END as time_of_day
	FROM walmart_sales
)

SELECT branch, time_of_day, count(*) as num_transactions
FROM time_of_day_table
GROUP BY branch, time_of_day
ORDER BY branch, time_of_day;

-- 9. Identify Branches with Highest Revenue Decline Year-Over-Year
-- Question: Which branches experienced the largest decrease in revenue compared to the previous year?

WITH revenue_year_sales AS
(
	SELECT branch, sum(total) as total_revenue, YEAR(formatted_date) as sales_year
	FROM walmart_sales
	GROUP BY branch, YEAR(formatted_date)
),
revenue_change AS
(
	SELECT curr.branch, curr.sales_year, curr.total_revenue, prev.total_revenue as previous_year_revenue,
	(curr.total_revenue - prev.total_revenue) AS revenue_change,
	ROUND(((curr.total_revenue - prev.total_revenue) * 100.0) / prev.total_revenue, 2) AS revenue_change_percent
	FROM revenue_year_sales curr
	LEFT JOIN revenue_year_sales prev
	ON curr.branch = prev.branch AND curr.sales_year = prev.sales_year + 1
)

SELECT TOP 5 branch, sales_year, previous_year_revenue, total_revenue as current_year_revenue, revenue_change_percent
FROM revenue_change
WHERE sales_year = 2023 AND previous_year_revenue IS NOT NULL AND revenue_change < 0
ORDER BY revenue_change_percent;