#!/bin/bash

set -euo pipefail

SKIP_POSTGRES=false
SKIP_SOLR=false
FORCE_SOLR_BACKUP=false

usage () {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Restore the latest PostgreSQL and Solr backups to the configured destination.

Options:
  --skip-postgres       Skip the PostgreSQL restore and Dataverse restart
  --skip-solr           Skip the Solr backup and restore
  --force-solr-backup   Create a new source Solr backup even if a recent one exists
  -h, --help            Show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --skip-postgres)
            SKIP_POSTGRES=true
            ;;
        --skip-solr)
            SKIP_SOLR=true
            ;;
        --force-solr-backup)
            FORCE_SOLR_BACKUP=true
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
    shift
done

LOGICAL_BACKUP_S3_BUCKET=
SCOPE=
LOGICAL_BACKUP_S3_BUCKET_SCOPE_SUFFIX=
S3_CONFIG_FILE=
SOURCE_DATAVERSE_NAME=
SOURCE_DATAVERSE_CONTEXT=
SOURCE_DATAVERSE_NAMESPACE=
DESTINATION_DATAVERSE_NAME=
DESTINATION_DATAVERSE_CONTEXT=
DESTINATION_DATAVERSE_NAMESPACE=

S3_CONFIG_FILE="${S3_CONFIG_FILE:-'~/.s3cfg'}"

POSTGRES_POD_NAME=${DESTINATION_DATAVERSE_NAME}-dataverse-postgres-0
DATAVERSE_POD_NAME=${DESTINATION_DATAVERSE_NAME}-dataverse-0
SOURCE_SOLR_POD_NAME=${SOURCE_DATAVERSE_NAME}-dataverse-solr-0
DESTINATION_SOLR_POD_NAME=${DESTINATION_DATAVERSE_NAME}-dataverse-solr-0
SOLR_DATA_DIR=/var/solr/data/collection1/data

restore_postgres () {
    local last_backup_file
    local backup_basename
    local uncompressed_backup_basename

    last_backup_file=$(s3cmd ls "s3://${LOGICAL_BACKUP_S3_BUCKET}/spilo/${SCOPE}${LOGICAL_BACKUP_S3_BUCKET_SCOPE_SUFFIX}/logical_backups/" -c "$S3_CONFIG_FILE" | sort | tail -n 1 | awk '{print $4}')
    if [[ -z "$last_backup_file" ]]; then
        echo "No PostgreSQL backup found in S3." >&2
        return 1
    fi
    backup_basename=$(basename "$last_backup_file")
    uncompressed_backup_basename=$(basename "$last_backup_file" .gz)

    echo "Downloading backup from S3..."
    s3cmd get "$last_backup_file" . -c "$S3_CONFIG_FILE" --skip-existing

    echo "Copying backup to postgres pod..."
    kubectl cp "$backup_basename" "$POSTGRES_POD_NAME:/tmp/" --context "$DESTINATION_DATAVERSE_CONTEXT" -n "$DESTINATION_DATAVERSE_NAMESPACE"

    echo "Unzipping backup..."
    kubectl exec "$POSTGRES_POD_NAME" --context "$DESTINATION_DATAVERSE_CONTEXT" -n "$DESTINATION_DATAVERSE_NAMESPACE" -- gunzip "/tmp/$backup_basename"

    echo "Emptying database..."
    kubectl exec "$POSTGRES_POD_NAME" --context "$DESTINATION_DATAVERSE_CONTEXT" -n "$DESTINATION_DATAVERSE_NAMESPACE" -- psql -P pager=off -U dataverse -c "-- Recreate the schema
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

-- Restore default permissions
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;"
    # source: https://stackoverflow.com/a/61221726

    echo "Loading backup into database..."
    kubectl exec "$POSTGRES_POD_NAME" --context "$DESTINATION_DATAVERSE_CONTEXT" -n "$DESTINATION_DATAVERSE_NAMESPACE" -- psql -P pager=off -U dataverse -f "/tmp/$uncompressed_backup_basename" template1

    echo "Updating database passwords..."
    kubectl get secret --context "$DESTINATION_DATAVERSE_CONTEXT" -n "$DESTINATION_DATAVERSE_NAMESPACE" | grep "${DESTINATION_DATAVERSE_NAME}-dataverse-postgres.credentials.postgresql.acid.zalan.do" | awk '{print $1}' | while read -r secret; do
        kubectl exec "$POSTGRES_POD_NAME" --context "$DESTINATION_DATAVERSE_CONTEXT" -n "$DESTINATION_DATAVERSE_NAMESPACE" -- psql -P pager=off -U dataverse -c "ALTER USER $(echo "$secret" | awk -F. '{print $1}') WITH PASSWORD '$(kubectl get "secrets/$secret" -o=jsonpath="{.data.password}" --context "$DESTINATION_DATAVERSE_CONTEXT" -n "$DESTINATION_DATAVERSE_NAMESPACE" | base64 -d)';"
    done

    echo "Restarting dataverse pod..."
    kubectl delete pod "$DATAVERSE_POD_NAME" --context "$DESTINATION_DATAVERSE_CONTEXT" -n "$DESTINATION_DATAVERSE_NAMESPACE"
    kubectl wait --for=condition=Ready --timeout=-1s --context "$DESTINATION_DATAVERSE_CONTEXT" -n "$DESTINATION_DATAVERSE_NAMESPACE" "pod/$DATAVERSE_POD_NAME"
}

