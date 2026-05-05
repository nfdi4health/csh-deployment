set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

MISSING_VARS=()

if [ -z "$SOURCE" ]; then
  MISSING_VARS+=("SOURCE: Insert name of data source to determine which transformation must be applied. Example: \"CTIS\"")
fi

if [ -z "$S3_PATH" ]; then
  MISSING_VARS+=("S3_PATH: Insert S3 path where data should be stored. Example: \"km-bonn-prod-nfdi4health-etl-data\"")
fi

if [ -z "$COLLECTIONS_PATH" ]; then
  MISSING_VARS+=("COLLECTIONS_PATH: Insert path where collection JSON is located. Example: \"km-bonn-prod-nfdi4health-etl-data/collections.json\"")
fi

if [ -z "$DATAVERSE_HOST" ]; then
  MISSING_VARS+=("DATAVERSE_HOST: Insert Dataverse URL. Example: \"http://my-dataverse-svc.default.svc.cluster.local:8080\"")
fi

if [ -z "$AWS_ENDPOINT_URL" ]; then
  MISSING_VARS+=("AWS_ENDPOINT_URL: Insert S3 endpoint URL. Example: \"https://s3.de-west-1.psmanaged.com\"")
fi

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  MISSING_VARS+=("AWS_ACCESS_KEY_ID: Insert S3 access key ID.")
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  MISSING_VARS+=("AWS_SECRET_ACCESS_KEY: Insert S3 secret access key.")
fi

if [ -z "$DATAVERSE_API_KEY" ]; then
  MISSING_VARS+=("DATAVERSE_API_KEY: Insert Dataverse API key.")
fi

if [ ${#MISSING_VARS[@]} -ne 0 ]; then
  echo "ERROR: The following required environment variables are missing:"
  for msg in "${MISSING_VARS[@]}"; do
    echo "  - $msg"
  done
  exit 1
fi

MISSING_OPTIONAL_VARS=()

if [ -z "$NAMESPACE" ]; then
  MISSING_OPTIONAL_VARS+=("NAMESPACE: Insert name of Kubernetes namespace. Default: default")
fi

if [ -z "$ETL_PIPELINE_IMAGE_TAG" ]; then
  MISSING_OPTIONAL_VARS+=("ETL_PIPELINE_IMAGE_TAG: Insert tag of ETL pipeline image to be used. Default: latest")
fi

if [ ${#MISSING_OPTIONAL_VARS[@]} -ne 0 ]; then
  echo "INFO: The following optional environment variables are not supplied, using default values:"
  for msg in "${MISSING_OPTIONAL_VARS[@]}"; do
    echo "  - $msg"
  done
fi

# Load default values for optional env variables if necessary
export NAMESPACE=${NAMESPACE:-default}
export ETL_PIPELINE_IMAGE_TAG=${ETL_PIPELINE_IMAGE_TAG:-latest}

# Generate name of this pipeline run
export PIPELINE_RUN_NAME=$(echo "$(echo $SOURCE | tr '[:upper:]' '[:lower:]')-$(date +%d-%m-%y--%H-%M-%S)")

# Generate output path for extract job
export EXTRACT_PATH=$(echo "${S3_PATH}/$(echo $SOURCE | tr '[:upper:]' '[:lower:]')/$(date +%y-%m-%d).parquet")

# Generate output path for transform job
export OUTPUT_PATH=${EXTRACT_PATH%.parquet}-converted.parquet

# Generate checkpoint path for load job
export CHECKPOINT_PATH=${EXTRACT_PATH%.parquet}-checkpoint

# Create k8s objects
cat $SCRIPT_DIR/secrets.yaml | envsubst '$NAMESPACE $PIPELINE_RUN_NAME $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY $DATAVERSE_API_KEY' | kubectl apply -f -
cat $SCRIPT_DIR/rbac.yaml | envsubst '$NAMESPACE' | kubectl apply -f -
cat $SCRIPT_DIR/etl_jobs.yaml | envsubst '$NAMESPACE $PIPELINE_RUN_NAME $SOURCE $AWS_ENDPOINT_URL $EXTRACT_PATH $OUTPUT_PATH $CHECKPOINT_PATH $COLLECTIONS_PATH $ETL_PIPELINE_IMAGE_TAG $DATAVERSE_HOST' | kubectl apply -f -

echo
echo "INFO: To clean up, call:"
echo "  kubectl -n $NAMESPACE delete job etl-job-extract-$PIPELINE_RUN_NAME etl-job-transform-$PIPELINE_RUN_NAME etl-job-load-$PIPELINE_RUN_NAME etl-job-publish-$PIPELINE_RUN_NAME && kubectl -n $NAMESPACE delete secret etl-job-credentials-$PIPELINE_RUN_NAME"