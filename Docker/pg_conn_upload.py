#!/usr/bin/env python
# coding: utf-8

# In[44]:


import pandas as pd
from sqlalchemy import create_engine, text as sql_text
import wget


# In[20]:


# downloading the file

wget.download('https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz')


# In[45]:


# creating the engine with credentials

engine = create_engine('postgresql://root:root@localhost:5432/ny_taxi')


# In[46]:


# checking connection

engine.connect()


# In[47]:


# testing if we may run a query

query = """
SELECT 1 as number;
"""


# In[48]:


# https://stackoverflow.com/questions/75309237/read-sql-query-throws-optionengine-object-has-no-attribute-execute-with

pd.read_sql_query(con=engine.connect(), sql=sql_text(query))


# In[49]:


# checking what table we have in our pg database

query = """
SELECT *
FROM pg_catalog.pg_tables
WHERE schemaname != 'pg_catalog' AND 
    schemaname != 'information_schema';
"""


# In[50]:


# we already have ny_taxi table we've created before

pd.read_sql_query(con=engine.connect(), sql=sql_text(query))


# In[28]:


# reading the 1st 100 rows from our new file
# decompressing it from gzip

df = pd.read_csv("yellow_tripdata_2021-01.csv.gz", nrows=100, compression='gzip')
df.head()


# In[29]:


# checking how our table structure will look like
# this is the statement Pandas will execute when it'll be creating this table

print(pd.io.sql.get_schema(df, name='yellow_taxi_data', con=engine))


# In[31]:


# converting tpep_pickup_datetime & tpep_dropoff_datetime from TEXT to datetime

df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)

print(pd.io.sql.get_schema(df, name='yellow_taxi_data', con=engine))


# In[32]:


# we don't want to upload the whole file, as it's too big
# for this reason we'll split it into chunks of 100000

df_iter = pd.read_csv("yellow_tripdata_2021-01.csv.gz", iterator=True, chunksize=100000, compression='gzip')


# In[33]:


# if we print it, we see that it's not a DataFrame, it's an iterator

df_iter


# In[34]:


# next() takes the next chunk

df = next(df_iter)


# In[35]:


len(df)


# In[ ]:


df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)


# In[37]:


df.head(5)


# In[38]:


df.head(0)


# In[39]:


# in order to create the table in pg, we may isert only 1st row, that is column names

df.head(n=0).to_sql(name='yellow_taxi_data', con=engine, if_exists='replace')


# In[40]:


# checking

pd.read_sql_query(con=engine.connect(), sql=sql_text(query))


# In[41]:


from time import time

while True: 
    t_start = time()

    # when all the chunks will be uploaded, it'll throw an exception
    df = next(df_iter)

    df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
    df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)
    
    df.to_sql(name='yellow_taxi_data', con=engine, if_exists='append')

    t_end = time()

    print('inserted another chunk, took %.3f second' % (t_end - t_start))


# In[51]:


# checking

query = """
SELECT COUNT(1) FROM yellow_taxi_data;
"""

pd.read_sql_query(con=engine.connect(), sql=sql_text(query))


# In[ ]:





# In[ ]:





# In[ ]:




