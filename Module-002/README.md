# INTRODUCTION

Existing business wants to analyze the data they've been collecting on sales and customers.

They would like to create a Postgres database with tables designed to optimize queries on analysis.

# DATABASE SCHEMA DESIGN

I choose a star schema design for this project because it's simple and straightforward.
This will help the analytic team to get the most information and do their analysis in the most efficient way.

In my star schema, there will be a fact table and few dimensional tables:

**Fact table:** sales_fact.

**Dimension tables:** shipping_dim, customer_dim, geo_dim, product_dim, calendar_dim.

# ETL PIPELINE

My ETL pipline is structured to read data from OLTP table (orders in csv), create Postgres database, insert values and process create a new schema and load data.

# FILES

This project has two final files:

* `<stg.orders.sql>` loads data from from csv to database (staging)
* `<from_stg_to_dw.sql>` creates a new schema and loads data accordingly
