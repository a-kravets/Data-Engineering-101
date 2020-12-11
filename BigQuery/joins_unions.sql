  -- Finding if usaf is unique over time
SELECT
  COUNT(usaf) AS total_stations, -- 29554
  COUNT(DISTINCT usaf) AS distinct_stations -- 26155 -> not unique
FROM
  `bigquery-public-data.noaa_gsod.stations`; 

 
 -- Is usaf + wban combo unique OVER time?
SELECT
  COUNT(CONCAT(usaf,wban)) AS total_stations, -- 29554
  COUNT(DISTINCT CONCAT(usaf,wban)) AS distinct_stations -- 29554 -> yes
FROM
  `bigquery-public-data.noaa_gsod.stations`;

 
-- UNION DISTINCT removes duplicates
SELECT
  stn,
  wban,
  temp,
  year
FROM
  `bigquery-public-data.noaa_gsod.gsod1929`
UNION DISTINCT (
  SELECT
    stn,
    wban,
    temp,
    year
  FROM
    `bigquery-public-data.noaa_gsod.gsod1930`)
    
    
-- Using table wildcard (*) in the name of the table instead of union hundreds of years
SELECT
  stn,
  wban,
  temp,
  year
FROM
  `bigquery-public-data.noaa_gsod.gsod*`
  
  
-- Using _TABLE_SUFFIX with a wildcard
SELECT
	stn,
	wban,
	temp,
	YEAR,
	-- _TABLE_SUFFIX AS table_year we can use _TABLE_SUFFIX in SELECT statement
FROM
	`bgquery-public-data.noaa_gsod.gsod*`
-- All gsod tables after 1950
WHERE _TABLE_SUFFIX > '1950'


-- JOIN
SELECT
  a.stn,
  a.wban,
  a.temp,
  a.year,
  b.name,
  b.state,
  b.country
FROM
  `bigquery-public-data.noaa_gsod.gsod*` AS a
JOIN
  `bigquery-public-data.noaa_gsod.stations` AS b
ON
  a.stn=b.usaf
  AND a.wban=b.wban
WHERE
  # Filter data
  state IS NOT NULL
  AND country='US'
  AND _TABLE_SUFFIX > '2015'
LIMIT 10;


