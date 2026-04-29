# K8s ETL Jobs

This directory contains Kubernetes manifests and a helper script to run the ETL (Extract, Transform, Load) pipeline. The pipeline consists of two main jobs:
1. **Transform**: Converts source data from S3 into Parquet format.
2. **Load**: Submits the converted Parquet data to a Dataverse instance.

## Running the Jobs

To run the ETL pipeline, use the `run.sh` script. You must provide several environment variables for configuration.

```shell
chmod +x run.sh

# Required variables
export SOURCE="CTIS"
export SOURCE_PATH="km-bonn-prod-nfdi4health-etl-data/ctis/2026-04-15"
export COLLECTIONS_PATH="km-bonn-prod-nfdi4health-etl-data/collections.json"
export DATAVERSE_HOST="http://my-dataverse-svc.default.svc.cluster.local:8080"
export DATAVERSE_API_KEY="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
export AWS_ENDPOINT_URL="https://s3.de-west-1.psmanaged.com"
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"

# Optional variables
export NAMESPACE="default"
export ETL_PIPELINE_IMAGE_TAG="latest"

./run.sh
```

### Environment Variables

| Variable | Description | Example                              |
| :--- | :--- |:-------------------------------------|
| `SOURCE` | Name of the data source (determines transformation logic). | `CTIS`                               |
| `SOURCE_PATH` | S3 path where the source data is located. | `bucket/path/to/data`                |
| `COLLECTIONS_PATH` | S3 path where the collection JSON is located. | `bucket/collections.json`            |
| `DATAVERSE_HOST` | URL of the target Dataverse instance. | `http://dataverse.example.org`       |
| `DATAVERSE_API_KEY` | API key for Dataverse authentication. | `...`                                |
| `AWS_ENDPOINT_URL` | S3 endpoint URL. | `https://s3.de-west-1.psmanaged.com` |
| `AWS_ACCESS_KEY_ID` | S3 access key ID. | `...`                                |
| `AWS_SECRET_ACCESS_KEY` | S3 secret access key. | `...`                                |
| `NAMESPACE` | Kubernetes namespace to run the jobs in (Default: `default`). | `my-ns`                              |
| `ETL_PIPELINE_IMAGE_TAG` | Tag of the `csh-etl-pipeline` image (Default: `latest`). | `v1.2.3`                             |

## Cleanup

The `run.sh` script will print the exact command to delete the created Jobs and Secret after the execution is finished. It follows this pattern:

```shell
kubectl -n $NAMESPACE delete job etl-job-transform-$PIPELINE_RUN_NAME etl-job-load-$PIPELINE_RUN_NAME && \
kubectl -n $NAMESPACE delete secret etl-job-credentials-$PIPELINE_RUN_NAME
```

You can also clean up all driver pods if you no longer need the logs:

```bash
kubectl -n $NAMESPACE delete pods -l spark-role=driver
```

Also, if you want to completely restart a load job, remember to clear the checkpoints in S3:

```bash
s3cmd rm --recursive s3://$SOURCE_PATH-checkpoint/
```