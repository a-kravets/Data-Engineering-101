# docker build -t test:pandas .
# docker run -it test:pandas 2023-08-12

FROM python:3.9

WORKDIR /app

RUN pip install pandas sqlalchemy psycopg2 wget

COPY pg_conn_upload.py pg_conn_upload.py

ENTRYPOINT ["python", "pg_conn_upload.py"]