-- https://cloud.google.com/bigquery/docs/external-data-cloud-storage
-- Creating external table referring to gcs path
CREATE OR REPLACE EXTERNAL TABLE `demo_dataset.external_yellow_tripdata`
OPTIONS (
  format = 'parquet',
  uris = ['gs://de_zoomcamp_data_lake_de-zoomcamp-407509/yellow_tripdata_2021-01.parquet']
);

-- Creating external table referring to gcs path with multiple files
CREATE OR REPLACE EXTERNAL TABLE `demo_dataset.external_yellow_tripdata_3m`
OPTIONS (
  format = 'parquet',
  uris = [
    'gs://de_zoomcamp_data_lake_de-zoomcamp-407509/data_yellow_tripdata_2021-01.parquet',
    'gs://de_zoomcamp_data_lake_de-zoomcamp-407509/data_yellow_tripdata_2021-02.parquet',
    'gs://de_zoomcamp_data_lake_de-zoomcamp-407509/data_yellow_tripdata_2021-03.parquet'    
    ]
);

-- https://cloud.google.com/bigquery/docs/partitioned-tables
-- Create a partitioned table from external table
CREATE OR REPLACE TABLE demo_dataset.de_zoomcamp_bq_taxi_rides_partitoned
PARTITION BY
  DATE(tpep_pickup_datetime) AS
SELECT * FROM `demo_dataset.de_zoomcamp_bq_taxi_rides_de-zoomcamp-407509`;


-- Let's look into the partitons
SELECT table_name, partition_id, total_rows
FROM `demo_dataset.INFORMATION_SCHEMA.PARTITIONS`
WHERE table_name = 'de_zoomcamp_bq_taxi_rides_partitoned'
ORDER BY total_rows DESC;

-- https://cloud.google.com/bigquery/docs/creating-clustered-tables
-- Creating a partition and cluster table
CREATE OR REPLACE TABLE demo_dataset.de_zoomcamp_bq_taxi_rides_partitoned_clustered
PARTITION BY DATE(tpep_pickup_datetime)
CLUSTER BY PUlocationID AS
SELECT * FROM `demo_dataset.de_zoomcamp_bq_taxi_rides_de-zoomcamp-407509`;


schema = '''

VendorID: INTEGER, -- or FLOAT
tpep_pickup_datetime: TIMESTAMP,
tpep_dropoff_datetime: TIMESTAMP,
passenger_count: FLOAT,
trip_distance: FLOAT,
RatecodeID: FLOAT,
store_and_fwd_flag: STRING,
PULocationID: INTEGER,
DOLocationID: INTEGER,
payment_type: FLOAT,
fare_amount: FLOAT,
extra: FLOAT,
mta_tax: FLOAT,
tip_amount: FLOAT,
tolls_amount: FLOAT,
improvement_surcharge: FLOAT,
total_amount: FLOAT,
congestion_surcharge: FLOAT

'''