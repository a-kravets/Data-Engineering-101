  -- CREATE A ML TABLE
  -- Selecting only features we need
CREATE OR REPLACE TABLE
  `de-zoomcamp-407509.demo_dataset.yellow_tripdata_ml` ( `passenger_count` INTEGER,
    `trip_distance` FLOAT64,
    `PULocationID` STRING,
    `DOLocationID` STRING,
    `payment_type` STRING,
    `fare_amount` FLOAT64,
    `tolls_amount` FLOAT64,
    `tip_amount` FLOAT64 ) AS (
  SELECT
  -- Changing dtypes
    CAST(passenger_count AS INTEGER),
    trip_distance,
    CAST(PULocationID AS STRING),
    CAST(DOLocationID AS STRING),
    CAST(payment_type AS STRING),
    fare_amount,
    tolls_amount,
    tip_amount
  FROM
    `de-zoomcamp-407509.demo_dataset.external_yellow_tripdata_3m`
  WHERE
    fare_amount != 0);