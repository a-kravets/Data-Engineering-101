-- ClickHouse playground
-- https://fiddle.clickhouse.com/

-- available data types
select * from system.data_type_families

CREATE DATABASE test_db;

CREATE TABLE test_db.test_table (
	name String,
	birthday Date,
	age UInt8
)
ENGINE = MergeTree
PRIMARY KEY name;

-- add another column to existing table
ALTER TABLE test_db.test_table
	ADD COLUMN meetings Array(DateTime);

-- returns create table command
SHOW CREATE TABLE test_db.test_table;

INSERT INTO test_db.test_table VALUES 
	('Bob', '1985-05-05', 39, ['2024-01-01 09:00:00', '2024-02-02 10:10:01']),
	('Jake', '1984-09-12', 40, ['2024-04-01 18:00:00', '2024-04-02 11:01:11']),
	('John', '1979-09-12', 45, [now(), now() - INTERVAL 1 WEEK])
	
-- Array is 1-based, meaning the count starts from 1
	SELECT name, meetings[1] FROM test_db.test_table
	
ALTER TABLE test_db.test_table
	ADD COLUMN size UInt32,
	ADD COLUMN metrics Nullable(UInt32)

SELECT * FROM test_db.test_table

-- if we don't pass value, it'll take the default value for a specific datatype, i.e. 0 for Int
-- if a field if Nullable, it'll be NULL
-- Nullable creates additional hidden field that is 1 or 0 depending on existance of a value
INSERT INTO test_db.test_table VALUES 
	('Bob2', '1985-05-05', 39, ['2024-01-01 09:00:00', '2024-02-02 10:10:01'], NULL, 54),
	('Jake2', '1984-09-12', 40, ['2024-04-01 18:00:00', '2024-04-02 11:01:11'], 1, NULL)
	
ALTER TABLE test_db.test_table
	ADD COLUMN note String

-- alternatively for String data type the default value is empty string or ''
-- for date it's '1970-01-01'
INSERT INTO test_db.test_table (name, note) VALUES
	('Mary', 'no comment')
	('Jane', NULL)

-- enum data type presented as a string, but stored under the hood as an integer
-- which is effective for tables with huge number of rows
-- the only downside, if you try to insert a string that is not in Enum list, it'll throw an error
CREATE TABLE test_db.test_enum
(
	device_id UInt32,
	device_type Enum('server' = 1, 'container' = 2, 'router' = 3)
)
ENGINE = MergeTree
PRIMARY KEY device_id;

INSERT INTO test_db.test_enum VALUES
	(12, 'server')
	(45, 'router')
	
SELECT * FROM test_db.test_enum

-- LowCardinality is just like Enum, but
-- LowCardinality addresses this downside of Enum and allows to add new values dynamically
-- you don't have to know all the potential values in advance
CREATE TABLE test_db.test_lowcardinality
(
	device_id UInt32,
	device_type LowCardinality(String)
)
ENGINE = MergeTree
PRIMARY KEY device_id;

INSERT INTO test_db.test_lowcardinality VALUES
	(12, 'server')
	(45, 'router')
	
SELECT * FROM test_db.test_lowcardinality

-------------------

DESCRIBE pypi;

-- uniqExact() returns the unique number of values for the column
SELECT
    uniqExact(COUNTRY_CODE),
    uniqExact(PROJECT),
    uniqExact(URL)
FROM pypi;

SHOW CREATE TABLE pypi2

CREATE TABLE default.pypi4
(
    `TIMESTAMP` DateTime,
    `COUNTRY_CODE` LowCardinality(String),
    `URL` String,
    `PROJECT` LowCardinality(String)
)
ENGINE = MergeTree
PRIMARY KEY (PROJECT, TIMESTAMP)
ORDER BY (PROJECT, TIMESTAMP)

INSERT INTO pypi4 select *
from s3('https://datasets-documentation.s3.eu-west-3.amazonaws.com/pypi/2023/pypi_0_7_34.snappy.parquet')

-- check how much size our tables use
SELECT
    table,
    formatReadableSize(sum(data_compressed_bytes)) AS compressed_size,
    formatReadableSize(sum(data_uncompressed_bytes)) AS uncompressed_size,
    count() AS num_of_active_parts
FROM system.parts
WHERE (active = 1) AND (table LIKE 'pypi%')
GROUP BY table;

SELECT
    toStartOfMonth(TIMESTAMP) AS month,
    count() AS count
FROM pypi4
WHERE COUNTRY_CODE = 'US'
GROUP BY
    month
ORDER BY
    month ASC,
    count DESC;

DESCRIBE s3('https://learnclickhouse.s3.us-east-2.amazonaws.com/datasets/crypto_prices.parquet');

DROP TABLE IF EXISTS crypto_prices
CREATE TABLE crypto_prices
(
    trade_date Date,
    crypto_name LowCardinality(String),
    volume Float32,
    price Float32,
    market_cap Float32,
    change_1_day Float32
)
ENGINE = MergeTree
PRIMARY KEY (crypto_name, trade_date)

INSERT INTO crypto_prices SELECT 
    trade_date,
    crypto_name,
    volume,
    price,
    market_cap,
    change_1_day 
FROM s3('https://learnclickhouse.s3.us-east-2.amazonaws.com/datasets/crypto_prices.parquet');


SELECT COUNT() FROM crypto_prices

SELECT COUNT()
FROM crypto_prices
WHERE volume >= 1000_000

SELECT AVG(price)
FROM crypto_prices
WHERE crypto_name = 'Bitcoin'

SELECT AVG(price)
FROM crypto_prices
WHERE crypto_name ILIKE 'B%'