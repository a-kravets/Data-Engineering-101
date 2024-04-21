DESCRIBE s3('https://learn-clickhouse.s3.us-east-2.amazonaws.com/uk_property_prices.snappy.parquet')
-- get rid of Nullable data type
SETTINGS schema_inference_make_columns_nullable = False;

CREATE TABLE uk_price_paid
(
	price	UInt32,
	date	Date,
	postcode1	LowCardinality(String),
	postcode2	LowCardinality(String),
	type	Enum('terraced' = 1, 'semi-detached' = 2, 'detached' = 3, 'flat' = 4, 'other' = 0),
	is_new	UInt8,
	duration	Enum('freehold' = 1, 'leasehold' = 2, 'unknown' = 0),
	addr1	String,
	addr2	String,
	street	LowCardinality(String),
	locality	LowCardinality(String),
	town	LowCardinality(String),
	district	LowCardinality(String),
	county	LowCardinality(String)
)
ENGINE = MergeTree
PRIMARY KEY (postcode1, postcode2, date)

SELECT * FROM uk_price_paid 

INSERT INTO uk_price_paid SELECT *
FROM s3('https://learn-clickhouse.s3.us-east-2.amazonaws.com/uk_property_prices.snappy.parquet')

SELECT count() FROM uk_price_paid 

SELECT AVG(price)
FROM uk_price_paid 
WHERE postcode1 = 'LU1' and postcode2 = '5FT'

-- imperfect csv file 
SET format_csv_delimiter = '~';
SELECT count()
FROM s3('https://learn-clickhouse.s3.us-east-2.amazonaws.com/operating_budget.csv');

SET format_csv_delimiter = '~';
SELECT sum(actual_amount)
FROM s3('https://learn-clickhouse.s3.us-east-2.amazonaws.com/operating_budget.csv');

-- if the field is Nullable and there are null/na values, it usually treated as a String
-- if we need to make a calculation, we may use toUInt32OrZero()
SET format_csv_delimiter = '~';
SELECT sum(toUInt32OrZero(approved_amount))
FROM s3('https://learn-clickhouse.s3.us-east-2.amazonaws.com/operating_budget.csv');

SET format_csv_delimiter = '~';
DESCRIBE s3('https://learn-clickhouse.s3.us-east-2.amazonaws.com/operating_budget.csv');

CREATE TABLE operating_budget2 (
    fiscal_year LowCardinality(String),
    service LowCardinality(String),
    department LowCardinality(String),
    program LowCardinality(String),
    program_code LowCardinality(String),
    description String,
    item_category LowCardinality(String),
    approved_amount UInt32,
    recommended_amount UInt32,
    actual_amount Decimal(12,2),
    fund LowCardinality(String),
    fund_type Enum8('GENERAL FUNDS' = 1, 'FEDERAL FUNDS' = 2, 'OTHER FUNDS' = 3)
)
ENGINE = MergeTree
PRIMARY KEY (fiscal_year, program);


SET format_csv_delimiter = '~';
SELECT *
FROM s3('https://learn-clickhouse.s3.us-east-2.amazonaws.com/operating_budget.csv')
LIMIT 10;

INSERT INTO operating_budget2
    WITH
        splitByChar('(', c4) AS result
    SELECT
        c1 AS fiscal_year,
        c2 AS service,
        c3 AS department,
        result[1] AS program,
        splitByChar(')',result[2])[1] AS program_code,
        c5 AS description,
        c6 AS item_category,
        toUInt32OrZero(c7) AS approved_amount,
        toUInt32OrZero(c8) AS recommended_amount,
        toDecimal64(c9, 2) AS actual_amount,
        c10 AS fund,
        c11 AS fund_type
    FROM s3(
        'https://learn-clickhouse.s3.us-east-2.amazonaws.com/operating_budget.csv',
        'CSV',
        'c1 String,
        c2 String,
        c3 String,
        c4 String,
        c5 String,
        c6 String,
        c7 String,
        c8 String,
        c9 String,
        c10 String,
        c11 String'
        )
    SETTINGS
        format_csv_delimiter = '~',
        input_format_csv_skip_first_lines=1;
        
SELECT * FROM operating_budget2
LIMIT 10;