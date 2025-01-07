# Install dataverse
`helm install my-dataverse ./dataverse`

# Backup & Restore

## Database

### Restoring a database backup

Postgres is configured to automatically create and store a logical backup in S3. You can use the script at
[`scripts/load_dataverse_backup.sh`][1] to load it into a Dataverse deployed on Kubernetes.

[1]: https://github.com/nfdi4health/csh-deployment/blob/main/scripts/load_dataverse_backup.sh

Before running the script, you must set these env variables:

- `SOURCE_DATAVERSE_NAME`, the deployment name of the source Dataverse
- `SOURCE_DATAVERSE_CONTEXT`, the Kubernetes context name of the source Dataverse
- `DESTINATION_DATAVERSE_NAME`, the deployment name of the destination Dataverse
- `DESTINATION_DATAVERSE_CONTEXT`, the Kubernetes context name of the destination Dataverse
- `LOGICAL_BACKUP_S3_BUCKET`, the S3 bucket where the backup is located
- `SCOPE` and `LOGICAL_BACKUP_S3_BUCKET_SCOPE_SUFFIX`, define the directory inside the S3 bucket where the backup is
   located
- (optional) `S3_CONFIG_FILE`, path to a s3cmd config file

The values for `LOGICAL_BACKUP_S3_BUCKET`, `SCOPE` and `LOGICAL_BACKUP_S3_BUCKET_SCOPE_SUFFIX` can be found using
`kubectl describe pod` on one of the backup job pods.

Since reindexing the entire Dataverse database into the Solr index may take a long time depending on the number of
datasets, the script also creates and loads a backup of the Solr index instead.
If you don't have a lot of datasets and prefer reindexing, you can comment out the script section responsible for
Solr backup creation and loading, and comment in the section for reindexing.

### Creating a database backup

1. Login into the postgres pod and create and compress a logical backup.

   `kubectl exec -it pods/$POSTGRES_POD_NAME -- /bin/bash`
   
   `pg_dumpall -f /tmp/jd.dump -U dataverse`
   
   `gzip /tmp/jd.dump`

2. Copy the logical backup to your local computer

   `kubectl cp $POSTGRES_POD_NAME:/tmp/jd.dump.gz ./jd.dump.gz`