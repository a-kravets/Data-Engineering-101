# Top 5 products by views
# In GA a view is a product of the following interaction types:
# page, screenview, event, transaction, item, social, exception, timing
SELECT
  COUNT(*) AS product_views,
  p.v2ProductName AS product_name
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`,
  UNNEST(hits) AS hits,
  UNNEST(hits.product) AS p
WHERE type = 'PAGE'
GROUP BY v2ProductName
ORDER BY product_views DESC
LIMIT 5;