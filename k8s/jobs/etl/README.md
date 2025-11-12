# Running ETL Jobs

This guide explains how to run ETL conversion jobs using Spark on Kubernetes.

## Configuration

1. Add S3 credentials and endpoint configuration in `base/kustomization.yaml`.
2. Add job-specific configuration in the relevant directory, e.g. `ctgov/kustomization.yaml`.

## Running a Job

1. Apply the job configuration for the specific ETL job you want to run:

   ```bash
   kubectl apply -k ctgov/
   ```

**Note:** Every instance of an ETL job currently uses the same job names, so you cannot run multiple instances of the same job in parallel. Before starting a new run, delete the existing job first, for example:
```bash
kubectl -n spark delete job ctgov-load-job ctgov-transform-job
```

You can also clean up the driver pods if you no longer need the logs:

```bash
kubectl -n spark delete pods -l spark-role=driver
```

Also, if you want to completely restart a load job, don't forget to clear the checkpoints in S3:

```bash
s3cmd rm --recursive s3://$SOURCE_PATH-checkpoint/
```