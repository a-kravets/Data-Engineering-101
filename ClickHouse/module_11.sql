-- we may set compression algorithm for every column in a table
-- because every column is in a separate file
CREATE TABLE codec_example
(
	-- DoubleDelta is one of the specialized codecs
	column1 UInt32 CODEC(DoubleDelta, LZ4),
	column2 String CODEC(LZ4HC),
	column3 Float32 CODEC(NONE),
	-- LZ4HC has a configurable level
	column4 Float64 CODEC(LZ4HC(9)),
	column5 Float32 CODEC(Delta, ZSTD),
	-- creates a dictionary from the values
	column6 LowCardinality(String)
)

-- system table contains details about space used by tables 
SELECT
	name,
	formatReadableSize(data_compressed_bytes),
	formatReadableSize(data_uncompressed_bytes)
FROM system.columns
WHERE table = 'crypto_prices' 

-- returns the amount of disk space used by uk_price_paid table, along with the uncompressed size and the number of parts
SELECT
    formatReadableSize(sum(data_uncompressed_bytes) AS u) AS uncompressed,
    formatReadableSize(sum(data_compressed_bytes) AS c) AS compressed,
    round(u / c, 2) AS compression_ratio,
    count() AS num_of_parts
FROM system.parts
WHERE table = 'uk_price_paid' AND active = 1;

SELECT
    column,
    formatReadableSize(sum(column_data_uncompressed_bytes) AS u) AS uncompressed,
    formatReadableSize(sum(column_data_compressed_bytes) AS c) AS compressed,
    round(u / c, 2) AS compression_ratio
FROM system.parts_columns
WHERE table = 'uk_price_paid' AND active = 1
GROUP BY column;


-- TTL stads for Time to Live
-- specifies when the rows will be deleted + 4 hours by default
CREATE OR REPLACE TABLE ttl_demo (
    key UInt32,
    value String,
    timestamp DateTime
)
ENGINE = MergeTree
ORDER BY key
TTL timestamp + INTERVAL 1 MONTH;

-- we can set TTL for columns
CREATE OR REPLACE TABLE ttl_demo2 (
    key UInt32,
    value1 String TTL now() + INTERVAL 1 MONTH,
    value12 String TTL now() + INTERVAL 1 WEEK
)
ENGINE = MergeTree
ORDER BY key

-- if you don't want to delete data, you may aggregate it (roll up) after some period of time
CREATE OR REPLACE TABLE ttl_demo3 (
    id Int,
    x Decimal164(2),
    y Decimal132(2),
 	sum_x Decimal1256(2),
 	max_y Decimal132(2)
)
ENGINE = MergeTree
ORDER BY id 
-- it aggregates data after 1 MONTH
-- to sum_x and max_y
TTL now() + INTERVAL 1 MONTH GROUP BY id SET sum_x = sum(x), max_y = max(y)