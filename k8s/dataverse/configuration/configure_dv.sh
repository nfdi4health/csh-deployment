#!/bin/bash

DATAVERSE_POD="vc-dv-ss3-dataverse-0"
DATAVERSE_HOST=http://localhost:8080
DATAVERSE_API_KEY=""
SOLR_POD="vc-dv-ss3-dataverse-solr-0"

kubectl port-forward pods/$DATAVERSE_POD 8080:8080 &
PORT_FORWARD_PID=$!

trap "{
    kill $PORT_FORWARD_PID
}" EXIT

sleep 3

echo "Allow all API calls"
curl -X PUT -d allow $DATAVERSE_HOST/api/admin/settings/:BlockedApiPolicy
curl -X PUT -d "admin,builtin-users,licenses" $DATAVERSE_HOST/api/admin/settings/:BlockedApiEndpoints
echo ""

echo "Set DOI provider"
curl -X PUT -d FAKE $DATAVERSE_HOST/api/admin/settings/:DoiProvider
echo ""

echo "Load custom metadata blocks"
curl -X POST -H "Content-type: text/tab-separated-values" $DATAVERSE_HOST/api/admin/datasetfield/load --upload-file customMDS.tsv
curl -X POST -H "Content-type: text/tab-separated-values" $DATAVERSE_HOST/api/admin/datasetfield/load --upload-file custom_chronic_diseases_epidemiology.tsv
curl -X POST -H "Content-type: text/tab-separated-values" $DATAVERSE_HOST/api/admin/datasetfield/load --upload-file custom_diet_assessment.tsv
curl -X POST -H "Content-type: text/tab-separated-values" $DATAVERSE_HOST/api/admin/datasetfield/load --upload-file custom_link.tsv
echo ""

echo "Reload SOLR schema"
# NOTE: this uses a precreated SOLR schema instead of the update-fields.sh script because of a bug in the script

#kubectl exec $SOLR_POD --container dataverse-solr-config -- apk add ed
#kubectl exec $SOLR_POD --container dataverse-solr-config -- bash -c 'curl http://${DATAVERSE_HOSTNAME}:8080/api/admin/index/solr/schema | /scripts/update-fields.sh /template/conf/schema.xml'
#kubectl exec $SOLR_POD --container dataverse-solr-config -- cp /template/conf/schema.xml /var/solr/data/collection1/schema.xml

kubectl cp --container dataverse-solr-config schema.xml $SOLR_POD:/var/solr/data/collection1/schema.xml
kubectl exec $SOLR_POD --container dataverse-solr-config -- curl "http://localhost:8983/solr/admin/cores?action=RELOAD&core=collection1"
echo ""

echo "Set up Keycloak as OIDC provider"
curl -X POST -H "Content-type: application/json" --upload-file keycloak.json $DATAVERSE_HOST/api/admin/authenticationProviders
echo ""

echo "Add dataset permissions admin role"
curl -X POST -H "Content-type:application/json" $DATAVERSE_HOST/api/admin/roles --upload-file dataset-permissions-admin.json
echo ""

echo "Upload licenses"
curl -X POST -H "Content-Type: application/json" -H "X-Dataverse-key:$DATAVERSE_API_KEY" $DATAVERSE_HOST/api/licenses --upload-file licenseCC0-1.0.json
curl -X POST -H "Content-Type: application/json" -H "X-Dataverse-key:$DATAVERSE_API_KEY" $DATAVERSE_HOST/api/licenses --upload-file licenseCC-BY-4.0.json
curl -X POST -H "Content-Type: application/json" -H "X-Dataverse-key:$DATAVERSE_API_KEY" $DATAVERSE_HOST/api/licenses --upload-file licenseCC-BY-NC-4.0.json
curl -X POST -H "Content-Type: application/json" -H "X-Dataverse-key:$DATAVERSE_API_KEY" $DATAVERSE_HOST/api/licenses --upload-file licenseCC-BY-NC-SA-4.0.json
curl -X POST -H "Content-Type: application/json" -H "X-Dataverse-key:$DATAVERSE_API_KEY" $DATAVERSE_HOST/api/licenses --upload-file licenseCC-BY-SA-4.0.json
curl -X POST -H "Content-Type: application/json" -H "X-Dataverse-key:$DATAVERSE_API_KEY" $DATAVERSE_HOST/api/licenses --upload-file license-All-rights-reserved.json
curl -X POST -H "Content-Type: application/json" -H "X-Dataverse-key:$DATAVERSE_API_KEY" $DATAVERSE_HOST/api/licenses --upload-file license-Unknown.json
curl -X POST -H "Content-Type: application/json" -H "X-Dataverse-key:$DATAVERSE_API_KEY" $DATAVERSE_HOST/api/licenses --upload-file license-Not-applicable.json
curl -X POST -H "Content-Type: application/json" -H "X-Dataverse-key:$DATAVERSE_API_KEY" $DATAVERSE_HOST/api/licenses --upload-file license-Other.json
echo ""

echo "Create user for import client"
curl -X POST -H "Content-Type: application/json" $DATAVERSE_HOST/api/admin/authenticatedUsers --upload-file service_account_user.json
