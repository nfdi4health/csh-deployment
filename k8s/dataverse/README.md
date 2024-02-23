# Install dataverse
`helm install my-dataverse ./dataverse`

# Backup & Restore
## Restore database backup

### Get a logical backup
#### From S3 
Postgres is configured to automatically create and store a logical backup in S3. You can use the following to find the most recent one.
1. Find the newest backup
   
   `s3cmd ls s3://$LOGICAL_BACKUP_S3_BUCKET/spilo/$SCOPE$LOGICAL_BACKUP_S3_BUCKET_SCOPE_SUFFIX/logical_backups/`
   
   The env variable values can be found using `kubectl describe job` on one of the backup jobs.

2. Copy the backup to your local computer

   `s3cmd get s3://$LOGICAL_BACKUP_S3_BUCKET/spilo/$SCOPE$LOGICAL_BACKUP_S3_BUCKET_SCOPE_SUFFIX/logical_backups/1695726061.sql.gz .`
   
   (replace the file name with the name of the newest backup found in step 1)

### Copy the backup into the postgres pod

3. Copy a logical backup from local computer it into the postgres pod

   `kubectl cp 1695726061.sql.gz $POSTGRES_POD_NAME:/tmp/1695726061.sql.gz`
   
   (replace the file name)

4. Extract the backup

   `kubectl exec -it $POSTGRES_POD_NAME -- /bin/bash`

   `gunzip /tmp/1695726061.sql.gz`

5.  Empty the database before loading the backup
   `kubectl exec -it $POSTGRES_POD_NAME -- psql -U dataverse `
   ```
   -- Recreate the schema
   DROP SCHEMA public CASCADE;
   CREATE SCHEMA public;

   -- Restore default permissions
   GRANT ALL ON SCHEMA public TO postgres;
   GRANT ALL ON SCHEMA public TO public;
   ```

   (source: https://stackoverflow.com/a/61221726)

6. Load the backup into the database
   `kubectl exec -it $POSTGRES_POD_NAME -- bash`
   `psql -U dataverse -f /tmp/1690815661.sql template1`

   (replace the file name)

7. Configure and sync postgres secrets with k8s.

   The  postgres deployment creates at least three k8s secrets. Since you just loaded a backup they (k8s secret) are out of sync.
   Either those k8s secrets must be updated with the values from the just loaded backup or the database must be adapted to the values of the k8s secrets
   We update the values within the db. First, we obtain list of accounts to update, then we obtain the passwords and update the db values.

   Get the list of accounts:

   `kubectl get secret | grep ${DEPLOYMENTNAME}-dataverse-postgres.credentials.postgresql.acid.zalan.do `
   
   Repeat the following for each account:

      Get the password for the user `dataverse`:
   
      `kubectl get secrets/dataverse.${DEPLOYMENTNAME}-dataverse-postgres.credentials.postgresql.acid.zalan.do  -o=jsonpath="{.data.password}" | base64 -d`
   
      Update the password for the user `dataverse`:
   
      `kubectl exec -it $POSTGRES_POD_NAME -- psql -U dataverse "ALTER USER dataverse WITH PASSWORD '...'"`

8. Start SOLR reindex

   `curl http://localhost:8080/api/admin/index`

   (see https://guides.dataverse.org/en/latest/admin/solr-search-index.html#clear-and-reindex)

## Creating a database backup

1. Login into the postgres pod and create and compress a logical backup.

   `kubectl exec -it pods/$POSTGRES_POD_NAME -- /bin/bash`
   
   `pg_dumpall -f /tmp/jd.dump -U dataverse`
   
   `gzip /tmp/jd.dump`

2. Copy the logical backup to your local computer

   `kubectl cp $POSTGRES_POD_NAME:/tmp/jd.dump.gz ./jd.dump.gz`