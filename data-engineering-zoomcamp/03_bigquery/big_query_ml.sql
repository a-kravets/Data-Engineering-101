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


-- CREATE MODEL WITH DEFAULT SETTING
CREATE OR REPLACE MODEL `de-zoomcamp-407509.demo_dataset.tip_model`
OPTIONS
(model_type='linear_reg',
-- input_label_cols is what we want to predict, i.e. tip amount
input_label_cols=['tip_amount'],
-- will split the data into training & evaluation sets
DATA_SPLIT_METHOD='AUTO_SPLIT') AS
SELECT
  *
FROM
  `de-zoomcamp-407509.demo_dataset.yellow_tripdata_ml`
WHERE
tip_amount IS NOT NULL;


-- CHECK FEATURES
SELECT * FROM ML.FEATURE_INFO(MODEL `de-zoomcamp-407509.demo_dataset.tip_model`);


-- EVALUATE THE MODEL
SELECT
  *
FROM
  ML.EVALUATE(MODEL `de-zoomcamp-407509.demo_dataset.tip_model`,
  (
    SELECT
      *
    FROM
      `de-zoomcamp-407509.demo_dataset.yellow_tripdata_ml`
    WHERE
      tip_amount IS NOT NULL
    ));



-- PREDICT THE MODEL
SELECT
  *
FROM
  ML.PREDICT(MODEL `de-zoomcamp-407509.demo_dataset.tip_model`,
  (
  SELECT
    *
  FROM
    `de-zoomcamp-407509.demo_dataset.yellow_tripdata_ml`
  WHERE
    tip_amount IS NOT NULL
  ));


  -- PREDICT AND EXPLAIN
SELECT
  *
FROM
  ML.EXPLAIN_PREDICT(MODEL `de-zoomcamp-407509.demo_dataset.tip_model`,
    (
    SELECT
      *
    FROM
      `de-zoomcamp-407509.demo_dataset.yellow_tripdata_ml`
    WHERE
      tip_amount IS NOT NULL ),
    -- sets to show 3 features that had the biggest impact 
    STRUCT(3 AS top_k_features));


  -- https://cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create
  -- https://cloud.google.com/bigquery/docs/create-machine-learning-model
  -- HYPER PARAM TUNNING
CREATE OR REPLACE MODEL
  `de-zoomcamp-407509.demo_dataset.tip_model` OPTIONS (model_type='linear_reg',
    input_label_cols=['tip_amount'],
    DATA_SPLIT_METHOD='AUTO_SPLIT',
    num_trials=5,
    max_parallel_trials=2,
    l1_reg=hparam_range(0, 20),
    l2_reg=hparam_candidates([0, 0.1, 1, 10])
    ) AS
SELECT
  *
FROM
  `de-zoomcamp-407509.demo_dataset.yellow_tripdata_ml`
WHERE
  tip_amount IS NOT NULL;