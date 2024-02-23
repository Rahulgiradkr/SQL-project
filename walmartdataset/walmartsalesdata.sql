create database EDA;
use EDA;
CREATE TABLE WalmartSalesData (
        `Invoice ID` VARCHAR(11) NOT NULL,
        `Branch` VARCHAR(1) NOT NULL,
        `City` VARCHAR(9) NOT NULL,
        `Customer type` VARCHAR(6) NOT NULL,
        `Gender` VARCHAR(6) NOT NULL,
        `Product line` VARCHAR(22) NOT NULL,
        `Unit price` DECIMAL(38, 2) NOT NULL,
        `Quantity` DECIMAL(38, 0) NOT NULL,
        `Tax 5%%` DECIMAL(38, 4) NOT NULL,
        `Total` DECIMAL(38, 4) NOT NULL,
        `Date` VARCHAR(30),
        `Time` TIME NOT NULL,
        `Payment` VARCHAR(11) NOT NULL,
        cogs DECIMAL(38, 2) NOT NULL,
        `gross margin percentage` DECIMAL(38, 9) NOT NULL,
        `gross income` DECIMAL(38, 4) NOT NULL,
        `Rating` DECIMAL(38, 1) NOT NULL
);


select * from walmartsalesdata;





LOAD DATA INFILE  
'D:\WalmartSalesData.csv'
into table WalmartSalesData
FIELDS TERMINATED by ','
ENCLOSED by '"'
lines terminated by '\n'
IGNORE 1 ROWS;

select str_to_date(Date,'%m/%d/%y') from WalmartSalesData;

alter table WalmartSalesData
add column Date_new  date after `Date`;

update WalmartSalesData
set Date_new = str_to_date(`Date`,'%m/%d/%Y');

select * from walmartsalesdata;

-- Data cleaning

-- Add the time_of_day column
SELECT 
	TIME,
    (CASE
		WHEN 'TIME' BETWEEN '00:00:00' AND '12:00:00' THEN 'MORNING'
        WHEN 'TIME' BETWEEN '12:01:00' AND '16:00:00' THEN 'AFTERNOON'
        ELSE 'EVENING'
        END) AS TIME_OF_DAY
	FROM walmartsalesdata;
    
    ALTER TABLE walmartsalesdata ADD COLUMN time_of_day VARCHAR(20);
    
UPDATE walmartsalesdata
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
	DAYNAME(date_new)
FROM walmartsalesdata;

ALTER TABLE walmartsalesdata ADD COLUMN day_name VARCHAR(10);

UPDATE walmartsalesdata
SET day_name = DAYNAME(date_new);


-- Add month_name column
SELECT
	date,
	MONTHNAME(date_new)
FROM walmartsalesdata;

ALTER TABLE walmartsalesdata ADD COLUMN month_name VARCHAR(10);

UPDATE walmartsalesdata
SET month_name = MONTHNAME(date_new);

--------------------------------------------------
-- How many unique cities does the data have?
select distinct city from walmartsalesdata;

-- In which city is each branch?
select distinct city,branch from walmartsalesdata;

-- --------------------------------------------------------------------
-- ---------------------------- Product -------------------------------
-- --------------------------------------------------------------------

-- How many unique product lines does the data have?

select distinct `Product line` from walmartsalesdata;


-- What is the most selling product line

SELECT
	SUM(quantity) as qty,
    `product line`
FROM walmartsalesdata
GROUP BY `product line`
ORDER BY qty DESC;

-- What is the most selling product line
SELECT
	SUM(quantity) as qty,
    `product line`
FROM walmartsalesdata
GROUP BY `product line`
ORDER BY qty DESC;

-- What is the total revenue by month
SELECT
	month_name AS month,
	SUM(total) AS total_revenue
FROM walmartsalesdata
GROUP BY month_name 
ORDER BY total_revenue;

-- What month had the largest COGS?
SELECT
	month_name AS month,
	SUM(cogs) AS cogs
FROM walmartsalesdata
GROUP BY month_name 
ORDER BY cogs;

-- What product line had the largest revenue?
SELECT
	`product line`,
	SUM(total) as total_revenue
FROM walmartsalesdata
GROUP BY `product line`
ORDER BY total_revenue DESC;

-- What is the city with the largest revenue?
SELECT
	branch,
	city,
	SUM(total) AS total_revenue
FROM walmartsalesdata
GROUP BY city, branch 
ORDER BY total_revenue;

