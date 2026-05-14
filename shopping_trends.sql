-- Create staging table
CREATE TABLE shopping_trends_staging
LIKE shopping_trends;

-- Check empty staging table
SELECT * 
FROM shopping_trends_staging;

-- Insert into staging table
INSERT shopping_trends_staging
SELECT *
FROM shopping_trends;

-- Check duplicates
SELECT *,
ROW_NUMBER() OVER(PARTITION BY `customer id`, age, gender
, `Item purchased`, `Category`, `Purchase Amount (USD)`
, Location, Size, Color, Season, `Review Rating`, `Subscription Status`, `Payment Method`
, `Shipping Type`, `Discount Applied`, `Promo Code Used`
, `Previous Purchases`, `Preferred Payment Method`, `Frequency of Purchases`)
FROM shopping_trends_staging;

-- Check NULL values
-- No null values found
SELECT *
FROM shopping_trends_staging
WHERE age IS NULL;

-- Question
-- 1. How many unique customers have visited the store during the time period provided? 
SELECT 
	count(DISTINCT`Customer ID`) as total_customers
FROM shopping_trends_staging;
-- We have total 3900

-- 2. Should the store more male or female clothing?  
-- (What % of customers are male vs. female?)
SELECT 
	gender, count(gender) as total_customers
FROM shopping_trends_staging
GROUP BY gender;

SELECT 
	gender, count(gender) as total_customers,
    ROUND(count(gender) * 100.0 / sum(count(gender)) over (),2) as percentage
from shopping_trends_staging
GROUP by gender;
-- 68% are male and 32% are female

SELECT 
	gender, count(gender) as total_cutsomers
FROM shopping_teends_staging
GROUP BY gender


-- 3. How many customers for category ?
SELECT category,
	count(`customer id`) as total_customers
FROM shopping_trends_staging
GROUP BY category;
-- we have clothing (1737), footwear (599), outerwear (324), accessories (1240)


-- 4. How many average Purchase Amount (USD)  for each gender?
SELECT gender,
	avg(`purchase amount (usd)`) as avg_purchase
from shopping_trends_staging
group by gender;



-- 5. What seasons are represented in the data?

-- Data profilling
SELECT  DISTINCT season
FROM  shopping_trends_staging;
'Winter'
'Spring'
'Summer'
'Fall'

-- Frequency distribution
SELECT season,
COUNT(season) as total
FROM shopping_trends_staging
GROUP BY season;
-- 'Winter' are 971
-- 'Spring' are 999
-- 'Summer' are 955
-- 'Fall' are 975

-- Percentage distribution
SELECT season,
	count(season) as total,
	ROUND(count(season) * 100.0 / sum(count(season)) over(), 2) AS percentage
from shopping_trends_staging
GROUP BY season;
-- 'Winter' are 24.90%
-- 'Spring' are 25.62%
-- 'Summer' are 24.49%
-- 'Fall' are 25%

-- 6.What are the most purchased categories and/or items by season?

SELECT
	season,
count(category) as total
FROM shopping_trends_staging
group by 1
order by 2 desc;
-- spring (999), fall(975), winter(971), summer (955)

-- 7.What are the most popular item purchased by season? 

with ranked as(
select 
	season, 
	`item purchased`,
	count(*) as total,
    row_number() OVER(PARTITION BY season order by count(*) desc) as rn
from shopping_trends_staging
group by season, `item purchased`
)
select 
	season,
    `item purchased`, 
    total
from ranked
where rn = 1;
-- fall (jaket = 54), spring (sweater= 52), summer (pants = 50), winter (sunglasses = 50)


-- 8.Which locations have the highest number of customers?
SELECT
	location,
    count(`Customer ID`) as total
FROM shopping_trends_staging
group by 1
order by total desc
limit 3;

-- 9.Which locations are top-performing in terms of customer experience?
SELECT 
	location,
    round(avg(`Review Rating`), 2)as avg_rating
FROM shopping_trends_staging
group by 1
order by 2 desc;
-- location  such as texas and wisconsin have ratings above 3.88 hence other location perform lower

-- 10.Does having more than 10 previous purchases correlate with higher total spend?
SELECT 	
	case
		when `Previous Purchases` >= 10 then 'more than 10'
        else 'less than 10'
	end as previous_purchases_status,
round(sum(`Purchase Amount (USD)`), 2) as total_purchase_amount
FROM shopping_trends_staging
group by 1
order by 2 desc;

-- Yess, customers who made higher number or purchases previously, maintain the trend of higher  purchases when they return,
-- they would be good target segment to target with any campaigns

    
    
 
