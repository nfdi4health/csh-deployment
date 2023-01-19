import json
import requests
from pymongo import MongoClient
import pandas as pd
URL = 'https://sso.studyhub.nfdi4health.de/admin/realms/nfdi4health'
# login wit Oauth2
data = {
    'username': 'admin',
    'password': '',
    'grant_type': 'password',
    'client_id': 'admin-cli',
    'client_secret': '',
}
response = requests.post('https://sso.studyhub.nfdi4health.de/realms/master/protocol/openid-connect/token', data=data)
print(response.status_code)
headers = {
    'Accept': 'application/json',
    'Authorization': 'Bearer '+response.json()['access_token'],
    'Content-Type': 'application/json',
}

#import user
# SELECT t.login,p.id, p.first_name, p.last_name,p.email,p.phone,p.web_page,p.orcid
# FROM seek_docker.users t JOIN people p on t.person_id = p.id
# df = pd.read_csv ('/Users/johannesdarms/users.csv')
# df.fillna('', inplace=True)
# for index, k in df.iterrows():
#     json_data = {
#         'username': k.login,
#         'email': k.email,
#         'firstName': k.first_name,
#         'lastName': k.last_name,
#         'attributes': {
#             'SEEK_USER': str(k.id),
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
#     response = requests.post('%s/users' % URL, headers=headers, json=json_data)
#     print(response.status_code)
#     print(response.text)



# map user id<-> SEEK ID

response = requests.get('%s/users' % URL, headers=headers)
users= response.json()
map={}
for user in users:
    if "attributes" in user and "SEEK_USER" in user['attributes']:
        if user['attributes']["SEEK_USER"]:
            map[user['attributes']["SEEK_USER"][0]]=user['id']
print("seek,sub")
for k,v in map.items():
    print("{},{}".format(k,v))

# SQL to generate
# SELECT s.id,s.contributor_id ,
# CASE d.publish_state
#       WHEN  1 THEN 'PENDING'
#        WHEN  4 THEN 'PENDING'
#       WHEN  2 THEN 'PUBLIC'
#       ELSE 'DRAFT'
# END AS status,
# s.updated_at,
# s.created_at
# FROM seek_docker.studyhub_resources as s
#     LEFT JOIN (
#         SELECT rpl.resource_id,rpl.publish_state
#         FROM resource_publish_logs rpl
#           LEFT OUTER JOIN resource_publish_logs t2
#             ON (rpl.resource_id = t2.resource_id AND rpl.updated_at < t2.updated_at)
#         WHERE t2.resource_id IS NULL
# )as d ON s.id=d.resource_id;

# update userID in mongoDB
import pandas as pd
df = pd.read_csv ('/Users/johannesdarms/resource_user.csv')
myclient = MongoClient("mongodb://:@localhost:27017/resources?authSource=admin")

#myclient = MongoClient("mongodb://OcxUwqmjY2Z6HvPmNusm:u1XZfwmwSpsQcJ0X6Omr@localhost:27017/resources?authSource=admin")
Collection = myclient['CSH']['dgpei']

for index, resource in df.iterrows():
    if str(resource.contributor_id) in map:
        sub = str(map[str(resource.contributor_id)])
        result=Collection.update_one({"resource.resource_identifier": str(resource.id)},
                         {"$set": {"creator": sub,"status":resource.status,"created_at":resource.created_at,"updated_at":resource.updated_at}})
    else:
        print("ERR:{}".format(resource.contributor_id))