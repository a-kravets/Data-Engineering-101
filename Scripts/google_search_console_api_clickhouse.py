'''
This script iterates over multiple accounts with sites inside each of them
and gets clicks and impressions data by date (dimension)
After that inserts data to a clickhouse table

To get Google Search Console data one needs
- get service keys for each account, if there is more than one account
- activate Google Search Console API for each account
- add service email of each account to every site inside specific account and grant permissions
https://search.google.com/u/1/search-console/users
'''
# pip install --upgrade google-api-python-client google-auth-httplib2 google-auth-oauthlib

from google.oauth2 import service_account
from googleapiclient.discovery import build, Resource
import pandas as pd
import clickhouse_connect
import re

# define general constants
# https://developers.google.com/webmaster-tools/about
API_SERVICE_NAME = "webmasters"
API_VERSION = "v3"
SCOPE = ["https://www.googleapis.com/auth/webmasters.readonly"]

# https://clickhouse-driver.readthedocs.io/en/latest/quickstart.html#selecting-data
# connection to clickhouse
client = clickhouse_connect.get_client(host='', port=8123, username='', password='')

# connection (service) to google search console
def auth_using_key_file(key_filepath: str) -> Resource:
    """Authenticate using a service account key file saved locally"""

    credentials = service_account.Credentials.from_service_account_file(
        key_filepath, scopes=SCOPE
    )
    service = build(API_SERVICE_NAME, API_VERSION, credentials=credentials)

    return service

# accounts with json key paths
accounts = [
        ['account1', 'account1.json'],
        ['account2', 'account2.json'],
        ['account3', 'account3.json'],
        ['account4', 'account4.json'],
        ['account5', 'account5.json']
]

# parameters for data requests
# https://developers.google.com/webmaster-tools/v1/searchanalytics/query
payload = {
        'startDate': '2024-01-01',
        'endDate': '2024-01-31',
        'dimensions': ["date"],
        'rowLimit': 10,
        'startRow': 0
    }

# filepath location of your service account key json file
#KEY_FILE = "key.json"

# authenticate session
#service = auth_using_key_file(key_filepath=KEY_FILE)

# looping over accounts
for account in accounts:
    # connection to current account with appropriate service json key
    service = auth_using_key_file(key_filepath=account[1])
    # getting the list of sites for current account
    sites = service.sites().list().execute()
# verify your service account has permissions to your domain
#print(service.sites().list().execute())
    # looping over sites of current account
    for site in sites:
        # checking if returned dict is not empty
        if len(site) != 0:
            # proceeding if not 
            for site in sites['siteEntry']:
                # current site url
                site_url = site['siteUrl']
                # getting data for current site
                response = service.searchanalytics().query(siteUrl=site_url, body=payload).execute()
                results = []

                # cleaning site url, leaving only domain
                if 'sc-domain' in site_url:
                    site_url = site_url.rsplit(':')[1]
                else:
                    site_url = site_url.rsplit('/')[2]

                # looping over results
                for row in response['rows']:
                    data = {}

                    for i in range(len(payload['dimensions'])):
                        data[payload['dimensions'][i]] = row['keys'][i]
                    data['clicks'] = row['clicks']
                    data['impressions'] = row['impressions']
                #data['ctr'] = round(row['ctr'] * 100, 2)
                #data['position'] = round(row['position'], 2)
                    # getting site url this data came from
                    data['site'] = site_url
                    # getting account this data came from
                    data['account'] = account[0]
                    results.append(data)

                dataframe_report = pd.DataFrame.from_dict(results)
                dataframe_report['date'] = pd.to_datetime(dataframe_report['date'])
                client.insert_df(table='', df=dataframe_report)
                #print(dataframe_report.head())