if [[ "$SKIP_POSTGRES" == true ]]; then
    echo "Skipping PostgreSQL restore."
else
    restore_postgres
fi
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
    SOLR_BACKUP_RESPONSE=$(kubectl exec "$SOURCE_SOLR_POD_NAME" --context "$SOURCE_DATAVERSE_CONTEXT" -n "$SOURCE_DATAVERSE_NAMESPACE" --container solr -- curl -sS --fail-with-body "localhost:8983/solr/collection1/replication?command=details")
    SOLR_BACKUP_STATUS=$(printf '%s\n' "$SOLR_BACKUP_RESPONSE" | jq -er '.details.backup.status // "null"')
    if [[ "$SOLR_BACKUP_STATUS" == "success" ]]; then
        SOLR_BACKUP_TIMESTAMP=$(printf '%s\n' "$SOLR_BACKUP_RESPONSE" | jq -er '.details.backup.snapshotCompletedAt')

        SOLR_BACKUP_TIMESTAMP_DATE=$(printf '%s\n' "$SOLR_BACKUP_TIMESTAMP" | cut -d'T' -f1)
        SOLR_BACKUP_TIMESTAMP_HOUR=$(printf '%s\n' "$SOLR_BACKUP_TIMESTAMP" | cut -d'T' -f2 | cut -d':' -f1)

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
    else
        echo "No recent successful backup exists (status: $SOLR_BACKUP_STATUS)."
        return 0
    fi
}

create_solr_backup () {
    local backup_response

    echo "Creating backup of source Solr..."
    backup_response=$(kubectl exec "$SOURCE_SOLR_POD_NAME" --context "$SOURCE_DATAVERSE_CONTEXT" -n "$SOURCE_DATAVERSE_NAMESPACE" --container solr -- curl -sS --fail-with-body "localhost:8983/solr/collection1/replication?command=backup&numberToKeep=1")
    printf '%s\n' "$backup_response" | jq .

    while true; do
        SOLR_BACKUP_RESPONSE=$(kubectl exec "$SOURCE_SOLR_POD_NAME" --context "$SOURCE_DATAVERSE_CONTEXT" -n "$SOURCE_DATAVERSE_NAMESPACE" --container solr -- curl -sS --fail-with-body "localhost:8983/solr/collection1/replication?command=details")
        SOLR_BACKUP_STATUS=$(printf '%s\n' "$SOLR_BACKUP_RESPONSE" | jq -er '.details.backup.status // "null"')
        if [[ "$SOLR_BACKUP_STATUS" == "success" ]]; then
            break
        elif [[ "$SOLR_BACKUP_STATUS" == "failed" ]]; then
            echo "Source Solr backup failed:" >&2
            printf '%s\n' "$SOLR_BACKUP_RESPONSE" | jq . >&2
            return 1
        fi
        echo "Waiting for Solr backup to be completed..."
        sleep 1
    done
}

