-- CREATE VIEW
CREATE VIEW uk_terraced_property
AS
	SELECT *
	FROM uk_price_paid upp 
	WHERE `type` = 'terraced';

SELECT count()
FROM uk_terraced_property 

-- CREATE VIEW
CREATE VIEW london_properties_view 
AS
	SELECT 
		date, 
		price, 
		addr1, 
		addr2,
		street
	FROM uk_price_paid upp 
	WHERE town = 'LONDON'

SELECT AVG(price) FROM london_properties_view
WHERE toYear(date) = 2022

SELECT count() 
FROM uk_price_paid
WHERE town = 'LONDON';

SELECT count() FROM london_properties_view

-- EXPLAIN the query
EXPLAIN SELECT count() 
FROM london_properties_view;

-- EXPLAIN the query
EXPLAIN SELECT count() 
FROM uk_price_paid
WHERE town = 'LONDON';

-- CREATE a parametrized VIEW
-- https://clickhouse.com/docs/en/sql-reference/statements/create/view#parameterized-view
DROP VIEW IF EXISTS properties_by_town_view;
CREATE VIEW properties_by_town_view
AS
    SELECT
        date,
        price,
        addr1,
        addr2,
        street
    FROM uk_price_paid
    WHERE town = {town_filter:String};

-- querying parametrized view
SELECT
    MAX(price),
    argMax(street, price)
FROM properties_by_town_view(town_filter='LIVERPOOL');


-- CREATE MATERIALIZED VIEW can use different ORDER BY / PROMARY KEY
-- uk_proces_by_town has postcode1, postcode2, addr1, addr2 PRIMARY KEY
-- but we want to create a view with ORDER BY town to improve performance 
-- of this second type of query
CREATE MATERIALIZED VIEW uk_proces_by_town
ENGINE = MergeTree
ORDER BY town
POPULATE AS -- the best practice is not to use POPULATE, but TO 
	SELECT 
		price,
		date,
		street,
		town,
		district
	FROM uk_price_paid;


SELECT
	AVG(price),
	count()
FROM uk_price_paid 
WHERE toYear(`date`) = 2020

SELECT
	toYear(date),
	AVG(price),
	count()
FROM uk_price_paid 
GROUP BY toYear(date)


-- using TO instead of POPULATE
-- 1. create a destination table
CREATE TABLE prices_by_year_dest
(
    price UInt32,
    date Date,
    addr1 String,
    addr2 String,
    street LowCardinality(String),
    town LowCardinality(String),
    district LowCardinality(String),
    county LowCardinality(String)
)
ENGINE = MergeTree
PRIMARY KEY (town, date)
-- in reality there is rarely a need to partition by year or any other column
PARTITION BY toYear(date);

-- 2. CREATE MATERIALIZED VIEW
CREATE MATERIALIZED VIEW prices_by_year_view
TO prices_by_year_dest
AS
    SELECT
        price,
        date,
        addr1,
        addr2,
        street,
        town,
        district,
        county
    FROM uk_price_paid;

 -- 3. Insert the data
INSERT INTO prices_by_year_dest
  SELECT
  	price,
    date,
    addr1,
    addr2,
    street,
    town,
    district,
    county
FROM uk_price_paid;

SELECT * FROM system.parts
WHERE table='prices_by_year_dest';

SELECT * FROM system.parts
WHERE table='uk_price_paid';


-- let's test whether INSERT triggers INSERT into MV
INSERT INTO uk_price_paid VALUES
    (125000, '2024-03-07', 'B77', '4JT', 'semi-detached', 0, 'freehold', 10,'',	'CRIGDON','WILNECOTE','TAMWORTH','TAMWORTH','STAFFORDSHIRE'),
    (440000000, '2024-07-29', 'WC1B', '4JB', 'other', 0, 'freehold', 'VICTORIA HOUSE', '', 'SOUTHAMPTON ROW', '','LONDON','CAMDEN', 'GREATER LONDON'),
    (2000000, '2024-01-22','BS40', '5QL', 'detached', 0, 'freehold', 'WEBBSBROOK HOUSE','', 'SILVER STREET', 'WRINGTON', 'BRISTOL', 'NORTH SOMERSET', 'NORTH SOMERSET');

SELECT * FROM prices_by_year_dest
WHERE toYear(date) = '2024';

SELECT * FROM system.parts
WHERE table='prices_by_year_dest';