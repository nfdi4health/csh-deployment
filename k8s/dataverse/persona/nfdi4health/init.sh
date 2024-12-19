#!/bin/bash
set -euo pipefail

# Set some defaults as documented
DATAVERSE_URL=${DATAVERSE_URL:-"http://dataverse:8080"}
export DATAVERSE_URL

# get current dir location
SELF_LOCATION=${BOOTSTRAP_DIR}/${PERSONA}/
echo "SELF_LOCATION = $SELF_LOCATION"

echo "Running base setup-all.sh (INSECURE MODE)"
"${BOOTSTRAP_DIR}"/base/setup-all.sh --insecure -p=admin1 | tee /tmp/setup-all.sh.out
API_TOKEN=$(grep apiToken "/tmp/setup-all.sh.out" | jq ".data.apiToken" | tr -d \")
export API_TOKEN

# configure curl
echo "# hide progress meter
-s
# authentication
-H \"X-Dataverse-key:$API_TOKEN\"
# fail script on server error
--fail-with-body" > ~/.curlrc

echo "Setting superuser status"
curl -X PUT "${DATAVERSE_URL}/api/admin/superuser/dataverseAdmin" -d true
echo

echo "Publishing root dataverse"
curl -X POST "${DATAVERSE_URL}/api/dataverses/:root/actions/:publish"
echo

#echo "Allow all API calls"
##curl -X PUT -d allow $DATAVERSE_URL/api/admin/settings/:BlockedApiPolicy
#curl -X PUT -d "admin,builtin-users,licenses" $DATAVERSE_URL/api/admin/settings/:BlockedApiEndpoints

echo "Set up OIDC provider"
curl -X POST -H "Content-type: application/json" --upload-file $SELF_LOCATION/keycloak.json $DATAVERSE_URL/api/admin/authenticationProviders
echo

echo "Disable tabular file ingest"
curl -X PUT -d 0 "${DATAVERSE_URL}/api/admin/settings/:TabularIngestSizeLimit"
echo

echo "Setting file upload limit to 5Gi"
curl -X PUT -d 5368709120 "${DATAVERSE_URL}/api/admin/settings/:MaxFileUploadSizeInBytes"
echo

echo "Upload licenses"
#curl -X POST -H "Content-Type: application/json" -H "X-Dataverse-key:$DATAVERSE_API_KEY" $DATAVERSE_HOST/api/licenses --upload-file license-CC0-1.0.json
# Find all licence files
TSVS=$(find "${LICENCE_PATH}" -maxdepth 1 -iname 'license-*.json')
# Load licences
while IFS= read -r TSV; do
  echo "Loading ${TSV}: "
  curl -X POST -H "Content-type: application/json"  $DATAVERSE_URL/api/licenses --upload-file ${TSV}
  echo
done <<< "${TSVS}"

echo "Disable custom terms of use"
curl -X PUT -d false "${DATAVERSE_URL}/api/admin/settings/:AllowCustomTermsOfUse"
echo

echo "Creating users"
USERS=$(find $USERS_PATH -maxdepth 1 -iname '*.json')
while IFS= read -r USER; do
  echo "Creating user $(jq -r '.identifier' $USER):"
  curl -X POST -H "Content-type:application/json" $DATAVERSE_URL/api/admin/authenticatedUsers --upload-file $USER
  echo
done <<< "${USERS}"

echo "Creating roles"
ROLES=$(find $ROLES_PATH -maxdepth 1 -iname '*.json')
while IFS= read -r ROLE; do
  echo "Creating role $(basename $ROLE .json):"
  curl -X POST -H "Content-type:application/json" $DATAVERSE_URL/api/admin/roles --upload-file $ROLE
  echo
done <<< "${ROLES}"

echo "Create dataverses"
# NOTE Using POSIX C locale to force sorting by simple byte comparison. This sorts "." before "_". This is to ensure
# parent dataverses are created before child dataverses, e.g. "nfdi4health.json" is created before
# "nfdi4health_covid-19.json".
DATAVERSES=$(find $DATAVERSES_PATH -maxdepth 1 -iname '*.json' | LC_COLLATE=C sort)
while IFS= read -r DATAVERSE; do
  if [[ $DATAVERSE == *"_"* ]]; then
    DATAVERSE_FILE_NAME=$(basename $DATAVERSE .json)
    PARENT_DATAVERSE=${DATAVERSE_FILE_NAME%%_*}
  else
    PARENT_DATAVERSE="root"
  fi

  DATAVERSE_ID=$(jq -r '.alias' $DATAVERSE)
  echo "Creating dataverse $PARENT_DATAVERSE/$DATAVERSE_ID:"
  curl -X POST -H "Content-Type: application/json" $DATAVERSE_URL/api/dataverses/$PARENT_DATAVERSE --upload-file $DATAVERSE
  echo

  echo "Publishing dataverse $PARENT_DATAVERSE/$DATAVERSE_ID:"
  curl -X POST $DATAVERSE_URL/api/dataverses/$DATAVERSE_ID/actions/:publish
  echo

#  echo "Adding @dataverseAdmin as admin to dataverse $PARENT_DATAVERSE/$DATAVERSE_ID:"
#  curl -s -H "X-Dataverse-key:$API_TOKEN" -X POST -H "Content-Type: application/json" $DATAVERSE_URL/api/dataverses/$DATAVERSE_ID/assignments -d '{"assignee": "@dataverseAdmin", "role": "admin"}'
#  echo

  if [[ $DATAVERSE_ID == "nfdi4health" ]]; then
    echo "Adding :authenticated-users as dataset creators to dataverse $PARENT_DATAVERSE/$DATAVERSE_ID:"
    curl -X POST -H "Content-Type: application/json" $DATAVERSE_URL/api/dataverses/$DATAVERSE_ID/assignments -d '{"assignee": ":authenticated-users", "role": "dsContributor"}'
    echo

    echo "Adding :authenticated-users as dataset permission admins to dataverse $PARENT_DATAVERSE/$DATAVERSE_ID:"
    curl -X POST -H "Content-Type: application/json" $DATAVERSE_URL/api/dataverses/$DATAVERSE_ID/assignments -d '{"assignee": ":authenticated-users", "role": "dsPermAdmin"}'
    echo
  fi

  if [[ $PARENT_DATAVERSE == "nfdi4health" ]]; then
    # We add the "Publish permission" for all users only to the sub-dataverses (collection dataverses, e.g. "COVID-19")
    # of "NFDI4Health" where no datasets are created so it can only be used for linking, not publishing
    # (only curators should be able to publish)
    echo "Adding :authenticated-users as dataset publisher to dataverse $PARENT_DATAVERSE/$DATAVERSE_ID:"
    curl -X POST -H "Content-Type: application/json" $DATAVERSE_URL/api/dataverses/$DATAVERSE_ID/assignments -d '{"assignee": ":authenticated-users", "role": "dsPublisher"}'
    echo
  else
    # The import client and the admin are currently the only automatically configured curator user, all other curators
    # must be added manually
    echo "Creating curator group"
    CURATOR_GROUP_ID=`curl -X POST -H "Content-Type: application/json" $DATAVERSE_URL/api/dataverses/$DATAVERSE_ID/groups -d '{"description": "Curator users", "displayName": "Curators", "aliasInOwner": "curators"}' | jq .data.identifier -r`
    echo

    echo "Adding @service-account-import_client and @dataverseAdmin to curator group"
    curl -X POST -H "Content-Type: application/json" $DATAVERSE_URL/api/dataverses/$DATAVERSE_ID/groups/curators/roleAssignees -d '["@service-account-import_client", "@dataverseAdmin"]'
    echo

    echo "Adding curator group as curator to dataverse $PARENT_DATAVERSE/$DATAVERSE_ID:"
    curl -X POST -H "Content-Type: application/json" $DATAVERSE_URL/api/dataverses/$DATAVERSE_ID/assignments -d "{\"assignee\": \"$CURATOR_GROUP_ID\", \"role\": \"curator\"}"
    echo
  fi
done <<< "${DATAVERSES}"

# This should be done after creating dataverses if we want a chance of keeping the database IDs and Permalink IDs of our
# datasets in sync
echo "Configuring PID permalink generator function"
PGPASSWORD=$DATAVERSE_DB_PASSWORD psql -h $DATAVERSE_DB_HOST -U $DATAVERSE_DB_USER < /scripts/bootstrap/nfdi4health/generate-permalink.sql
echo

# Last step as existence of one block is the indicator for a complete bootstrapped installation
echo "Load custom metadata blocks"
#curl -X POST -H "Content-type: text/tab-separated-values" $DATAVERSE_HOST/api/admin/datasetfield/load --upload-file customMDS.tsv
# Find all TSV files
TSVS=$(find "${METADATABLOCKS_PATH}" -maxdepth 1 -iname '*.tsv')
METADATABLOCK_NAMES=("citation")
# Load metadata blocks
while IFS= read -r TSV; do
  echo "Loading ${TSV}:"
  curl -X POST -H "Content-type: text/tab-separated-values" $DATAVERSE_URL/api/admin/datasetfield/load --upload-file ${TSV}
  echo
  METADATABLOCK_NAMES=(${METADATABLOCK_NAMES[@]} "$(awk 'NR==2 {print $2}' $TSV)")
done <<< "${TSVS}"

echo "Activating metadata blocks"
while IFS= read -r DATAVERSE; do
  DATAVERSE_ID=$(jq -r '.alias' $DATAVERSE)
  curl -X POST -H "Content-Type: application/json" $DATAVERSE_URL/api/dataverses/$DATAVERSE_ID/metadatablocks -d $(jq -c -n '$ARGS.positional' --args "${METADATABLOCK_NAMES[@]}")
  echo
done <<< "${DATAVERSES}"

echo
echo
echo "...DONE!"