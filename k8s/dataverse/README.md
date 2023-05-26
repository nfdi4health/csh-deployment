
# Install dataverse

`helm install my-dataverse ./dataverse`

## Configure custom schema

# Enable admin api via localhost port forwarding
k port-forward pods/my-dataverse-dataverse-0      8080:8080
curl -X PUT -d "builtin-users" http://localhost:8080/api/admin/settings/:BlockedApiEndpoints
# Import custom metadata

curl http://localhost:8080/api/admin/datasetfield/load -X POST --data-binary @customMDS.tsv -H "Content-type: text/tab-separated-values" -v
curl http://localhost:8080/api/admin/datasetfield/load -X POST --data-binary @custom_link.tsv -H "Content-type: text/tab-separated-values" -v
curl http://localhost:8080/api/admin/datasetfield/load -X POST --data-binary @custom_chronic_diseases_epidemiology.tsv -H "Content-type: text/tab-separated-values" -v
curl http://localhost:8080/api/admin/datasetfield/load -X POST --data-binary @custom_diet_assessment.tsv custom_diet_assessment.tsv -H "Content-type: text/tab-separated-values" -v
# Update SOLR fields with custom metadata info
## we need to update the schema locally (on dev node), do an upgrade (helm upgrade) to update the config map, then copy the updated file into live config location
cd ./solr
curl "http://localhost:8080/api/admin/index/solr/schema" | ./update-fields.sh schema.xml
### manually fix two fields (role_...) to allow mutliple entries
// @TODO: Document wich fields
helm upgrade my-dataverse ./dataverse
kubectl exec  --stdin --tty  pods/my-dataverse-dataverse-solr-0  -- /bin/bash
> cp /tmp/schema.xml /var/solr/data/collection1/schema.xml 
> curl "http://localhost:8983/solr/admin/cores?action=RELOAD&core=collection1"
# Disable admin API
curl -X PUT -d 'admin,builtin-users' $SERVER/admin/settings/:BlockedApiEndpoints
