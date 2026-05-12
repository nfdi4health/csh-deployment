# Kubernetes ETL Jobs

This directory contains Kubernetes manifests and a helper script to manage the ETL (Extract, Transform, Load) pipeline.

## Pipeline Overview

The pipeline consists of four sequential stages:

1.  **Extract**: Downloads raw source data into S3 storage.
2.  **Transform**: Converts raw data from S3 into Parquet format.
3.  **Load**: Uploads the processed Parquet data into a Dataverse instance.
4.  **Publish**: Finalizes and publishes the datasets within Dataverse.

## Running the Pipeline

Use the `run.sh` script to execute the pipeline. The script requires several environment variables for configuration.

### Usage Example

```shell
# Make the script executable
chmod +x run.sh

# Define required variables
export SOURCE="CTIS"
export S3_PATH="km-bonn-prod-nfdi4health-etl-data"
export COLLECTIONS_PATH="km-bonn-prod-nfdi4health-etl-data/collections.json"
export DATAVERSE_HOST="http://my-dataverse-svc.default.svc.cluster.local:8080"
export DATAVERSE_API_KEY="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
export AWS_ENDPOINT_URL="https://s3.de-west-1.psmanaged.com"
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"

# Define optional variables (defaults shown)
export NAMESPACE="default"
export ETL_PIPELINE_IMAGE_TAG="latest"

# Execute the script
./run.sh
```

### Configuration Variables

| Variable | Description | Example |
| :--- | :--- | :--- |
| `SOURCE` | Data source identifier (determines transformation logic). | `CTIS` |
| `S3_PATH` | S3 path for storing pipeline data. | `bucket/path/to/data` |
| `COLLECTIONS_PATH` | S3 path to the collection JSON file. | `bucket/collections.json` |
| `DATAVERSE_HOST` | URL of the target Dataverse instance. | `http://dataverse.example.org` |
| `DATAVERSE_API_KEY` | API key for Dataverse authentication. | `...` |
| `AWS_ENDPOINT_URL` | S3 endpoint URL. | `https://s3.de-west-1.psmanaged.com` |
| `AWS_ACCESS_KEY_ID` | S3 access key ID. | `...` |
| `AWS_SECRET_ACCESS_KEY` | S3 secret access key. | `...` |
| `NAMESPACE` | K8s namespace for the jobs (Default: `default`). | `my-ns` |
| `ETL_PIPELINE_IMAGE_TAG` | Docker image tag for `csh-etl-pipeline` (Default: `latest`). | `v1.2.3` |

## Cleanup

Upon completion, `run.sh` provides a `kubectl` command to delete the created Jobs and Secrets. The resources are named using a generated `$PIPELINE_RUN_NAME`.

**Format:** `[source]-[timestamp]` (e.g., `ctis-05-05-26--16-02-53`).

To manually clean up, use the command printed by the script or follow this pattern:
```shell
kubectl -n $NAMESPACE delete job \
  etl-job-extract-$PIPELINE_RUN_NAME \
  etl-job-transform-$PIPELINE_RUN_NAME \
  etl-job-load-$PIPELINE_RUN_NAME \
  etl-job-publish-$PIPELINE_RUN_NAME && \
kubectl -n $NAMESPACE delete secret etl-job-credentials-$PIPELINE_RUN_NAME
```

### Resetting Load Jobs
If you need to completely restart a **Load** job, you must clear the S3 checkpoints:
```bash
s3cmd rm --recursive s3://$S3_PATH/$(echo $SOURCE | tr '[:upper:]' '[:lower:]')/$(date +%y-%m-%d)-checkpoint/
```