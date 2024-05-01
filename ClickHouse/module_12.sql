-- Projections are just like VIEWS and enable us to add additional sorting 
-- but they're stored in the subfolder of  the part folder
-- and no MATERIALIZED VIEW / table is created
-- we can set projections when creating tables or add to existing tables
-- when adding a projection, it's applied to new rows that are being inserted to the table
ALTER TABLE uk_price_paid 
	ADD PROJECTION town_sort_projection (
		SELECT
			-- we can pick all columns or just a few we need for queries
			town, price, date, street, locality
			-- sort the data in the projection by town
			-- original table has different sorting
			ORDER BY town
	)
	
-- the projection is applied after the MERGE 
-- we don't have to wait and can MATERIALIZE PROJECTION
-- after that queries on town will become way faster
ALTER TABLE uk_price_paid 
MATERIALIZE PROJECTION town_sort_projection;

-- we can check the mutations
SELECT * FROM system.mutations

-- adding EXPLAIN clause will show how the query was executed (steps)
-- last step would be 'ReadFromMergeTree (town_sort_projection)'
EXPLAIN SELECT
	avg(price)
FROM uk_price_paid upp 
WHERE town = 'DURHAM'


-- instead of ORDER BY we may pre-aggregate data with GROUP BY
-- this way the max(price) of each town will be stored for each part
ALTER TABLE uk_price_paid 
	ADD PROJECTION max_town_price_projection (
		SELECT
			town,
			max(price)
		GROUP BY town
	)
	

	
-- MATERIALIZED VIEWS and PROJECTIONS are great, but they store the data twice
-- so we may use skipping index 
-- https://clickhouse.com/docs/en/optimize/skipping-indexes
-- it's built on top of existing sort order of the data and existing granules
-- and builds, if we may, an additional sub index based on the existing order
ALTER TABLE uk_price_paid 
	ADD INDEX town_set_index town
	-- type of index is set, 10 means it'll store not more than 10 values (unique towns) in each set
	TYPE set(10)
	-- with 3 granules which means we're skipping 3 granules
	GRANULARITY 3;

ALTER TABLE uk_price_paid 
	MATERIALIZE INDEX town_set_index
