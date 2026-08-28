# Install dataverse
`helm install my-dataverse ./dataverse`

# Backup & Restore

## Database

### Restoring a database backup

Postgres is configured to automatically create and store a logical backup in S3. You can use the script at
[`scripts/load_dataverse_backup.sh`][1] to load it into a Dataverse deployed on Kubernetes.

[1]: https://github.com/nfdi4health/csh-deployment/blob/main/scripts/load_dataverse_backup.sh

The source and destination releases, Kubernetes contexts, namespaces, and local `s3cmd` configuration can be
selected with command-line options. Run `scripts/load_dataverse_backup.sh --help` for the complete list. For example,
to restore only the Solr backup after the PostgreSQL restore has already succeeded:

```shell
scripts/load_dataverse_backup.sh --skip-postgres \
  --source-name my-production-dataverse --source-context prod \
  --destination-name my-development-dataverse --destination-context dev
```

By default, the script discovers the PostgreSQL backup bucket, prefix, scope, and scope suffix from the source
PostgreSQL cluster's logical-backup CronJob. They can be overridden with the corresponding `--s3-*` options.
S3 credentials remain in the local `s3cmd` configuration selected with `--s3-config-file`.

Since reindexing the entire Dataverse database into the Solr index may take a long time depending on the number of
datasets, the script creates and loads a Solr backup by default. Use `--solr-mode reindex` (or `--reindex`) to clear
the destination index and trigger a Dataverse reindex instead.

### Creating a database backup

1. Login into the postgres pod and create and compress a logical backup.

   `kubectl exec -it pods/$POSTGRES_POD_NAME -- /bin/bash`
   
   `pg_dumpall -f /tmp/jd.dump -U dataverse`
   
   `gzip /tmp/jd.dump`

2. Copy the logical backup to your local computer

   `kubectl cp $POSTGRES_POD_NAME:/tmp/jd.dump.gz ./jd.dump.gz`
