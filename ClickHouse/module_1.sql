show tables in system;

-- returns the data / table function
SELECT *
FROM s3('.parquet')
LIMIT 10

--returns data types
DESCRIBE s3('.parquet')

-- reads 3 files
select formatReadableQuantity(count(*))
from s3('https://learnclickhouse.s3.us-east-2.amazonaws.com/datasets/crypto_prices{1..3}.parquet')
limit 100;


select trim(crypto_name), formatReadableQuantity(count(*))
from s3('https://learnclickhouse.s3.us-east-2.amazonaws.com/datasets/crypto_prices.parquet')
group by 1
order by 1
limit 100;

describe s3('https://learnclickhouse.s3.us-east-2.amazonaws.com/datasets/crypto_prices.parquet');


select toStartOfMonth(toDate(trade_date)), max(price)
from s3('https://learnclickhouse.s3.us-east-2.amazonaws.com/datasets/crypto_prices.parquet')
group by 1
limit 100;