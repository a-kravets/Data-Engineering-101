# Standard SQL
# checking for duplicate rows
SELECT #selecting all columns
  end_date,
  country,
  city,
  devicecategory,
  browser,
  sourcemedium,
  start_date,
  pageviews,
  organicsearches,
  COUNT(*) AS rows_count
FROM
  `project_name.dataset_name.table_name`
GROUP BY
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9
HAVING
  rows_count > 1 #find duplicates