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
TSVS=$(find "${LICENSES_PATH}" -maxdepth 1 -iname 'license*.json')
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

echo "Syncing roles"

# Collect roles defined locally
mapfile -t LOCAL_ROLES < <(find "$ROLES_PATH" -maxdepth 1 -iname '*.json')

# Collect aliases we will keep (for later cleanup)
declare -A KEEP_ALIASES=()

for ROLE_FILE in "${LOCAL_ROLES[@]}"; do
  ALIAS=$(jq -r '.alias' "$ROLE_FILE")
  KEEP_ALIASES["$ALIAS"]=1

  echo "Processing role: $ALIAS"

  # Check if role exists
  # (Temporarily allow this command to fail because there may be a 404)
  set +e
  GET_RES=$(curl -o /tmp/role_get.json -w "%{http_code}" "$DATAVERSE_URL/api/roles/:alias?alias=$ALIAS")
  set -e
  echo

  if [[ "$GET_RES" == "404" ]]; then
    echo "Creating role $ALIAS"
    curl -X POST -H "Content-type:application/json" --upload-file "$ROLE_FILE" "$DATAVERSE_URL/api/admin/roles"
    echo
  elif [[ "$GET_RES" == "200" ]]; then
    ID=$(jq -r '.data.id' /tmp/role_get.json)

    echo "Updating role $ALIAS (id=$ID)"
    curl -X PUT -H "Content-type:application/json" --upload-file "$ROLE_FILE" "$DATAVERSE_URL/api/admin/roles/$ID"
    echo
  else
    # On any error except 404, fail the script
    exit 1
  fi

  echo
done

echo "Removing obsolete roles"
curl "$DATAVERSE_URL/api/admin/roles" > /tmp/roles_all.json
mapfile -t EXISTING < <(jq -c '.data[]' /tmp/roles_all.json)

for R in "${EXISTING[@]}"; do
  ALIAS=$(jq -r '.alias' <<< "$R")
  ID=$(jq -r '.id' <<< "$R")

  if [[ -z "${KEEP_ALIASES[$ALIAS]+x}" ]]; then
    echo "Deleting role $ALIAS (id=$ID)"
    curl -X DELETE "$DATAVERSE_URL/api/admin/roles/$ID"
    echo
  fi
done

if [ -z "$DATAVERSE_INSTALLATION_NAME" ]; then
    echo "Updating root dataverse name"
    curl -X PUT "$DATAVERSE_URL/api/dataverses/root/attribute/name?value=$DATAVERSE_INSTALLATION_NAME"
    echo
fi

echo "Creating workflows"
WORKFLOWS=$(find $WORKFLOWS_PATH -maxdepth 1 -iname '*.json')
while IFS= read -r WORKFLOW; do
  WORKFLOW_NAME=$(basename "$WORKFLOW" .json)
  if [[ "WORKFLOW_NAME" != "PrePublishDataset" && "WORKFLOW_NAME" != "PostPublishDataset" ]]; then
    echo "ERROR: Workflow file name must be 'PrePublishDataset.json' or 'PostPublishDataset.json'"
    continue
  fi

  echo "Creating workflow $WORKFLOW_NAME:"
  RESPONSE=$(curl -X POST -H "Content-type:application/json" $DATAVERSE_URL/api/admin/workflows --upload-file $WORKFLOW)
  WORKFLOW_ID=$(echo "$RESPONSE" | jq -r '.data.id')
  curl -X PUT http://localhost:8080/api/admin/workflows/default/$WORKFLOW_NAME -d $WORKFLOW_ID
  echo
done <<< "${WORKFLOWS}"

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
  fi

  if [[ $PARENT_DATAVERSE == "nfdi4health" ]]; then
    echo "Adding :authenticated-users as dataset publisher to dataverse $PARENT_DATAVERSE/$DATAVERSE_ID:"
    curl -X POST -H "Content-Type: application/json" $DATAVERSE_URL/api/dataverses/$DATAVERSE_ID/assignments -d '{"assignee": ":authenticated-users", "role": "dsLinker"}'
    echo
  else
    # The import client, CI test and admin account are currently the only automatically configured curators, all other
    # curators must be added manually
    echo "Creating curator group"
    CURATOR_GROUP_ID=`curl -X POST -H "Content-Type: application/json" $DATAVERSE_URL/api/dataverses/$DATAVERSE_ID/groups -d '{"description": "Curator users", "displayName": "Curators", "aliasInOwner": "curators"}' | jq .data.identifier -r`
    echo

    echo "Adding @service-account-import_client and @dataverseAdmin to curator group"
    curl -X POST -H "Content-Type: application/json" $DATAVERSE_URL/api/dataverses/$DATAVERSE_ID/groups/curators/roleAssignees -d '["@service-account-import_client", "@dataverseAdmin", "@ci_test"]'
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
  METADATABLOCK_NAMES=(${METADATABLOCK_NAMES[@]} "$(awk -F'\t' 'NR==2 {print $2}' $TSV)")
done <<< "${TSVS}"

echo "Activating metadata blocks"
while IFS= read -r DATAVERSE; do
  DATAVERSE_ID=$(jq -r '.alias' $DATAVERSE)
  curl -X POST -H "Content-Type: application/json" $DATAVERSE_URL/api/dataverses/$DATAVERSE_ID/metadatablocks -d $(jq -c -n '$ARGS.positional' --args "${METADATABLOCK_NAMES[@]}")
  echo
done <<< "${DATAVERSES}"

echo "Activating metadata field facets"
curl "$DATAVERSE_URL/api/datasetfields/facetables" | jq ".data | map(.name)" | curl -X POST -H "Content-Type: application/json" -d @- "$DATAVERSE_URL/api/dataverses/root/facets"

echo
echo
echo "...DONE!"