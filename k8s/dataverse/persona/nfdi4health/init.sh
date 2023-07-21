#!/bin/bash
set -euo pipefail

# Set some defaults as documented
DATAVERSE_URL=${DATAVERSE_URL:-"http://dataverse:8080"}
export DATAVERSE_URL
# get current dir location
SELF_LOCATION=$( dirname "$(readlink -f -- "$0")" )

echo -n "Running dev setup-all.sh (INSECURE MODE)"
"${BOOTSTRAP_DIR}"/base/setup-all.sh --insecure -p=admin1 | tee /tmp/setup-all.sh.out
API_TOKEN=$(grep apiToken "/tmp/setup-all.sh.out" | jq ".data.apiToken" | tr -d \")
export API_TOKEN

echo -n "Setting DOI provider to FAKE"
curl -H "X-Dataverse-key:$API_TOKEN" -X PUT -d FAKE DATAVERSE_URL/api/admin/settings/:DoiProvider

echo -n "Publishing root dataverse"
curl -H "X-Dataverse-key:$API_TOKEN" -X POST "${DATAVERSE_URL}/api/dataverses/:root/actions/:publish"

#echo "Allow all API calls"
##curl -X PUT -d allow $DATAVERSE_URL/api/admin/settings/:BlockedApiPolicy
#curl -X PUT -d "admin,builtin-users,licenses" $DATAVERSE_URL/api/admin/settings/:BlockedApiEndpoints

echo -n "Set up OIDC provider"
curl -X POST -H "Content-type: application/json" --upload-file $SELF_LOCATION/keycloak.json $DATAVERSE_URL/api/admin/authenticationProviders

echo -n "Upload licenses"
#curl -X POST -H "Content-Type: application/json" -H "X-Dataverse-key:$DATAVERSE_API_KEY" $DATAVERSE_HOST/api/licenses --upload-file license-CC0-1.0.json
# Find all licence files
TSVS=$(find "${LICENCE_PATH}" -maxdepth 1 -iname 'license-*.json')
# Load licences
while IFS= read -r TSV; do
  echo -n "Loading ${TSV}: "
  curl -H "X-Dataverse-key:$API_TOKEN" -X POST -H "Content-type: application/json"  $DATAVERSE_URL/api/licenses --upload-file ${TSV}
done <<< "${TSVS}"

echo -n "Creating users"
USERS=$(find USERS_PATH -maxdepth 1 -iname '*.json')
while IFS= read -r USER; do
  echo -n "Creating user $(jq -r '.identifier' $USER):"
  curl -H "X-Dataverse-key:$API_TOKEN" -X POST -H "Content-type:application/json" $DATAVERSE_URL/api/admin/authenticatedUsers --upload-file USER
done <<< "${USERS}"

echo -n "Creating roles"
ROLES=$(find $ROLES_PATH -maxdepth 1 -iname '*.json')
while IFS= read -r ROLE; do
  echo -n "Creating role $(basename $ROLE .json):"
  curl -H "X-Dataverse-key:$API_TOKEN" -X POST -H "Content-type:application/json" $DATAVERSE_URL/api/admin/roles --upload-file $ROLE
done <<< "${ROLES}"

echo -n "Create dataverses"
# Find all JSON files
# NOTE Using POSIX C locale to force sorting by simple byte comparison. This sorts "." before "_". This is to ensure
# parent dataverses are created before child dataverses, e.g. "nfdi4health.json" is created before
# "nfdi4health_covid-19.json".
DATAVERSES=$(find $DATAVERSES_PATH -maxdepth 1 -iname '*.json' | LC_COLLATE=C sort)
# Create dataverses
echo -n "Publishing dataverse root:"
curl -H "X-Dataverse-key:$API_TOKEN" -X POST $DATAVERSE_URL/api/dataverses/root/actions/:publish

while IFS= read -r DATAVERSE; do
  if [[ $DATAVERSE == *"_"* ]]; then
    DATAVERSE_FILE_NAME=$(basename $DATAVERSE .json)
    PARENT_DATAVERSE=${DATAVERSE_FILE_NAME%%_*}
  else
    PARENT_DATAVERSE="root"
  fi

  DATAVERSE_ID=$(jq -r '.alias' $DATAVERSE)
  echo -n "Creating dataverse $PARENT_DATAVERSE/$DATAVERSE_ID:"
  curl -H "X-Dataverse-key:$API_TOKEN" -X POST -H "Content-Type: application/json" $DATAVERSE_URL/api/dataverses/$PARENT_DATAVERSE --upload-file $DATAVERSE

  echo -n "Publishing dataverse $PARENT_DATAVERSE/$DATAVERSE_ID:"
  curl -H "X-Dataverse-key:$API_TOKEN" -X POST $DATAVERSE_URL/api/dataverses/$DATAVERSE_ID/actions/:publish

  echo -n "Adding @dataverseAdmin as admin to dataverse $PARENT_DATAVERSE/$DATAVERSE_ID:"
  curl -H "X-Dataverse-key:$API_TOKEN" -X POST -H "Content-Type: application/json" $DATAVERSE_URL/api/dataverses/$DATAVERSE_ID/assignments -d '{"assignee": "@dataverseAdmin", "role": "admin"}'

  echo -n "Adding :authenticated-users as dataset creators to dataverse $PARENT_DATAVERSE/$DATAVERSE_ID:"
  curl -H "X-Dataverse-key:$API_TOKEN" -X POST -H "Content-Type: application/json" $DATAVERSE_URL/api/dataverses/$DATAVERSE_ID/assignments -d '{"assignee": ":authenticated-users", "role": "dsContributor"}'

  if [[ $PARENT_DATAVERSE != "root" ]]; then
    # We add the "Publish permission" for all users only to the sub-dataverses (collection dataverses, e.g. "COVID-19")
    # where no datasets are created so it can only be used for linking, not publishing
    # (only curators should be able to publish)
    echo -n "Adding :authenticated-users as dataset publisher to dataverse $PARENT_DATAVERSE/$DATAVERSE_ID:"
    curl -H "X-Dataverse-key:$API_TOKEN" -X POST -H "Content-Type: application/json" $DATAVERSE_URL/api/dataverses/$DATAVERSE_ID/assignments -d '{"assignee": ":authenticated-users", "role": "dsPublisher"}'
  else
    # The import client is currently the only automatically configured curator user, all other curators must be added
    # manually
    echo -n "Adding @service-account-import_client as curator to dataverse $PARENT_DATAVERSE/$DATAVERSE_ID:"
    curl -H "X-Dataverse-key:$API_TOKEN" -X POST -H "Content-Type: application/json" $DATAVERSE_URL/api/dataverses/$DATAVERSE_ID/assignments -d '{"assignee": "@service-account-import_client", "role": "curator"}'
  fi
done <<< "${DATAVERSES}"

# Last step as existence of one block is the indicator for a complete bootstrapped installation
echo -n "Load custom metadata blocks"
#curl -X POST -H "Content-type: text/tab-separated-values" $DATAVERSE_HOST/api/admin/datasetfield/load --upload-file customMDS.tsv
# Find all TSV files
TSVS=$(find "${METADATABLOCKS_PATH}" -maxdepth 1 -iname '*.tsv')
METADATABLOCK_NAMES=("citation")
# Load metadata blocks
while IFS= read -r TSV; do
  echo -n "Loading ${TSV}:"
  curl -X POST -H "Content-type: text/tab-separated-values" $DATAVERSE_URL/api/admin/datasetfield/load --upload-file ${TSV}
  METADATABLOCK_NAMES=(${METADATABLOCK_NAMES[@]} "$(awk 'NR==2 {print $2}' $TSV)")
done <<< "${TSVS}"

echo -n "Activating metadata blocks"
while IFS= read -r DATAVERSE; do
  DATAVERSE_ID=$(jq -r '.alias' $DATAVERSE)
  curl -H "X-Dataverse-key:$API_TOKEN" -X POST -H "Content-Type: application/json" $DATAVERSE_URL/api/dataverses/$DATAVERSE_ID/metadatablocks -d $(jq -c -n '$ARGS.positional' --args "${METADATABLOCK_NAMES[@]}")
done <<< "${DATAVERSES}"



echo "\n\n...DONE!"