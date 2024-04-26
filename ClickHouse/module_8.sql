-- system.clusters contains details about your clusters, servers, shards and replicas
SELECT
    cluster,
    shard_num,
    replica_num,
    database_shard_name,
    database_replica_name
FROM system.clusters;

--
SELECT event_time, query
FROM system.query_log
ORDER BY event_time DESC
LIMIT 20;

--
SELECT
    event_time,
    query
FROM clusterAllReplicas(default, system.query_log)
ORDER BY  event_time DESC
LIMIT 20;

-- returns all queries executed on the default.uk_price_paid table
SELECT
    query
FROM clusterAllReplicas(default, system.query_log)
WHERE has(tables, 'default.uk_price_paid');

-- number of queries executed on the default cluster that contain the substring 'insert'
SELECT count()
FROM clusterAllReplicas(default, system.query_log)
WHERE positionCaseInsensitive(query, 'insert') > 0;

-- counts the number of parts on whichever node handles the request
SELECT count()
FROM system.parts;

-- returns the number of all parts in default cluster
SELECT count()
FROM clusterAllReplicas(default, system.parts);

-- Ireturns details about how much memory our primary indexes are consuming on each instance in a cluster
SELECT
    instance,
    * EXCEPT instance APPLY formatReadableSize
FROM (
    SELECT
        hostname() AS instance,
        sum(primary_key_size),
        sum(primary_key_bytes_in_memory),
        sum(primary_key_bytes_in_memory_allocated)
    FROM clusterAllReplicas(default, system.parts)
    GROUP BY instance
);

--
SELECT 
    PROJECT,
    count()
FROM s3('https://datasets-documentation.s3.eu-west-3.amazonaws.com/pypi/2023/pypi_0_0_*.snappy.parquet')
GROUP BY PROJECT
ORDER BY 2 DESC
LIMIT 20;

-- uses the s3Cluster table function instead of s3
-- the cluster name in ClickHouse Cloud is default
-- query should run much faster now
SELECT
    PROJECT,
    count()
FROM s3Cluster(default,'https://datasets-documentation.s3.eu-west-3.amazonaws.com/pypi/2023/pypi_0_0_*.snappy.parquet')
GROUP BY PROJECT
ORDER BY 2 DESC
LIMIT 20;