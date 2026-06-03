#!/bin/bash
set -euo pipefail

# Set some defaults as documented
DATAVERSE_URL=${DATAVERSE_URL:-"http://dataverse:8080"}
export DATAVERSE_URL

# get current dir location
SELF_LOCATION=${BOOTSTRAP_DIR}/${PERSONA}/
echo "SELF_LOCATION = $SELF_LOCATION"

echo "Running base setup-all.sh (INSECURE MODE, securing later)"
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

if [ -f "${DATAVERSES_PATH}/root.json" ]; then
    echo "Updating root collection"
    curl -X PUT "$DATAVERSE_URL/api/dataverses/root" --upload-file ${DATAVERSES_PATH}/root.json
    echo
fi

echo "Publishing root collection"
curl -X POST "${DATAVERSE_URL}/api/dataverses/:root/actions/:publish"
echo

if [ -f "${CONFIG_PATH}/cvoc_conf.json" ]; then
    echo "Configuring external vocabularies"
    curl -X PUT "$DATAVERSE_URL/api/admin/settings/:CVocConf" --upload-file ${CONFIG_PATH}/cvoc_conf.json
    echo
fi

echo "Setting up external tools"
"${SELF_LOCATION}"/init-external-tools.sh
echo

echo "Enabling file-level embargoes"
curl -X PUT $DATAVERSE_URL/api/admin/settings/:MaxEmbargoDurationInMonths -d -1
echo

echo "Configuring dataset summary fields"
curl -X PUT $DATAVERSE_URL/api/admin/settings/:CustomDatasetSummaryFields -d 'dsDescription,subject,keyword,publication,grantNumber'
echo

echo "Configuring ZIP download limit (10GB)"
curl -X PUT $DATAVERSE_URL/api/admin/settings/:ZipDownloadLimit -d 10000000000
echo

echo "Configuring footer"
curl -X PUT $DATAVERSE_URL/api/admin/settings/:FooterCopyright -d " | <a href=\"https://www.zbmed.de/en/legal-notice\" target=\"_blank\">Legal notice</a> | <a href=\"https://www.zbmed.de/en/privacy-policy\" target=\"_blank\">Privacy policy</a>"


# TODO Waiting for final version of guide
#echo "Configuring user guide link"
#curl -X PUT $DATAVERSE_URL/api/admin/settings/:NavbarGuidesUrl -d http://frl-test-dv.qa.km.k8s.zbmed.de/guides/User%20Manual_ZB%20MED%20LifeData_draft.pdf

echo "Configuring custom CSS"
curl -X PUT -d '/dv/branding/style.css' $DATAVERSE_URL/api/admin/settings/:StyleCustomizationFile
echo

echo "Configuring custom analytics code"
curl -X PUT -d '/dv/branding/matomo.html' $DATAVERSE_URL/api/admin/settings/:WebAnalyticsCode
echo

echo "Configuring custom navbar logo"
curl -X PUT -d '/logos/navbar/logo.png' $DATAVERSE_URL/api/admin/settings/:LogoCustomizationFile
echo

echo "Upload licenses"
LICENSES=$(find "${LICENSES_PATH}" -maxdepth 1 -iname 'license*.json')
while IFS= read -r LICENSE; do
  echo "Loading ${LICENSE}: "
  curl -X POST -H "Content-type: application/json" $DATAVERSE_URL/api/licenses --upload-file ${LICENSE}
  echo
done <<< "${LICENSES}"

# Last step as existence of one block is the indicator for a complete bootstrapped installation
# (see https://github.com/IQSS/dataverse/blob/v6.8/modules/container-configbaker/scripts/bootstrap.sh#L53-L58)
echo "Load custom metadata blocks"
# Load base metadata blocks
for BLOCK in codemeta computational_workflow; do
  echo "Loading base block ${BLOCK}:"
  curl -X POST -H "Content-type: text/tab-separated-values" $DATAVERSE_URL/api/admin/datasetfield/load --upload-file "${BOOTSTRAP_DIR}/base/data/metadatablocks/${BLOCK}.tsv"
  echo
done

# Find all TSV files
TSVS=$(find "${METADATABLOCKS_PATH}" -maxdepth 1 -iname '*.tsv')
# Load metadata blocks
while IFS= read -r TSV; do
  echo "Loading ${TSV}:"
  curl -X POST -H "Content-type: text/tab-separated-values" $DATAVERSE_URL/api/admin/datasetfield/load --upload-file ${TSV}
  echo
done <<< "${TSVS}"

echo "Activating metadata blocks"
curl -X POST -H "Content-Type: application/json" $DATAVERSE_URL/api/dataverses/:root/metadatablocks -d "[\"citation\",\"geospatial\",\"codemeta\",\"computational_workflow\"]"
echo

echo
echo
echo "...DONE!"