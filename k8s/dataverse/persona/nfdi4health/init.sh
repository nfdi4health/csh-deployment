#!/bin/bash
set -euo pipefail

# Set some defaults as documented
DATAVERSE_URL=${DATAVERSE_URL:-"http://dataverse:8080"}
export DATAVERSE_URL
# get current dir location
SELF_LOCATION=$( dirname "$(readlink -f -- "$0")" )

echo "Running dev setup-all.sh (INSECURE MODE)..."
"${BOOTSTRAP_DIR}"/base/setup-all.sh --insecure -p=admin1 | tee /tmp/setup-all.sh.out

echo "Allow all API calls"
curl -X PUT -d allow $DATAVERSE_URL/api/admin/settings/:BlockedApiPolicy
#curl -X PUT -d "admin,builtin-users,licenses" $DATAVERSE_URL/api/admin/settings/:BlockedApiEndpoints

echo "Set up OIDC provider"
curl -X POST -H "Content-type: application/json" --upload-file $SELF_LOCATION/keycloak.json $DATAVERSE_URL/api/admin/authenticationProviders

echo "Upload licenses"
#curl -X POST -H "Content-Type: application/json" -H "X-Dataverse-key:$DATAVERSE_API_KEY" $DATAVERSE_HOST/api/licenses --upload-file license-CC0-1.0.json
# Find all licence files
TSVS=$(find "${LICENCE_PATH}" -maxdepth 1 -iname 'license-*.json')
# Load licences
while IFS= read -r TSV; do
  echo -n "Loading ${TSV}: "
  curl -X POST -H "Content-type: application/json"  $DATAVERSE_URL/api/licenses --upload-file ${TSV}
done <<< "${TSVS}"

echo "Add dataset permissions admin role"
curl -X POST -H "Content-type:application/json" $DATAVERSE_URL/api/admin/roles --upload-file $SELF_LOCATION/dataset-permissions-admin.json

echo "Create dataverses"
# Find all JSON files
DATAVERSES=$(find $DATAVERSES_PATH -maxdepth 1 -iname '*.json')
# Create dataverses
echo -n "Publishing dataverse root:"
curl -X POST $DATAVERSE_URL/api/dataverses/root/actions/:publish

while IFS= read -r DATAVERSE; do
  if [[ $(dirname "$DATAVERSE") -ef $DATAVERSES_PATH ]]; then
    PARENT_DATAVERSE="root"
  else
    PARENT_DATAVERSE= ${DATAVERSE%%_*}
  fi

  DATAVERSE_ID=$(jq -r '.alias' $DATAVERSE)
  echo -n "Creating dataverse $PARENT_DATAVERSE/$DATAVERSE_ID:"
  curl -X POST -H "Content-Type: application/json" $DATAVERSE_URL/api/dataverses/$PARENT_DATAVERSE --upload-file $DATAVERSE

  echo -n "Publishing dataverse $PARENT_DATAVERSE/$DATAVERSE_ID:"
  curl -X POST $DATAVERSE_URL/api/dataverses/$DATAVERSE_ID/actions/:publish

  echo -n "Adding dataverseAdmin as admin to dataverse $PARENT_DATAVERSE/$DATAVERSE_ID:"
  curl -X POST -H "Content-Type: application/json" $DATAVERSE_URL/api/dataverses/$DATAVERSE_ID/assignments -d '{"assignee": "@dataverseAdmin", "role": "admin"}'

  echo -n "Adding :authenticated-users as dataset creators to dataverse $PARENT_DATAVERSE/$DATAVERSE_ID:"
  curl -X POST -H "Content-Type: application/json" $DATAVERSE_URL/api/dataverses/$DATAVERSE_ID/assignments -d '{"assignee": ":authenticated-users", "role": "dsContributor"}'
done <<< "${DATAVERSES}"

# Last step as existence of one block is the indicator for a complete bootstrapped installation
echo "Load custom metadata blocks"
#curl -X POST -H "Content-type: text/tab-separated-values" $DATAVERSE_HOST/api/admin/datasetfield/load --upload-file customMDS.tsv
# Find all TSV files
TSVS=$(find "${METADATABLOCKS_PATH}" -maxdepth 1 -iname '*.tsv')
# Load metadata blocks
while IFS= read -r TSV; do
  echo -n "Loading ${TSV}:"
  curl -X POST -H "Content-type: text/tab-separated-values" $DATAVERSE_URL/api/admin/datasetfield/load --upload-file ${TSV}
done <<< "${TSVS}"



echo "\n\n...DONE!"