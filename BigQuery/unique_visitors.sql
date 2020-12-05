SELECT
  COUNT(*) AS product_views, #all rows, giving each row is a session. We can also use fullVisitorId	(CID)
  COUNT(DISTINCT fullVisitorId) AS unique_visitors
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_*`
