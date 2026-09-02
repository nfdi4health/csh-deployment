# Create dataset types
curl -H "Content-Type: application/json" -X POST -d '{"name": "study", "displayName": "Study"}' $DATAVERSE_URL/api/datasets/datasetTypes
curl -H "Content-Type: application/json" -X POST -d '{"name": "substudy", "displayName": "Substudy"}' $DATAVERSE_URL/api/datasets/datasetTypes
# The type "dataset" already exists by default
#curl -H "Content-Type: application/json" -X POST -d '{"name": "dataset", "displayName": "Dataset"}' $DATAVERSE_URL/api/datasets/datasetTypes
curl -H "Content-Type: application/json" -X POST -d '{"name": "studyProtocol", "displayName": "Study protocol"}' $DATAVERSE_URL/api/datasets/datasetTypes
curl -H "Content-Type: application/json" -X POST -d '{"name": "dataDictionary", "displayName": "Data dictionary"}' $DATAVERSE_URL/api/datasets/datasetTypes
curl -H "Content-Type: application/json" -X POST -d '{"name": "informedConsentForm", "displayName": "Informed consent form"}' $DATAVERSE_URL/api/datasets/datasetTypes
curl -H "Content-Type: application/json" -X POST -d '{"name": "patientInformationSheet", "displayName": "Patient information sheet"}' $DATAVERSE_URL/api/datasets/datasetTypes
curl -H "Content-Type: application/json" -X POST -d '{"name": "manualOfOperationsSops", "displayName": "Manual of operations (SOPs)"}' $DATAVERSE_URL/api/datasets/datasetTypes
curl -H "Content-Type: application/json" -X POST -d '{"name": "statisticalAnalysisPlan", "displayName": "Statistical analysis plan"}' $DATAVERSE_URL/api/datasets/datasetTypes
curl -H "Content-Type: application/json" -X POST -d '{"name": "dataManagementPlan", "displayName": "Data management plan"}' $DATAVERSE_URL/api/datasets/datasetTypes
curl -H "Content-Type: application/json" -X POST -d '{"name": "caseReportForm", "displayName": "Case report form"}' $DATAVERSE_URL/api/datasets/datasetTypes
curl -H "Content-Type: application/json" -X POST -d '{"name": "codeBook", "displayName": "Code book"}' $DATAVERSE_URL/api/datasets/datasetTypes
curl -H "Content-Type: application/json" -X POST -d '{"name": "questionnaire", "displayName": "Questionnaire"}' $DATAVERSE_URL/api/datasets/datasetTypes
curl -H "Content-Type: application/json" -X POST -d '{"name": "interviewSchemeAndThemes", "displayName": "Interview scheme and themes"}' $DATAVERSE_URL/api/datasets/datasetTypes
curl -H "Content-Type: application/json" -X POST -d '{"name": "observationGuide", "displayName": "Observation guide"}' $DATAVERSE_URL/api/datasets/datasetTypes
curl -H "Content-Type: application/json" -X POST -d '{"name": "discussionGuide", "displayName": "Discussion guide"}' $DATAVERSE_URL/api/datasets/datasetTypes
curl -H "Content-Type: application/json" -X POST -d '{"name": "participantTasks", "displayName": "Participant tasks"}' $DATAVERSE_URL/api/datasets/datasetTypes
curl -H "Content-Type: application/json" -X POST -d '{"name": "otherDataCollectionInstrument", "displayName": "Other data collection instrument"}' $DATAVERSE_URL/api/datasets/datasetTypes
curl -H "Content-Type: application/json" -X POST -d '{"name": "otherStudyDocument", "displayName": "Other study document"}' $DATAVERSE_URL/api/datasets/datasetTypes
curl -H "Content-Type: application/json" -X POST -d '{"name": "other", "displayName": "Other"}' $DATAVERSE_URL/api/datasets/datasetTypes
curl -H "Content-Type: application/json" -X POST -d '{"name": "registry", "displayName": "Registry"}' $DATAVERSE_URL/api/datasets/datasetTypes
curl -H "Content-Type: application/json" -X POST -d '{"name": "secondaryDataSource", "displayName": "Secondary data source"}' $DATAVERSE_URL/api/datasets/datasetTypes
curl -H "Content-Type: application/json" -X POST -d '{"name": "biobank", "displayName": "Biobank"}' $DATAVERSE_URL/api/datasets/datasetTypes

# Activate dataset types for all collections
ALLOWED_DATASET_TYPES="study,substudy,dataset,studyProtocol,dataDictionary,informedConsentForm,patientInformationSheet,manualOfOperationsSops,statisticalAnalysisPlan,dataManagementPlan,caseReportForm,codeBook,questionnaire,interviewSchemeAndThemes,observationGuide,discussionGuide,participantTasks,otherDataCollectionInstrument,otherStudyDocument,other,registry,secondaryDataSource,biobank"
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
