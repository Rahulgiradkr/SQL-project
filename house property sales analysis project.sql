use eda;
CREATE TABLE raw_sales (
        datesold TIMESTAMP NULL,
        postcode DECIMAL(38, 0) NOT NULL,
        price DECIMAL(38, 0) NOT NULL,
        `propertyType` VARCHAR(5) NOT NULL,
        bedrooms  INTEGER NOT NULL
);


LOAD DATA INFILE  
'D:/rawsales.csv'
into table raw_sales
FIELDS TERMINATED by ','
lines terminated by '\n'
IGNORE 1 ROWS;

select * from raw_sales;

# House Property Sales Analysis

# The retail industry now heavily relies on data analytics tools to better estimate the prices of different properties. 
# Work on this project idea deals with analyzing the sales of house properties in a city in Australia.

# dataset includes the following columns:

#Datesold: The date when an owner sold the house to a buyer.

#Postcode: 4 digit postcode of the suburb where the owner sold the property.

#Price: Price for which the owner sold the property.

#Bedrooms: Number of bedrooms.

# SQL Project: First, use basic commands in SQL to get a feel of the scale of the numbers involved in the dataset. After that, answer the questions mentioned below to learn more about the patterns in the dataset.

#Which date corresponds to the highest number of sales?

#Find out the postcode with the highest average price per sale? (Using Aggregate Functions)

#Which year witnessed the lowest number of sales?

#Use the window function to deduce the top six postcodes by year's price.

#Data exploration

select * from raw_sales;

select distinct propertytype from raw_sales;

select distinct postcode  from raw_sales;

select distinct bedrooms 
from raw_sales 
order by  bedrooms asc;

# some observations had the value 0 in bedrooms so I decided to take a look at those

select datesold,propertyType,bedrooms from raw_sales where bedrooms = 0;
select count(*) as propeteries_without_bedrooms from raw_sales where bedrooms = 0;
# thus there is 30 propertied without bedroom

# making sure all postal codes have 4 characters

select length(postcode) as number_character , count(length(postcode)) as n_postal_code from raw_sales
group by length(postcode); 

# Proposed questions
# 1 .Which date corresponds to the highest number of sales?

select * from raw_sales;

select datesold as `date` ,count(*) as number_of_sales from raw_sales 
group by datesold
order by number_of_sales desc limit 1;


# Find out the postcode with the highest average price per sale? 

select POSTCODE, AVG(price) as avg_price from raw_sales
group by  POSTCODE
order by  avg_price desc limit 1;


select postcode from raw_sales where price =(select max(avg(price)) from raw_sales);

# Which year witnessed the lowest number of sales?

select year(datesold) as `date`, count(*) as number_of_sales from raw_sales
group by year(datesold)
order by number_of_sales ASC limit 1;

# Use the window function to deduce the top six postcodes by year's price


CREATE TEMPORARY TABLE IF NOT EXISTS sales_1 AS
SELECT 
    YEAR(datesold) AS `year`, 
    postcode,
    price,
    DENSE_RANK() OVER (PARTITION BY YEAR(datesold), postcode ORDER BY price DESC) AS rnk
FROM raw_sales;
    
select r.year, r.postcode, r.price
FROM(
    SELECT *,
    ROW_NUMBER() OVER (PARTITION BY year ORDER BY price DESC) row_num
    FROM sales_1
    WHERE rnk < 2) r
WHERE r.row_num BETWEEN 1 AND 6;