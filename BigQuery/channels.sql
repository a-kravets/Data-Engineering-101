SELECT
  channelGrouping,
  COUNT(DISTINCT fullVisitorId) AS unique_visitors
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`
GROUP BY channelGrouping
ORDER BY unique_visitors DESC;