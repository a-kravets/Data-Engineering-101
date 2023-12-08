import pandas as pd
from sqlalchemy import create_engine, text as sql_text
from time import time
import argparse



def main(params):

    user = params.user
    password = params.password
    host = params.host
    port = params.port
    db = params.db
    table = params.table
    url = params.url

    df = pd.read_csv(f'{url}', nrows=100, compression='gzip')

    # converting tpep_pickup_datetime & tpep_dropoff_datetime from TEXT to datetime

    df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
    df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)

    # creating the engine with credentials

    engine = create_engine(f'postgresql://{user}:{password}@{host}:{port}/{db}')


    df_iter = pd.read_csv(f'{url}', iterator=True, chunksize=100000, compression='gzip')

    # next() takes the next chunk

    df = next(df_iter)

    # in order to create the table in pg, we may isert only 1st row, that is column names

    df.head(n=0).to_sql(name=table, con=engine, if_exists='replace')

    # now we may iterate and ingest our data to the db in chunks

    while True: 
        try:
            t_start = time()

            # when all the chunks will be uploaded, it'll throw an exception
            df = next(df_iter)

            df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
            df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)

            df.to_sql(name=table, con=engine, if_exists='append')

            t_end = time()

            print('inserted another chunk, took %.3f second' % (t_end - t_start))
            
        except StopIteration:
                print("Finished ingesting data into the postgres database")
                break

if __name__ == '__main__':
    # parser will parse the args
    parser = argparse.ArgumentParser(description='Ingest csv data to Postgres')

    parser.add_argument('--user', help='user name for postgres')
    parser.add_argument('--password', help='password for postgres')
    parser.add_argument('--host', help='host name for postgres')
    parser.add_argument('--port', help='port for postgres')
    parser.add_argument('--db', help='db name for postgres')
    parser.add_argument('--table', help='table name for postgres')
    parser.add_argument('--url', help='url to csv')

    args = parser.parse_args()
    # we'll pass our args to the main method
    main(args)