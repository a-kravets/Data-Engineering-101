-- Product views, orders and prodcut name
-- ProductQuantity shows items added TO a cart, NOT necessarily bought
SELECT
  COUNT(*) AS product_views,
  COUNT(ProductQuantity) AS orders, --10 similar items in a cart will be counted as 1
  SUM(ProductQuantity) AS num_product_orders, --10 similar items in a cart will be counted as 10
  SUM(ProductQuantity) / COUNT(ProductQuantity) AS avg_per_order, --how many items ppl buy per order
  p.v2ProductName AS product_name
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`,
  UNNEST(hits) AS hits,
  UNNEST(hits.product) AS p
WHERE type = 'PAGE'
GROUP BY v2ProductName
ORDER BY product_views DESC --we can order by orders instead
LIMIT 5;