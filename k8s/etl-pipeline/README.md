# Kubernetes ETL Jobs

This directory contains Kubernetes manifests and a helper script to manage the ETL (Extract, Transform, Load) pipeline.

## Pipeline overview

The pipeline consists of four sequential stages:

1.  **Extract**: Downloads raw source data into S3 storage.
2.  **Transform**: Converts raw data from S3 into Parquet format.
3.  **Load**: Uploads the processed Parquet data into a Dataverse instance.
4.  **Publish**: Finalizes and publishes the datasets within Dataverse.

## Running the pipeline

The pipeline is available as a Helm chart.

```bash
helm upgrade --install my-etl-pipeline . -f my-values.yaml
```

See [values.yaml](values.yaml) for all available configuration options.

## Cleanup

Upon installation of the chart, Helm will print commands for uninstalling or suspending the cronjobs.

### Resetting Load Jobs

If you need to completely restart a **Load** job, you must clear the S3 checkpoints:

```bash
s3cmd rm --recursive s3://$S3_PATH/$(echo $SOURCE | tr '[:upper:]' '[:lower:]')/$(date +%y-%m-%d)-checkpoint/
```