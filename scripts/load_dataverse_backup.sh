#!/bin/bash

S3_CONFIG_FILE="${S3_CONFIG_FILE:-'~/.s3cfg'}"

# Computed from env variables above
LAST_BACKUP_FILE=$(s3cmd ls s3://$LOGICAL_BACKUP_S3_BUCKET/spilo/$SCOPE$LOGICAL_BACKUP_S3_BUCKET_SCOPE_SUFFIX/logical_backups/ -c $S3_CONFIG_FILE | sort | tail -n 1 | awk '{print $4}')
POSTGRES_POD_NAME=${DESTINATION_DATAVERSE_NAME}-dataverse-postgres-0
DATAVERSE_POD_NAME=${DESTINATION_DATAVERSE_NAME}-dataverse-0

echo "Downloading backup from S3..."
s3cmd get $LAST_BACKUP_FILE . -c $S3_CONFIG_FILE --skip-existing

echo "Copying backup to postgres pod..."
kubectl cp $(basename $LAST_BACKUP_FILE) $POSTGRES_POD_NAME:/tmp/

echo "Unzipping backup..."
kubectl exec $POSTGRES_POD_NAME -- gunzip /tmp/$(basename $LAST_BACKUP_FILE)

echo "Emptying database..."
kubectl exec $POSTGRES_POD_NAME -- psql -P pager=off -U dataverse -c "-- Recreate the schema
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

-- Restore default permissions
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;"
# source: https://stackoverflow.com/a/61221726

echo "Loading backup into database..."
kubectl exec $POSTGRES_POD_NAME -- psql -P pager=off -U dataverse -f /tmp/$(basename $LAST_BACKUP_FILE .gz) template1


echo "Updating database passwords..."
kubectl get secret | grep ${DESTINATION_DATAVERSE_NAME}-dataverse-postgres.credentials.postgresql.acid.zalan.do | awk '{print $1}' | while read SECRET; do kubectl exec $POSTGRES_POD_NAME -- psql -P pager=off -U dataverse -c "ALTER USER $(echo $SECRET | awk -F. '{print $1}') WITH PASSWORD '$(kubectl get secrets/$SECRET -o=jsonpath="{.data.password}" | base64 -d)';"; done

echo "Restarting dataverse pod..."
kubectl delete pod $DATAVERSE_POD_NAME
kubectl wait --for=condition=Ready --timeout=-1s pod/$DATAVERSE_POD_NAME

# Using port 8081 because 8080 is often already used if currently developing with Dataverse
DATAVERSE_LOCAL_PORT=8081
DATAVERSE_REMOTE_PORT=8080

echo "Starting re-index..."
kubectl port-forward $DATAVERSE_POD_NAME $DATAVERSE_LOCAL_PORT:$DATAVERSE_REMOTE_PORT >/dev/null &
PORT_FORWARD_PID=$!
# Kill the port-forward when this script exits
trap '{
    kill $PORT_FORWARD_PID 2>/dev/null
}' EXIT
# Wait for port to be available
while ! nc -vz localhost $DATAVERSE_LOCAL_PORT >/dev/null 2>&1; do
    sleep 0.1
done
curl http://localhost:$DATAVERSE_LOCAL_PORT/api/admin/index/clear
echo
curl http://localhost:$DATAVERSE_LOCAL_PORT/api/admin/index
echo

echo
echo "Done! Please wait for the re-indexing to finish, then the backup loading will be complete."
