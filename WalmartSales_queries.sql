-- Create database
CREATE DATABASE IF NOT EXISTS walmartSales;


-- Create table and erasing null data
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

-- Data cleaning
SELECT
	*
FROM sales;


-- Adding the time_of_day column
SELECT
	time,
	(CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_day
FROM sales;


ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

-- Note : for this to work turn off safe mode for update!!
-- Edit > Preferences > SQL Edito > scroll down and toggle safe mode
-- Reconnect to MySQL: Query > Reconnect to server
UPDATE sales
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);


-- Add day_name column
SELECT
	date,
	DAYNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);

-- Add month_name column
SELECT
	date,
	MONTHNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);

-- --------------------------------------------------------------------
-- ------------------------ Generic Questions -------------------------
-- --------------------------------------------------------------------
-- How many unique cities does the data have?
SELECT 
	DISTINCT city
FROM sales;

-- In which city is each branch?
SELECT 
	DISTINCT city,
    branch
FROM sales;

-- --------------------------------------------------------------------
-- ----------------------- Product Questions --------------------------
-- --------------------------------------------------------------------

-- How many unique product lines does the data have?
SELECT
	count(DISTINCT product_line)
FROM sales;

-- What is the most common payment method?
SELECT
	payment,
    count(payment) as cnt
from sales
group by payment
order by cnt desc;

-- What is the most selling product line?
SELECT
	product_line, SUM(quantity) as qty
FROM sales
GROUP BY product_line
ORDER BY qty DESC;

-- What is the total revenue by month
SELECT
	month_name AS month,
	SUM(total) AS total_revenue
FROM sales
GROUP BY month_name 
ORDER BY total_revenue desc;

-- What month had the largest COGS?
SELECT
	month_name AS month,
	SUM(cogs) AS cogs
FROM sales
GROUP BY month_name 
ORDER BY cogs limit 1;


-- What product line had the largest revenue?
SELECT
	product_line,
	SUM(total) as total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC limit 1;

-- What is the city with the largest revenue?
SELECT
	city,
	SUM(total) AS total_revenue
FROM sales
GROUP BY city
ORDER BY total_revenue desc limit 1; 


-- What product line had the largest VAT?
SELECT
	product_line,
	AVG(tax_pct) as avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC limit 1;

-- Fetch each product line and add a column to those product 
-- line showing "Good", "Bad". Good if its greater than average sales

SELECT 
	AVG(total) AS avg_total
FROM sales;

SELECT
	product_line,
	CASE
		WHEN AVG(total) > 323 THEN "Good"
        ELSE "Bad"
    END AS remark
FROM sales
GROUP BY product_line;

-- Which branch sold more products than average product sold? 
SELECT branch, avg_branch
FROM (
    SELECT 
        branch,
        AVG(quantity) AS avg_branch
    FROM sales
    GROUP BY branch
) AS avg_all_branch
WHERE avg_branch > (
    SELECT AVG(quantity) 
    FROM sales);

-- What is the most common product line by gender
SELECT
    gender,
    product_line,
    total_cnt
FROM (
    SELECT
        gender,
        product_line,
        COUNT(gender) AS total_cnt
    FROM sales
    GROUP BY gender, product_line
) AS sub
WHERE (gender, total_cnt) IN (
    SELECT
        gender,
        MAX(total_cnt)
    FROM (
        SELECT
            gender,
            product_line,
            COUNT(gender) AS total_cnt
        FROM sales
        GROUP BY gender, product_line
    ) AS sub2
    GROUP BY gender
)
ORDER BY gender DESC;

-- What is the average rating of each product line
SELECT
	product_line, ROUND(AVG(rating), 2) as avg_rating
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- -------------------------- Customers -------------------------------
-- --------------------------------------------------------------------

-- How many unique customer types does the data have?
SELECT
	DISTINCT customer_type
FROM sales;

-- How many unique payment methods does the data have?
SELECT
	DISTINCT payment
FROM sales;

-- What is the most common customer type?
SELECT
	customer_type,
	count(*) as count
FROM sales
GROUP BY customer_type
ORDER BY count DESC;

-- Which customer type buys the most?
SELECT
	customer_type,
    COUNT(*)
FROM sales
GROUP BY customer_type
order by count(*) desc limit 1;


-- What is the gender of most of the customers?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC limit 1;

-- What is the gender distribution per branch?
SELECT
    branch,
    gender,
    COUNT(*) AS gender_cnt
FROM sales
GROUP BY branch, gender
ORDER BY branch, gender DESC;


-- Which time of the day do customers give most ratings?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Looks like time of the day does not really affect the rating, its more or less the same for each time of the day


-- Which time of the day do customers give most ratings per branch?
SELECT
    branch,
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day, branch
ORDER BY branch, avg_rating DESC;
-- Branch A Afternoon, B Morning, C Afternoon


-- Which day fo the week has the best avg ratings?
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name 
ORDER BY avg_rating DESC;
-- Monday is the best day for avg_ratings


-- Which day of the week has the best average ratings per branch?
SELECT 
	branch,
	day_name,
	COUNT(day_name) total_sales
FROM sales
GROUP BY branch, day_name
ORDER BY branch, total_sales DESC;
-- Branch A is Sunday, Branch B is saturday, and Branch C is Tuesday


-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- ---------------------------- Sales ---------------------------------
-- --------------------------------------------------------------------

-- Number of sales made in each time of the day per weekday 
SELECT
	time_of_day,
	COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Sunday"
GROUP BY time_of_day 
ORDER BY total_sales DESC;
-- Evenings experience most sales, the stores are 
-- filled during the evening hours

-- Which of the customer types brings the most revenue?
SELECT
	customer_type,
	SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue desc limit 1;

-- Which city has the largest tax/VAT percent?
SELECT
	city,
    ROUND(AVG(tax_pct), 2) AS avg_tax_pct
FROM sales
GROUP BY city 
ORDER BY avg_tax_pct DESC limit 1;

-- Which customer type pays the most in VAT?
SELECT
	customer_type,
	AVG(tax_pct) AS total_tax
FROM sales
GROUP BY customer_type
ORDER BY total_tax desc limit 1;

-- --------------------------------------------------------------------
-- --------------------------------------------------------------------