copy_solr_backup () {
    local local_archive
    local remote_archive="/tmp/${SOLR_BACKUP_NAME}.tar.gz"

    if kubectl exec "$DESTINATION_SOLR_POD_NAME" --container solr --context "$DESTINATION_DATAVERSE_CONTEXT" -n "$DESTINATION_DATAVERSE_NAMESPACE" -- test -d "$SOLR_DATA_DIR/$SOLR_BACKUP_NAME"; then
        echo "Backup $SOLR_BACKUP_NAME was already copied to destination Solr."
        return
    fi

    echo "Copying completed backup $SOLR_BACKUP_NAME to destination Solr... (this may take some time)"
    local_archive=$(mktemp "/tmp/${SOLR_BACKUP_NAME}.XXXXXX.tar.gz")
    kubectl exec "$SOURCE_SOLR_POD_NAME" --container solr --context "$SOURCE_DATAVERSE_CONTEXT" -n "$SOURCE_DATAVERSE_NAMESPACE" -- tar -zcf "$remote_archive" -C "$SOLR_DATA_DIR" "$SOLR_BACKUP_NAME" > /dev/null
    kubectl cp "$SOURCE_SOLR_POD_NAME:$remote_archive" "$local_archive" --container solr --context "$SOURCE_DATAVERSE_CONTEXT" -n "$SOURCE_DATAVERSE_NAMESPACE" --retries=-1 > /dev/null
    kubectl cp "$local_archive" "$DESTINATION_SOLR_POD_NAME:$remote_archive" --container solr --context "$DESTINATION_DATAVERSE_CONTEXT" -n "$DESTINATION_DATAVERSE_NAMESPACE" --retries=-1 > /dev/null
    remove_other_solr_snapshots
    if ! check_solr_snapshot_copy_space; then
        kubectl exec "$SOURCE_SOLR_POD_NAME" --container solr --context "$SOURCE_DATAVERSE_CONTEXT" -n "$SOURCE_DATAVERSE_NAMESPACE" -- rm -f "$remote_archive"
        kubectl exec "$DESTINATION_SOLR_POD_NAME" --container solr --context "$DESTINATION_DATAVERSE_CONTEXT" -n "$DESTINATION_DATAVERSE_NAMESPACE" -- rm -f "$remote_archive"
        rm -f "$local_archive"
        return 1
    fi
    kubectl exec "$DESTINATION_SOLR_POD_NAME" --container solr --context "$DESTINATION_DATAVERSE_CONTEXT" -n "$DESTINATION_DATAVERSE_NAMESPACE" -- tar -zxf "$remote_archive" -C "$SOLR_DATA_DIR"
    kubectl exec "$SOURCE_SOLR_POD_NAME" --container solr --context "$SOURCE_DATAVERSE_CONTEXT" -n "$SOURCE_DATAVERSE_NAMESPACE" -- rm -f "$remote_archive"
    kubectl exec "$DESTINATION_SOLR_POD_NAME" --container solr --context "$DESTINATION_DATAVERSE_CONTEXT" -n "$DESTINATION_DATAVERSE_NAMESPACE" -- rm -f "$remote_archive"
    rm -f "$local_archive"
}

