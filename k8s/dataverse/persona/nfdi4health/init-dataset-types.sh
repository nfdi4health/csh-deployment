# Create dataset types
DATASET_TYPES=(
  "study|Study"
  "substudy|Substudy"
  "studyProtocol|Study protocol"
  "dataDictionary|Data dictionary"
  "informedConsentForm|Informed consent form"
  "patientInformationSheet|Patient information sheet"
  "manualOfOperationsSops|Manual of operations (SOPs)"
  "statisticalAnalysisPlan|Statistical analysis plan"
  "dataManagementPlan|Data management plan"
  "caseReportForm|Case report form"
  "codeBook|Code book"
  "questionnaire|Questionnaire"
  "interviewSchemeAndThemes|Interview scheme and themes"
  "observationGuide|Observation guide"
  "discussionGuide|Discussion guide"
  "participantTasks|Participant tasks"
  "otherDataCollectionInstrument|Other data collection instrument"
  "otherStudyDocument|Other study document"
  "other|Other"
  "registry|Registry"
  "secondaryDataSource|Secondary data source"
  "biobank|Biobank"
)

for DATASET_TYPE in "${DATASET_TYPES[@]}"; do
  IFS='|' read -r NAME DISPLAY_NAME <<< "$DATASET_TYPE"
  DATASET_TYPE_JSON=$(jq -cn --arg name "$NAME" --arg displayName "$DISPLAY_NAME" \
    '{name: $name, displayName: $displayName}')
  curl -H "Content-Type: application/json" -X POST \
    -d "$DATASET_TYPE_JSON" "$DATAVERSE_URL/api/datasets/datasetTypes"
done

# The type "dataset" already exists by default and is intentionally included
DATASET_TYPE_NAMES=()
for DATASET_TYPE in "${DATASET_TYPES[@]}"; do
  DATASET_TYPE_NAMES+=("${DATASET_TYPE%%|*}")
done
ALLOWED_DATASET_TYPES="dataset,$(IFS=,; echo "${DATASET_TYPE_NAMES[*]}")"
START=0

while true; do
  SEARCH_RESPONSE=$(curl "$DATAVERSE_URL/api/search?type=dataverse&q=*&start=$START")
  TOTAL_COUNT=$(jq -r '.data.total_count' <<< "$SEARCH_RESPONSE")
  COUNT_IN_RESPONSE=$(jq -r '.data.count_in_response' <<< "$SEARCH_RESPONSE")

  while IFS= read -r DATAVERSE_ID; do
    echo "Activating dataset types for dataverse $DATAVERSE_ID"
    curl -X PUT "$DATAVERSE_URL/api/dataverses/$DATAVERSE_ID/attribute/allowedDatasetTypes?value=$ALLOWED_DATASET_TYPES"
    echo
  done < <(jq -r '.data.items[] | .identifier' <<< "$SEARCH_RESPONSE")

  if (( COUNT_IN_RESPONSE == 0 || START + COUNT_IN_RESPONSE >= TOTAL_COUNT )); then
    break
  fi

  START=$((START + COUNT_IN_RESPONSE))
done
