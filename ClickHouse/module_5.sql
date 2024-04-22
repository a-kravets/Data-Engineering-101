-- https://clickhouse.com/docs/en/interfaces/formats
-- returns output in JSON format
SELECT 
	town,	
	AVG(price)
FROM uk_price_paid upp
GROUP by town 
LIMIT 10
FORMAT JSONEachRow;

-- returns output in vertical format
SELECT 
	town,	
	AVG(price)
FROM uk_price_paid upp
GROUP by town 
LIMIT 10
FORMAT Vertical;

-- using with clause
WITH
	'LONDON' AS my_town
SELECT 
	AVG(price)
FROM uk_price_paid upp 
WHERE town = my_town;

-- any() grabs any value
SELECT 
	town,
	any(district), 
	AVG(price)
FROM uk_price_paid upp
GROUP by town 
LIMIT 10

-- functions https://clickhouse.com/docs/en/sql-reference/functions
-- lower case
SELECT
	lower(town)
FROM uk_price_paid upp 
LIMIT 10

-- quantile()
SELECT
	quantile(0.75)(price)
FROM uk_price_paid upp 

-- https://clickhouse.com/docs/en/sql-reference/functions/date-time-functions
-- https://clickhouse.com/docs/en/sql-reference/functions/string-functions
-- https://clickhouse.com/docs/en/sql-reference/functions/string-search-functions
-- https://clickhouse.com/docs/en/sql-reference/functions/string-replace-functions

-- if it's > 1, it found
SELECT
	count()
FROM uk_price_paid upp 
WHERE position(street, 'KING') > 1

-- multiFuzzyMatchAny() searches for any term which N chars away from the term
-- if it's 1, it has to be 1 char away
SELECT
	count()
FROM uk_price_paid upp 
WHERE multiFuzzyMatchAny(street, 1, ['KING'])

-- argMax() returns the max price in every town by street w/o grouping by
SELECT
	town,
	max(price),
	argMax(street, price)
FROM uk_price_paid upp 
GROUP BY town

-- over 1513 functions
SELECT count()
FROM system.functions;

-- https://clickhouse.com/docs/en/sql-reference/aggregate-functions/combinators
--Using the topK function, write a query that returns the top 10 towns that are not London with the most properties sold
SELECT topKIf(10)(town, town != 'LONDON')
FROM uk_price_paid;

-- return the average price of properties for each type (detached, semi-detached, terraced, flat, and other)
SELECT
    avgIf(price, type = 'detached'),
    avgIf(price, type = 'semi-detached'),
    avgIf(price, type = 'terraced'),
    avgIf(price, type = 'flat'),
    avgIf(price, type = 'other')
FROM uk_price_paid;

--Write a query that returns the price of the most expensive property in each town divided by the price of the most expensive property
--in the entire dataset. Sort the results in descending order of the computed result.
SELECT 
	town,
	MAX(price) / (SELECT max(price) FROM uk_price_paid upp) 
FROM uk_price_paid upp2 
GROUP BY town 
ORDER BY 2 DESC;

WITH (
    SELECT max(price)
    FROM uk_price_paid
) AS overall_max
SELECT
    town,
    max(price) / overall_max
FROM uk_price_paid
GROUP BY town
ORDER BY 2 DESC;