check_solr_snapshot_copy_space () {
    local snapshot_size_kb
    local available_kb

    if kubectl exec "$DESTINATION_SOLR_POD_NAME" --container solr --context "$DESTINATION_DATAVERSE_CONTEXT" -n "$DESTINATION_DATAVERSE_NAMESPACE" -- test -d "$SOLR_DATA_DIR/$SOLR_BACKUP_NAME"; then
        return
    fi

    snapshot_size_kb=$(kubectl exec "$SOURCE_SOLR_POD_NAME" --container solr --context "$SOURCE_DATAVERSE_CONTEXT" -n "$SOURCE_DATAVERSE_NAMESPACE" -- du -sk "$SOLR_DATA_DIR/$SOLR_BACKUP_NAME" | awk '{print $1}')
    available_kb=$(kubectl exec "$DESTINATION_SOLR_POD_NAME" --container solr --context "$DESTINATION_DATAVERSE_CONTEXT" -n "$DESTINATION_DATAVERSE_NAMESPACE" -- df -Pk "$SOLR_DATA_DIR" | awk 'NR == 2 {print $4}')

    echo "Solr snapshot copy space: snapshot $((snapshot_size_kb / 1024)) MiB, available $((available_kb / 1024)) MiB."
    if (( available_kb < snapshot_size_kb )); then
        echo "Not enough free space to copy the Solr snapshot to the destination PVC." >&2
        echo "Expand the Solr PVC or remove abandoned, inactive restore directories, then retry." >&2
        return 1
    fi
}

remove_other_solr_snapshots () {
    echo "Removing superseded snapshots from destination Solr..."
    kubectl exec "$DESTINATION_SOLR_POD_NAME" --container solr --context "$DESTINATION_DATAVERSE_CONTEXT" -n "$DESTINATION_DATAVERSE_NAMESPACE" -- sh -c '
        for snapshot_path in "$1"/snapshot.*; do
            [ -d "$snapshot_path" ] || continue
            [ "${snapshot_path##*/}" = "$2" ] || rm -rf -- "$snapshot_path"
        done
    ' sh "$SOLR_DATA_DIR" "$SOLR_BACKUP_NAME"
}

check_solr_restore_space () {
    local snapshot_size_kb
    local available_kb
    local reserve_kb
    local required_kb

    snapshot_size_kb=$(kubectl exec "$DESTINATION_SOLR_POD_NAME" --container solr --context "$DESTINATION_DATAVERSE_CONTEXT" -n "$DESTINATION_DATAVERSE_NAMESPACE" -- du -sk "$SOLR_DATA_DIR/$SOLR_BACKUP_NAME" | awk '{print $1}')
    available_kb=$(kubectl exec "$DESTINATION_SOLR_POD_NAME" --container solr --context "$DESTINATION_DATAVERSE_CONTEXT" -n "$DESTINATION_DATAVERSE_NAMESPACE" -- df -Pk "$SOLR_DATA_DIR" | awk 'NR == 2 {print $4}')
    reserve_kb=$((snapshot_size_kb / 10))
    if (( reserve_kb < 262144 )); then
        reserve_kb=262144
    fi
    required_kb=$((snapshot_size_kb + reserve_kb))

    echo "Solr restore space: snapshot $((snapshot_size_kb / 1024)) MiB, available $((available_kb / 1024)) MiB, required $((required_kb / 1024)) MiB."
    if (( available_kb < required_kb )); then
        echo "Not enough free space to restore the Solr snapshot." >&2
        echo "The restore needs room for another copy of the snapshot plus a safety reserve." >&2
        echo "Current destination Solr data usage:" >&2
        kubectl exec "$DESTINATION_SOLR_POD_NAME" --container solr --context "$DESTINATION_DATAVERSE_CONTEXT" -n "$DESTINATION_DATAVERSE_NAMESPACE" -- sh -c 'du -sh "$1"/* 2>/dev/null | sort -h' sh "$SOLR_DATA_DIR" >&2
        echo "Expand the Solr PVC or remove abandoned, inactive restore directories, then retry." >&2
        return 1
    fi
}

