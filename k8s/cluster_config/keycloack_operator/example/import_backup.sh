#!/bin/bash

# === CONFIGURATION ===
KUBE_CONTEXT=""
NAMESPACE="default"
KEYCLOAK_CR_NAME="keycloak-example"

CLUSTER_NAME="keycloak-example-postgres"
BACKUP_FILE=""


# === MAIN SCRIPT ===

# Validate backup file
if [[ ! -f "$BACKUP_FILE" ]]; then
  echo "❌ Backup file '$BACKUP_FILE' not found."
  exit 1
fi

# === Import shared PostgreSQL functions ===
source ../../postgres_operator/pg_backup_utils.sh

find_postgres_pod
extract_db_credentials
prepare_backup_on_pod

echo "📉 Scaling down Keycloak instance '$KEYCLOAK_CR_NAME'..."
kubectl patch keycloak "$KEYCLOAK_CR_NAME" -n "$NAMESPACE" --context "$KUBE_CONTEXT" --type=merge -p '{"spec": {"instances": 0}}'

kubectl wait --for=delete pod \
  -l app.kubernetes.io/name=keycloak,app.kubernetes.io/instance=$KEYCLOAK_CR_NAME \
  -n "$NAMESPACE" --context "$KUBE_CONTEXT" --timeout=90s


restore_pg_dumpall
update_pg_user_passwords
cleanup_restore_files

echo "📈 Scaling Keycloak instance '$KEYCLOAK_CR_NAME' back up..."
kubectl patch keycloak "$KEYCLOAK_CR_NAME" -n "$NAMESPACE" --context "$KUBE_CONTEXT" --type=merge -p '{"spec": {"instances": 2}}'
