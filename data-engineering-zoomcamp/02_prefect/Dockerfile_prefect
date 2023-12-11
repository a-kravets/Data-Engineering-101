FROM prefecthq/prefect:2.7.7-python3.9

COPY docker-requirements.txt .

RUN pip install -r docker-requirements.txt --trusted-host pypi.python.org --no-cache-dir

# 1st filename is the source, 2nd is the destination
COPY ingest_data_prefect_parameterized.py /opt/prefect/flows

COPY data_yellow /opt/prefect/data 