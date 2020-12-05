-- Conversion rate calculated as number of products added to a cart divided by total number of views
SELECT
  COUNT(*) AS product_views,
  COUNT(ProductQuantity) AS orders, --10 similar items in a cart will be counted as 1
  SUM(ProductQuantity) AS num_product_orders, --10 similar items in a cart will be counted as 10
  SUM(ProductQuantity) / COUNT(ProductQuantity) AS avg_per_order,
  (COUNT(productQuantity) / COUNT(*)) AS conv_rate,
  p.v2ProductName AS product_name
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`,
  UNNEST(hits) AS hits,
  UNNEST(hits.product) AS p
WHERE type = 'PAGE'
GROUP BY v2ProductName
ORDER BY conv_rate DESC 
LIMIT 5;