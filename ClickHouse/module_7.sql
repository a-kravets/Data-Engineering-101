-- if we need aggregated columns in MATERIALIZED VIEW
-- we need to use different approach
-- and use SummingMergeTree ENGINE for summs or AggregatingMergeTree for other types
-- SummingMergeTree is just a running total
-- https://clickhouse.com/docs/en/engines/table-engines/mergetree-family/aggregatingmergetree
-- https://clickhouse.com/docs/en/engines/table-engines/mergetree-family/summingmergetree

-- 1. Create a destination table with AggregatingMergeTree
-- If it contained only sum, we would use ENGINE = SummingMergeTree
DROP TABLE IF EXISTS prices_sum_dest;
CREATE TABLE prices_sum_dest
(
    town LowCardinality(String),
    avg_price AggregateFunction(avg, Float64),
    max_price SimpleAggregateFunction(max, UInt64),
    sum_price SimpleAggregateFunction(sum, UInt64)
)
ENGINE = AggregatingMergeTree
PRIMARY KEY town;

-- 2. CREATE MATERIALIZED VIEW with TO
-- use State combinator to aggregations
DROP VIEW IF EXISTS prices_sum_view;
CREATE MATERIALIZED VIEW prices_sum_view
TO prices_sum_dest
AS
    SELECT
        town,
        avgState(toFloat64(price)) AS avg_price,
        maxSimpleState(price) AS max_price,
        sumSimpleState(price) AS sum_price
    FROM uk_price_paid
    GROUP BY town;

-- 3. Insert the data to the destination table
INSERT INTO prices_sum_dest
    SELECT
        town,
        avgState(toFloat64(price)),
        max(price),
        sum(price)
    FROM uk_price_paid
    GROUP BY town;

-- 4. to query aggregated MATERIALIZED VIEW we need to add the appropriate function
-- avgMerge()for AVG, max() & sum() for MAX & SUM
-- https://clickhouse.com/docs/en/sql-reference/data-types/aggregatefunction
-- https://clickhouse.com/docs/en/sql-reference/data-types/simpleaggregatefunction
SELECT
	town,
	avgMerge(avg_price),
	max(max_price),
	sum(sum_price)
FROM prices_sum_dest
GROUP BY town;