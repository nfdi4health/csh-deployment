#!/bin/bash

LOGICAL_BACKUP_S3_BUCKET=
SCOPE=
LOGICAL_BACKUP_S3_BUCKET_SCOPE_SUFFIX=
S3_CONFIG_FILE=
# Computed from env variables above
LAST_BACKUP_FILE=$(s3cmd ls s3://$LOGICAL_BACKUP_S3_BUCKET/spilo/$SCOPE$LOGICAL_BACKUP_S3_BUCKET_SCOPE_SUFFIX/logical_backups/ -c $S3_CONFIG_FILE | sort | tail -n 1 | awk '{print $4}')
POSTGRES_POD_NAME=${DESTINATION_DATAVERSE_NAME}-dataverse-postgres-0
DATAVERSE_POD_NAME=${DESTINATION_DATAVERSE_NAME}-dataverse-0

echo "Downloading backup from S3..."
s3cmd get $LAST_BACKUP_FILE . -c $S3_CONFIG_FILE --skip-existing


SOURCE_DATAVERSE_NAME=
SOURCE_DATAVERSE_CONTEXT=
DESTINATION_DATAVERSE_NAME=
DESTINATION_DATAVERSE_CONTEXT=

S3_CONFIG_FILE="${S3_CONFIG_FILE:-'~/.s3cfg'}"


echo "Copying backup to postgres pod..."
kubectl cp $(basename $LAST_BACKUP_FILE) $POSTGRES_POD_NAME:/tmp/ --context $DESTINATION_DATAVERSE_CONTEXT

echo "Unzipping backup..."
kubectl exec $POSTGRES_POD_NAME --context $DESTINATION_DATAVERSE_CONTEXT -- gunzip /tmp/$(basename $LAST_BACKUP_FILE)

echo "Emptying database..."
kubectl exec $POSTGRES_POD_NAME --context $DESTINATION_DATAVERSE_CONTEXT -- psql -P pager=off -U dataverse -c "-- Recreate the schema
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

-- Restore default permissions
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;"
# source: https://stackoverflow.com/a/61221726

echo "Loading backup into database..."
kubectl exec $POSTGRES_POD_NAME --context $DESTINATION_DATAVERSE_CONTEXT -- psql -P pager=off -U dataverse -f /tmp/$(basename $LAST_BACKUP_FILE .gz) template1


echo "Updating database passwords..."
kubectl get secret --context $DESTINATION_DATAVERSE_CONTEXT | grep ${DESTINATION_DATAVERSE_NAME}-dataverse-postgres.credentials.postgresql.acid.zalan.do | awk '{print $1}' | while read SECRET; do kubectl exec $POSTGRES_POD_NAME --context $DESTINATION_DATAVERSE_CONTEXT -- psql -P pager=off -U dataverse -c "ALTER USER $(echo $SECRET | awk -F. '{print $1}') WITH PASSWORD '$(kubectl get secrets/$SECRET -o=jsonpath="{.data.password}" --context $DESTINATION_DATAVERSE_CONTEXT | base64 -d)';"; done

echo "Restarting dataverse pod..."
kubectl delete pod $DATAVERSE_POD_NAME --context $DESTINATION_DATAVERSE_CONTEXT
kubectl wait --for=condition=Ready --timeout=-1s --context $DESTINATION_DATAVERSE_CONTEXT pod/$DATAVERSE_POD_NAME
#
## NOTE: The following block is commented out because it's no longer feasible time-wise to reindex Dataverse after
# loading a backup. Since we have over 25,000 datasets, it takes too long.
# Instead, we also load a backup for the Solr index.
# Using port 8081 because 8080 is often already used if currently developing with Dataverse
#DATAVERSE_LOCAL_PORT=8086
#DATAVERSE_REMOTE_PORT=8080
#
#echo "Starting re-index..."
#kubectl port-forward $DATAVERSE_POD_NAME $DATAVERSE_LOCAL_PORT:$DATAVERSE_REMOTE_PORT >/dev/null &
#PORT_FORWARD_PID=$!
## Kill the port-forward when this script exits
#trap '{
#    kill $PORT_FORWARD_PID 2>/dev/null
#}' EXIT
## Wait for port to be available
#while ! nc -vz localhost $DATAVERSE_LOCAL_PORT >/dev/null 2>&1; do
#    sleep 0.1
#done
#curl http://localhost:$DATAVERSE_LOCAL_PORT/api/admin/index/clear
#echo
#curl http://localhost:$DATAVERSE_LOCAL_PORT/api/admin/index
#echo

need_to_create_solr_backup () {
    echo "Checking age of latest backup of source Solr..."
    SOLR_BACKUP_RESPONSE=$(kubectl exec -it ${SOURCE_DATAVERSE_NAME}-dataverse-solr-0 --context $SOURCE_DATAVERSE_CONTEXT --container solr -- curl localhost:8983/solr/collection1/replication?command=details)
    SOLR_BACKUP_STATUS=$(echo $SOLR_BACKUP_RESPONSE | jq -r '.details.backup.status')
    if [[ "$SOLR_BACKUP_STATUS" == "success" ]]; then
        SOLR_BACKUP_TIMESTAMP=$(echo $SOLR_BACKUP_RESPONSE | jq -r '.details.backup.snapshotCompletedAt')

        SOLR_BACKUP_TIMESTAMP_DATE=$(echo $SOLR_BACKUP_TIMESTAMP | cut -d'T' -f1)
        SOLR_BACKUP_TIMESTAMP_HOUR=$(echo $SOLR_BACKUP_TIMESTAMP | cut -d'T' -f2 | cut -d':' -f1)

        CURRENT_DATE=$(date -u +"%Y-%m-%d")
        CURRENT_HOUR=$(date -u +"%H")

        if [[ "$SOLR_BACKUP_TIMESTAMP_DATE" == "$CURRENT_DATE" && "$SOLR_BACKUP_TIMESTAMP_HOUR" == "$CURRENT_HOUR" ]]; then
            # The timestamp is within the current hour
            echo "Backup is not too old."
            return 1
        else
            echo "Backup is too old."
            return 0
        fi
    elif [[ "$SOLR_BACKUP_STATUS" == "null" ]]; then
      echo "No backup exists."
      return 0
    fi
}

create_solr_backup () {
    echo "Creating backup of source Solr..."
    kubectl exec ${SOURCE_DATAVERSE_NAME}-dataverse-solr-0 --context $SOURCE_DATAVERSE_CONTEXT --container solr -- curl -s "localhost:8983/solr/collection1/replication?command=backup&numberToKeep=1"; echo
    while true; do
        SOLR_BACKUP_RESPONSE=$(kubectl exec ${SOURCE_DATAVERSE_NAME}-dataverse-solr-0 --context $SOURCE_DATAVERSE_CONTEXT --container solr -- curl localhost:8983/solr/collection1/replication?command=details)
        SOLR_BACKUP_STATUS=$(echo $SOLR_BACKUP_RESPONSE | jq -r '.details.backup.status')
        if [[ "$SOLR_BACKUP_STATUS" == "success" ]]; then
            break
        fi
        echo "Waiting for Solr backup to be completed..."
        sleep 1
    done
}

if need_to_create_solr_backup; then
    create_solr_backup
fi

SOLR_BACKUP_NAME=$(echo $SOLR_BACKUP_RESPONSE | jq -r '.details.backup.directoryName')

if kubectl exec ${DESTINATION_DATAVERSE_NAME}-dataverse-solr-0 --container solr --context $DESTINATION_DATAVERSE_CONTEXT -- sh -c "[ -d /var/solr/data/collection1/data/${SOLR_BACKUP_NAME} ]"; then
    echo "Backup was already copied to destination Solr."
else
    echo "Copying completed backup ${SOLR_BACKUP_NAME} to destination Solr... (this may take some time)"
    kubectl exec ${SOURCE_DATAVERSE_NAME}-dataverse-solr-0 --container solr --context $SOURCE_DATAVERSE_CONTEXT -- tar -zcf /tmp/${SOLR_BACKUP_NAME}.tar.gz -C /var/solr/data/collection1/data/ ${SOLR_BACKUP_NAME} > /dev/null
    kubectl cp ${SOURCE_DATAVERSE_NAME}-dataverse-solr-0:/tmp/${SOLR_BACKUP_NAME}.tar.gz ${SOLR_BACKUP_NAME}.tar.gz --container solr --context $SOURCE_DATAVERSE_CONTEXT --retries=-1 > /dev/null
    kubectl cp ${SOLR_BACKUP_NAME}.tar.gz ${DESTINATION_DATAVERSE_NAME}-dataverse-solr-0:/tmp/ --container solr --context $DESTINATION_DATAVERSE_CONTEXT --retries=-1 > /dev/null
    kubectl exec ${DESTINATION_DATAVERSE_NAME}-dataverse-solr-0 --container solr --context $DESTINATION_DATAVERSE_CONTEXT -- rm -r /var/solr/data/collection1/data/snapshot.*
    kubectl exec ${DESTINATION_DATAVERSE_NAME}-dataverse-solr-0 --container solr --context $DESTINATION_DATAVERSE_CONTEXT -- tar -zxf /tmp/${SOLR_BACKUP_NAME}.tar.gz -C /var/solr/data/collection1/data/
fi

kubectl exec ${DESTINATION_DATAVERSE_NAME}-dataverse-solr-0 --context $DESTINATION_DATAVERSE_CONTEXT --container solr -- curl -s "localhost:8983/solr/collection1/replication?command=restore" > /dev/null

while true; do
    SOLR_BACKUP_LOAD_RESPONSE=$(kubectl exec -t ${DESTINATION_DATAVERSE_NAME}-dataverse-solr-0 --context $DESTINATION_DATAVERSE_CONTEXT --container solr -- curl -s "localhost:8983/solr/collection1/replication?command=restorestatus")
    SOLR_BACKUP_LOAD_STATUS=$(echo $SOLR_BACKUP_LOAD_RESPONSE | jq -r '.restorestatus.status')
    if [[ "$SOLR_BACKUP_LOAD_STATUS" == "success" ]]; then
        break
    fi
    echo "Waiting for Solr backup to be loaded..."
    sleep 3
done

echo
echo "Done! Backup loading complete."
