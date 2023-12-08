
# tells docker what image we want to use
FROM python:3.9

# tells what we want to run
RUN pip install pandas sqlalchemy psycopg2

# locaion in the image in the container, where our files are stored
# it will do cd /app to this directory once started
# and will copy the file there and we'll be in this dir once it runs
WORKDIR /app

# copy this file from our current dir to the docker image
# 1st filename is the source, 2nd is the destination
COPY ingest_data.py ingest_data.py 

# tells where we want the image to start
# it'll run python and then execute ingest_data.py
ENTRYPOINT [ "python", "ingest_data.py" ]

# docker build -t test:pandas .
# -t is tag, with test as the name and pandas as the tag
# . in the end tells docker to build the image in the current directory


# docker run -it test:pandas
# -it means we eant to run it in interactive mode

# docker run -it test:pandas 2023-12-31
# since we added agrument in pipeline.py, we may specify it here