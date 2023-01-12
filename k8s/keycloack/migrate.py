import json

import requests

data = {
    'username': 'admin',
    'password': '',
    'grant_type': 'password',
    'client_id': 'admin-cli',
    'client_secret': '',
}

response = requests.post('https://keycloak.qa.km.k8s.zbmed.de/realms/master/protocol/openid-connect/token', data=data)
print(response.status_code)
headers = {
    'Accept': 'application/json',
    'Authorization': 'Bearer '+response.json()['access_token'],
    'Content-Type': 'application/json',
}

import pandas as pd

# df = pd.read_csv ('/Users/johannesdarms/Result_5.csv')
# df.fillna('', inplace=True)
# for index, k in df.iterrows():
#     json_data = {
#         'username': k.login,
#         'email': k.email,
#         'firstName': k.first_name,
#         'lastName': k.last_name,
#         'attributes': {
#             'SEEK_USER': str(k.person_id),
#             'orcid': k.orcid,
#             'phone': k.phone,
#             'web_page': k.web_page,
#         },
#         'enabled': True,
#         'emailVerified': True,
#         'requiredActions': [
#             'UPDATE_PASSWORD',
#         ],
#     }
#
#     response = requests.post('https://keycloak.qa.km.k8s.zbmed.de/admin/realms/nfdi4health/users', headers=headers, json=json_data)
#     print(response.status_code)
#     print(response.text)



response = requests.get('https://keycloak.qa.km.k8s.zbmed.de/admin/realms/nfdi4health/users', headers=headers)
users= response.json()
map=[]
for user in users:

    if "attributes" in user and "SEEK_USER" in user['attributes']:
        if user['attributes']["SEEK_USER"]:
            map.append({"sub":user['id'],"seek":user['attributes']["SEEK_USER"][0]})
print("seek,sub")
for user in map:
    print("{},{}".format(user['seek'],user['sub']))