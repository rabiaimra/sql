/* ASSIGNMENT 1 */
/* SECTION 2 */


--SELECT
/* 1. Write a query that returns everything in the customer table. */
SELECT * 
FROM customer;


/* 2. Write a query that displays all of the columns and 10 rows from the cus- tomer table, 
sorted by customer_last_name, then customer_first_ name. */
SELECT * 
FROM customer
ORDER BY customer_last_name, customer_first_name
LIMIT 10;


--WHERE
/* 1. Write a query that returns all customer purchases of product IDs 4 and 9. */
-- option 1
SELECT * 
FROM customer_purchases
WHERE product_id = 4 
OR product_id = 9;

-- option 2
SELECT * 
FROM customer_purchases
WHERE product_id IN (4,9);

/*
Just to check: 
SELECT DISTINCT product_id
FROM customer_purchases;
*/


/*2. Write a query that returns all customer purchases and a new calculated column 'price' (quantity * cost_to_customer_per_qty), 
filtered by vendor IDs between 8 and 10 (inclusive) using either:
	1.  two conditions using AND
	2.  one condition using BETWEEN
*/
-- option 1
SELECT *, quantity*cost_to_customer_per_qty AS price
FROM customer_purchases
WHERE vendor_id >= 8 AND vendor_id <= 10;


-- option 2
SELECT *, quantity*cost_to_customer_per_qty AS price
FROM customer_purchases
WHERE vendor_id BETWEEN 8 AND 10;

/*Just to check: 
SELECT DISTINCT vendor_id 
FROM customer_purchases;
*/


--CASE
/* 1. Products can be sold by the individual unit or by bulk measures like lbs. or oz. 
Using the product table, write a query that outputs the product_id and product_name
columns and add a column called prod_qty_type_condensed that displays the word “unit” 
if the product_qty_type is “unit,” and otherwise displays the word “bulk.” */
SELECT product_id, product_name
,CASE WHEN product_qty_type = 'unit'
	THEN 'unit'
	ELSE 'bulk' -- CAUTION: In addition to 'lbs', there are also NULL observations in product_qty_type columns. So this command (as requested by the assignment) displays 'bulk' for both 'lbs' and NULL observations.   	
END AS prod_qty_type
FROM product;


/* 2. We want to flag all of the different types of pepper products that are sold at the market. 
add a column to the previous query called pepper_flag that outputs a 1 if the product_name 
contains the word “pepper” (regardless of capitalization), and otherwise outputs 0. */
SELECT product_id, product_name
,CASE WHEN product_qty_type = 'unit'
	THEN 'unit'
	ELSE 'bulk' -- CAUTION: In addition to 'lbs', there are also NULL observations in product_qty_type columns. So this command (as requested by the assignment) displays 'bulk' for both 'lbs' and NULL observations.  	
END AS prod_qty_type
, CASE WHEN LOWER(product_name) LIKE '%pepper%'
	THEN 1
	ELSE 0	
END AS pepper_flag
FROM product;

--JOIN
/* 1. Write a query that INNER JOINs the vendor table to the vendor_booth_assignments table on the 
vendor_id field they both have in common, and sorts the result by vendor_name, then market_date. */
SELECT 
v.*, vba.*
FROM vendor v 
INNER JOIN vendor_booth_assignments vba
	ON v.vendor_id = vba.vendor_id
ORDER BY v.vendor_name, vba.market_date;


/* Just to check
SELECT DISTINCT vendor_id 
FROM vendor;

SELECT DISTINCT vendor_id
FROM vendor_booth_assignments;

SELECT DISTINCT v.vendor_id, vba.vendor_id 
FROM vendor v 
INNER JOIN vendor_booth_assignments vba
	ON v.vendor_id = vba.vendor_id;
*/

/* SECTION 3 */

-- AGGREGATE
/* 1. Write a query that determines how many times each vendor has rented a booth 
at the farmer’s market by counting the vendor booth assignments per vendor_id. */
SELECT 
vendor_id, COUNT(market_date) as no_of_booths
FROM vendor_booth_assignments
GROUP BY vendor_id;


/* 2. The Farmer’s Market Customer Appreciation Committee wants to give a bumper 
sticker to everyone who has ever spent more than $2000 at the market. Write a query that generates a list 
of customers for them to give stickers to, sorted by last name, then first name. 

HINT: This query requires you to join two tables, use an aggregate function, and use the HAVING keyword. */
SELECT 
cp.customer_id, customer_last_name, customer_first_name,
SUM(quantity*cost_to_customer_per_qty) AS spending

FROM customer_purchases cp
INNER JOIN customer c
	ON cp.customer_id = c.customer_id

GROUP BY cp.customer_id, customer_last_name, customer_first_name
HAVING spending > 2000
ORDER BY customer_last_name, customer_first_name;

--Temp Table
/* 1. Insert the original vendor table into a temp.new_vendor and then add a 10th vendor: 
Thomass Superfood Store, a Fresh Focused store, owned by Thomas Rosenthal

HINT: This is two total queries -- first create the table from the original, then insert the new 10th vendor. 
When inserting the new vendor, you need to appropriately align the columns to be inserted 
(there are five columns to be inserted, I've given you the details, but not the syntax) 

-> To insert the new row use VALUES, specifying the value you want for each column:
VALUES(col1,col2,col3,col4,col5) 
*/

-- Drop the table if it already exists
DROP TABLE IF EXISTS new_vendor;

-- Create a temporary table `new_vendor` by copying the original `vendor` table
CREATE TEMP TABLE new_vendor AS
SELECT *
FROM vendor;

-- Insert a new vendor (10th vendor) into `new_vendor`
INSERT INTO temp.new_vendor (vendor_id,vendor_name,vendor_type,vendor_owner_first_name,vendor_owner_last_name) 
VALUES (10,'Thomass Superfood Store','Fresh Focused','Thomas','Rosenthal');

-- Display the contents of `new_vendor` to verify the insert
SELECT * 
FROM temp.new_vendor;

-- Date
/*1. Get the customer_id, month, and year (in separate columns) of every purchase in the customer_purchases table.

HINT: you might need to search for strfrtime modifers sqlite on the web to know what the modifers for month 
and year are! */

SELECT customer_id, 
strftime('%m', date (market_date)) AS "month", 
strftime('%Y', date (market_date)) AS "year" 

FROM customer_purchases

ORDER BY year, month;

/* 2. Using the previous query as a base, determine how much money each customer spent in April 2022. 
Remember that money spent is quantity*cost_to_customer_per_qty. 

HINTS: you will need to AGGREGATE, GROUP BY, and filter...
but remember, STRFTIME returns a STRING for your WHERE statement!! */

SELECT customer_id, 
strftime('%m', date (market_date)) AS "month", 
strftime('%Y', date (market_date)) AS "year", 
SUM(quantity*cost_to_customer_per_qty) AS spending

FROM customer_purchases

WHERE strftime('%Y', date (market_date)) = '2022' 
AND strftime('%m', date (market_date)) = '04'

GROUP BY customer_id, year, month;