print_solr_restore_diagnostics () {
    echo "Destination Solr disk usage:" >&2
    kubectl exec "$DESTINATION_SOLR_POD_NAME" --container solr --context "$DESTINATION_DATAVERSE_CONTEXT" -n "$DESTINATION_DATAVERSE_NAMESPACE" -- df -h "$SOLR_DATA_DIR" >&2 || true
    echo "Destination Solr index and restore directories:" >&2
    kubectl exec "$DESTINATION_SOLR_POD_NAME" --container solr --context "$DESTINATION_DATAVERSE_CONTEXT" -n "$DESTINATION_DATAVERSE_NAMESPACE" -- sh -c 'du -sh "$1"/snapshot.* "$1"/restore.* 2>/dev/null | sort -h' sh "$SOLR_DATA_DIR" >&2 || true
    echo "Active Solr index:" >&2
    kubectl exec "$DESTINATION_SOLR_POD_NAME" --container solr --context "$DESTINATION_DATAVERSE_CONTEXT" -n "$DESTINATION_DATAVERSE_NAMESPACE" -- curl -sS "localhost:8983/solr/admin/cores?action=STATUS&core=collection1&indexInfo=true" | jq '.status.collection1.index | {directory, size, numDocs}' >&2 || true
}

restore_solr () {
    local restore_response

    if [[ "$FORCE_SOLR_BACKUP" == true ]] || need_to_create_solr_backup; then
        create_solr_backup
    fi

    SOLR_BACKUP_NAME=$(printf '%s\n' "$SOLR_BACKUP_RESPONSE" | jq -er '.details.backup.directoryName')
    if [[ ! "$SOLR_BACKUP_NAME" =~ ^snapshot\.[0-9]+$ ]]; then
        echo "Unexpected Solr backup directory name: $SOLR_BACKUP_NAME" >&2
        return 1
    fi

    copy_solr_backup
    remove_other_solr_snapshots
    check_solr_restore_space

    echo "Starting restore of $SOLR_BACKUP_NAME..."
    restore_response=$(kubectl exec "$DESTINATION_SOLR_POD_NAME" --context "$DESTINATION_DATAVERSE_CONTEXT" -n "$DESTINATION_DATAVERSE_NAMESPACE" --container solr -- curl -sS --fail-with-body "localhost:8983/solr/collection1/replication?command=restore")
    printf '%s\n' "$restore_response" | jq .

    while true; do
        SOLR_BACKUP_LOAD_RESPONSE=$(kubectl exec "$DESTINATION_SOLR_POD_NAME" --context "$DESTINATION_DATAVERSE_CONTEXT" -n "$DESTINATION_DATAVERSE_NAMESPACE" --container solr -- curl -sS --fail-with-body "localhost:8983/solr/collection1/replication?command=restorestatus")
        SOLR_BACKUP_LOAD_STATUS=$(printf '%s\n' "$SOLR_BACKUP_LOAD_RESPONSE" | jq -er '.restorestatus.status // "unknown"')
        if [[ "$SOLR_BACKUP_LOAD_STATUS" == "success" ]]; then
            echo "Done! Solr backup loading complete."
            return 0
        elif [[ "$SOLR_BACKUP_LOAD_STATUS" == "failed" ]]; then
            echo "Error while loading Solr backup:" >&2
            printf '%s\n' "$SOLR_BACKUP_LOAD_RESPONSE" | jq . >&2
            print_solr_restore_diagnostics
            return 1
        fi
        echo "Waiting for Solr backup to be loaded (status: $SOLR_BACKUP_LOAD_STATUS)..."
        sleep 3
    done
}

if [[ "$SKIP_SOLR" == true ]]; then
    echo "Skipping Solr restore."
else
    restore_solr
fi
