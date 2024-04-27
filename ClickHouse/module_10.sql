-- CREATE TABLE with ReplacingMergeTree engine
-- it leaves the last row inserted with the same PRIMARY KEY / ORDER BY
-- and deletes (during merge) all the other duplicates
CREATE TABLE duplicate_demo (
	x UInt32,
	y String
)
ENGINE = ReplacingMergeTree
PRIMARY KEY x;

INSERT INTO duplicate_demo VALUES
	(1, 'hello'),
	(2, 'world')

-- it'll replace row based on PRIMARY KEY / ORDER BY column of the table 
INSERT INTO duplicate_demo VALUES
	(1, 'what\'s up')

-- but it still returns both rows with x = 1
-- because CH needs time to merge parts
SELECT * FROM duplicate_demo dd 

-- if we want to get the final result right away
-- use FINAL after the table name
SELECT * FROM duplicate_demo FINAL;

-- we can force MERGE to happen
-- but in reality we rarely want to do that
OPTIMIZE TABLE duplicate_demo FINAL;

-- instead of relying on last row inserted logic,
-- we may use versioning
-- for example, ReplacingMergeTree has a ver parameter
-- if you have a column where values are always increasing, like datetime,
-- it's a perfect column to use for versioning
-- this way (passing ver parametr), merge will beb based on last ver of row

-- CREATE TABLE with CollapsingMergeTree engine
-- and passing sign (1, -1) column. it doesn't have to be named sign
CREATE TABLE url_hits (
	url String,
	hits UInt64,
	sign Int8
)
ENGINE = CollapsingMergeTree(sign)
PRIMARY KEY url;


INSERT INTO url_hits VALUES
	('index.html', 25, 1),
	('info.html', 9, 1);
	
SELECT * FROM url_hits 

-- now we'll have 4 rows in the table
-- before CollapsingMerge will be executed
INSERT INTO url_hits VALUES
	('index.html', 25, -1),
	('index.html', 32, 1);

-- there 4 rows now
SELECT * FROM url_hits 

-- if we want to get the relevant result, use FINAL
SELECT * FROM url_hits FINAL;

-- if we want to delete a row, we may pass its PRIMARY KEY with -1 sign
-- it'll be deleted after the merge
-- and right away it'll not be returned with FINAL
INSERT INTO url_hits(url, sign) VALUES
	('info.html', -1);
	
-- in order to avoid using FINAL, we may just multiply value by sign 
SELECT
	url,
	sum(hits * sign)
FROM url_hits 
GROUP BY url

-- there is also VersionedCollapsingMergeTree