-- What product line had the largest VAT?
SELECT
	`product line`,
	AVG(`Tax 5%%`) as avg_tax
FROM walmartsalesdata
GROUP BY `product line`
ORDER BY avg_tax DESC;

-- Fetch each product line and add a column to those product 
-- line showing "Good", "Bad". Good if its greater than average sales

SELECT 
	AVG(quantity) AS avg_qnty
FROM walmartsalesdata;

SELECT
	`product line`,
	CASE
		WHEN AVG(quantity) > 6 THEN "Good"
        ELSE "Bad"
    END AS remark
FROM walmartsalesdata
GROUP BY `product line`;

-- Which branch sold more products than average product sold?
SELECT 
	branch, 
    SUM(quantity) AS qnty
FROM walmartsalesdata
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM walmartsalesdata);

-- What is the most common product line by gender
SELECT
	gender,
    `product line`,
    COUNT(gender) AS total_cnt
FROM walmartsalesdata
GROUP BY gender, `product line`
ORDER BY total_cnt DESC;

-- What is the average rating of each product line
SELECT
	ROUND(AVG(rating), 2) as avg_rating,
    `product line`
FROM walmartsalesdata
GROUP BY `product line`
ORDER BY avg_rating DESC;

-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- -------------------------- Customers -------------------------------
-- --------------------------------------------------------------------

-- How many unique customer types does the data have?
SELECT
	DISTINCT `customer type`
FROM walmartsalesdata;

-- How many unique payment methods does the data have?
SELECT
	DISTINCT payment
FROM walmartsalesdata;


-- What is the most common customer type?
SELECT
	`customer type`,
	count(*) as count
FROM walmartsalesdata
GROUP BY `customer type`
ORDER BY count DESC;

-- Which customer type buys the most?
SELECT
	`customer type`,
    COUNT(*)
FROM walmartsalesdata
GROUP BY `customer type`;


-- What is the gender of most of the customers?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM walmartsalesdata
GROUP BY gender
ORDER BY gender_cnt DESC;

-- What is the gender distribution per branch?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM walmartsalesdata
WHERE branch = "C"
GROUP BY gender
ORDER BY gender_cnt DESC;
-- Gender per branch is more or less the same hence, I don't think has
-- an effect of the sales per branch and other factors.

-- Which time of the day do customers give most ratings?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM walmartsalesdata
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Looks like time of the day does not really affect the rating, its
-- more or less the same rating each time of the day.alter


-- Which time of the day do customers give most ratings per branch?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM walmartsalesdata
WHERE branch = "A"
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Branch A and C are doing well in ratings, branch B needs to do a 
-- little more to get better ratings.


-- Which day fo the week has the best avg ratings?
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM walmartsalesdata
GROUP BY day_name 
ORDER BY avg_rating DESC;
-- Mon, Tue and Friday are the top best days for good ratings
-- why is that the case, how many sales are made on these days?



-- Which day of the week has the best average ratings per branch?
SELECT 
	day_name,
	COUNT(day_name) total_sales
FROM walmartsalesdata
WHERE branch = "C"
GROUP BY day_name
ORDER BY total_sales DESC;


-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- ---------------------------- Sales ---------------------------------
-- --------------------------------------------------------------------

-- Number of sales made in each time of the day per weekday 
SELECT
	time_of_day,
	COUNT(*) AS total_sales
FROM walmartsalesdata
WHERE day_name = "Sunday"
GROUP BY time_of_day 
ORDER BY total_sales DESC;
-- Evenings experience most sales, the stores are 
-- filled during the evening hours

-- Which of the customer types brings the most revenue?
SELECT
	`customer type`,
	SUM(total) AS total_revenue
FROM walmartsalesdata
GROUP BY `customer type`
ORDER BY total_revenue;

-- Which city has the largest tax/VAT percent?
SELECT
	city,
    ROUND(AVG(`Tax 5%%`), 2) AS avg_tax_pct
FROM walmartsalesdata
GROUP BY city 
ORDER BY avg_tax_pct DESC;

-- Which customer type pays the most in VAT?
SELECT
	`customer type`,
	AVG(`Tax 5%%`) AS total_tax
FROM walmartsalesdata
GROUP BY `customer type`
ORDER BY total_tax ;

-- --------------------------------------------------------------------
-- --------------------------------------------------------------------
select * from walmartsalesdata;











