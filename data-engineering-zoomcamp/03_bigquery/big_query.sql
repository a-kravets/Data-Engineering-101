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