# Install dataverse

## If you would like to install custom 
`helm install my-dataverse ./dataverse`


# Configure custom schema
## Enable admin api via localhost port forwarding
### Allow all API calls
`export DATAVERSE_POD="my-dataverse-dataverse-0"`

`kubectl port-forward pods/${DATAVERSE_POD} 8080:8080`

`curl -X PUT -d allow http://localhost:8080/api/admin/settings/:BlockedApiPolicy`

## Update SOLR fields with custom metadata info
### Login into the solr helper container and execute the update 
`export SOLR_POD="my-dataverse-dataverse-solr-0"`

`kubectl exec -i -t $SOLR_POD  --container dataverse-solr-config  -- /bin/sh`

Until the image is fixed, manually add the `ed` package. 
`apk add ed` 

`curl "http://${DATAVERSE_HOSTNAME}:8080/api/admin/index/solr/schema" | /scripts/update-fields.sh /template/conf/schema.xml`

`cp /template/conf/schema.xml /var/solr/data/collection1/schema.xml `

`curl "http://localhost:8983/solr/admin/cores?action=RELOAD&core=collection1"`

## Loading a backup

1. Find the newest backup
   
   `s3cmd ls s3://$LOGICAL_BACKUP_S3_BUCKET/spilo/$SCOPE$LOGICAL_BACKUP_S3_BUCKET_SCOPE_SUFFIX/logical_backups/`
   
   The env variable values can be found using `kubectl describe job` on one of the backup jobs.

2. Copy the backup

   `s3cmd get s3://$LOGICAL_BACKUP_S3_BUCKET/spilo/$SCOPE$LOGICAL_BACKUP_S3_BUCKET_SCOPE_SUFFIX/logical_backups/1695726061.sql.gz .`
   
   (replace the file name with the name of the newest backup found in step 1)

3. Extract the sql file and copy it into the postgres pod

   `kubectl cp 1695726061.sql $POSTGRES_POD_NAME:/tmp`
   
   (replace the file name)

4. Empty the database before loading the backup

   `kubectl exec -it $POSTGRES_POD_NAME -- bash`
   
   `psql -U dataverse`

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

   `psql -U dataverse -f /tmp/1690815661.sql template1`

   (replace the file name)

7. Correct the database user password: Log into a container of the pod ...-dataverse-0, then run `echo $DATAVERSE_DB_PASSWORD`. Set this password in psql using `ALTER USER dataverse WITH PASSWORD '...';`

8. Start SOLR reindex

   `curl http://localhost:8080/api/admin/index`

   (see https://guides.dataverse.org/en/latest/admin/solr-search-index.html#clear-and-reindex)
