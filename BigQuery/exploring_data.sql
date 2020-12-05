-- Add a LIMIT clause to limit results

SELECT
  totrevenue
FROM
  `bigquery-public-data.irs_990.irs_990_2015`
LIMIT
  10
  
-- Add an ORDER BY clause to sort results
  
SELECT
  totrevenue
FROM
  `bigquery-public-data.irs_990.irs_990_2015`
ORDER BY
  totrevenue DESC
LIMIT
  10
  
-- Add a FORMAT function to format results
/* 
SELECT FORMAT("%'d",1000) returns 1,000
https://cloud.google.com/bigquery/docs/reference/standard-sql/functions-and-operators#format_string
 */
 
SELECT
  FORMAT("%'d",totrevenue) -- !the output will be treated as a string!
FROM
  `bigquery-public-data.irs_990.irs_990_2015`
ORDER BY
  totrevenue DESC
LIMIT
  10
  
-- Filter rows using the WHERE clause

SELECT
  totrevenue AS revenue,
  ein,
  operateschools170cd AS is_school
FROM
  `bigquery-public-data.irs_990.irs_990_2015`
WHERE
  operateschools170cd = 'Y'
ORDER BY
  totrevenue DESC
LIMIT
  10
  
-- Perform calculations over values with aggregation
  
SELECT
  SUM(totrevenue) AS total_2015_revenue,
  AVG(totrevenue) AS avg_revenue,
  COUNT(ein) AS nonprofits,
  COUNT(DISTINCT ein) AS nonprofits_distinct,
  MAX(noemplyeesw3cnt) AS num_employees
FROM
  `bigquery-public-data.irs_990.irs_990_2015`
  
-- Embed functions inside of other functions

SELECT
  SUM(totrevenue) AS total_2015_revenue,
  ROUND(AVG(totrevenue),2) AS avg_revenue, -- ROUND() is inside AVG()
  COUNT(ein) AS nonprofits,
  COUNT(DISTINCT ein) AS nonprofits_distinct,
  MAX(noemplyeesw3cnt) AS num_employees
FROM
  `bigquery-public-data.irs_990.irs_990_2015`
  
-- Create aggregation groupings with GROUP BY

SELECT
  ein, -- not aggregated
  COUNT(ein) AS ein_count -- aggregated
FROM
  `bigquery-public-data.irs_990.irs_990_2015`
GROUP BY
  ein
ORDER BY
  ein_count DESC
  
-- Filter aggregations with HAVING clause

SELECT
  ein,
  COUNT(ein) AS ein_count
FROM
  `bigquery-public-data.irs_990.irs_990_2015`
GROUP BY
  ein
HAVING
  ein_count > 1
ORDER BY
  ein_count DESC
  
-- Parse, convert, filter
-- https://cloud.google.com/bigquery/docs/reference/standard-sql/functions-and-operators#extract
-- https://cloud.google.com/bigquery/docs/reference/standard-sql/functions-and-operators#parse_date
  
SELECT
  ein,
  tax_pd,
  PARSE_DATE('%Y%m', CAST(tax_pd AS STRING)) AS tax_period
FROM
  `bigquery-public-data.irs_990.irs_990_2015`
WHERE
  EXTRACT(YEAR
  FROM
    PARSE_DATE('%Y%m', CAST(tax_pd AS STRING)) ) = 2014
LIMIT
  10
  
-- Using CAST to convert between data types

CAST("12345" AS INT64) -- 12345
CAST("2017-08-01" AS DATE) --2017-08-01
CAST(1112223333 AS STRING) -- "1112223333"
SELECT SAFE_CAST("apple" AS INT64) -- NULL  
  
-- Handle NULL values  
  
SELECT
  ein,
  street,
  city,
  state,
  zip
FROM
  `bigquery-public-data.irs_990.irs_990_ein`
WHERE
  state IS NULL
LIMIT
  10;  
  
-- Parsing string values with string functions
  
CONCAT("12345","678") -- "12345678"
ENDS_WITH("Apple","e") -- true
LOWER("Apple") -- "apple"
REGEXP_CONTAINS("Lunchbox",r"^*box$") -- true  
  
-- YYYY-MM-DD is the expected format for dates
CURRENT_DATE([time_zone]) -- Today’s date
EXTRACT(year FROM your_date_field) -- Year of date (try changing Year to Month, Day, Week etc.)
DATE_ADD(DATE "2008-12-25", INTERVAL 5 DAY) -- Adds an interval of time
SELECT DATE_SUB(DATE "2008-12-25", INTERVAL 5 DAY) -- Subtracts an interval of time
DATE_DIFF(DATE "2010-07-07", DATE "2008-12-25", DAY) -- Subtracts two dates and returns the interval
DATE_TRUNC(DATE '2008-12-25', MONTH) -- Truncates the date (e.g. 2008-12-01)
FORMAT_DATETIME( ) -- Formats an existing date to a different date string format
PARSE_DATETIME( ) -- Example: Turn “12/01/2017” to a proper date “2017-12-01”
  
  
  
  