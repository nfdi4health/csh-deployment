# Install dataverse

## If you would like to install custom 
`helm install my-dataverse ./dataverse`


# Configure custom schema
## Enable admin api via localhost port forwarding
### Allow all API calls
`export DATAVERSE_POD="my-dataverse-dataverse-solr-0"`

`kubectl port-forward pods/${DATAVERSE_POD} 8080:8080`

`curl -X PUT -d allow http://localhost:8080/api/admin/settings/:BlockedApiPolicy`

## Update SOLR fields with custom metadata info
### Login into the solr helper container and execute the update 
`export SOLR_POD="my-dataverse-dataverse-solr-0"`

`kubectl exec -i -t $SOLR_POD  --container dataverse-solr-config  -- /bin/sh`

Until the image is fixed, manually add the `ed` package. 
`apk add ed` 

`curl "http://${DATAVERSE_HOSTNAME}:8080/api/admin/index/solr/schema" | /scripts/update-fields.sh /template/conf/schema.xml`

`cp /template/conf/schema.xml /var/solr/data/collection1/schema.xml `

`curl "http://localhost:8983/solr/admin/cores?action=RELOAD&core=collection1"`


