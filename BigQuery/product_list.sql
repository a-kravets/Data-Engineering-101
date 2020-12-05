SELECT
  (p.v2ProductName) AS product_name,
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`,
  UNNEST(hits) AS hits,
  UNNEST(hits.product) AS p
GROUP BY
  product_name
ORDER BY
  product_name;