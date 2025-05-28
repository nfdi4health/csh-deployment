#!/bin/bash

# === CONFIGURATION ===
# kubectl context
KUBE_CONTEXT=""
# Namespace
NAMESPACE="default"
# Keycloak instance name
KEYCLOAK_CR_NAME="keycloak-example"
# Target database name
DB_NAME="keycloak"
# Name of your  Postgres cluster
CLUSTER_NAME="keycloak-example-postgres"
# Name of your Postgres cluster secret (Derived Variables)
SECRET_NAME="$DB_NAME.$CLUSTER_NAME.credentials.postgresql.acid.zalan.do"
# local backup file path
##
BACKUP_FILE=".sql"

# === SCRIPT  ===
# === FIND POSTGRES POD FOR THE CLUSTER (first pod) ===
POSTGRES_POD=$(kubectl get pods  \
  -l "application=spilo,cluster-name=$CLUSTER_NAME" \
  -o jsonpath="{.items[0].metadata.name}")

if [ -z "$POSTGRES_POD" ]; then
  echo "❌ No Postgres pod found for cluster '$CLUSTER_NAME' in namespace '$NAMESPACE'."
  exit 1
fi

# === VALIDATE BACKUP FILE ===
if [ ! -f "$BACKUP_FILE" ]; then
  echo "❌ Backup file '$BACKUP_FILE' not found."
  exit 1
fi

# === FETCH DB CREDENTIALS FROM SECRET ===
echo "🔐 Reading DB credentials from secret '$SECRET_NAME'..."
DB_USER=$(kubectl get secret "$SECRET_NAME" --context "$KUBE_CONTEXT" -n "$NAMESPACE" \
  -o jsonpath="{.data.username}" | base64 --decode)
DB_PASSWORD=$(kubectl get secret "$SECRET_NAME" --context "$KUBE_CONTEXT" -n "$NAMESPACE" \
  -o jsonpath="{.data.password}" | base64 --decode)

if [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ]; then
  echo "❌ Failed to extract DB credentials from secret '$SECRET_NAME'."
  exit 1
fi

# === COPY BACKUP TO POD ===
echo "📦 Copying backup to pod '$POSTGRES_POD'..."
kubectl cp "$BACKUP_FILE" --context "$KUBE_CONTEXT" "$NAMESPACE/$POSTGRES_POD:/tmp/keycloak_restore.sql"
if [ $? -ne 0 ]; then
  echo "❌ Failed to copy the backup file to pod."
  exit 1
fi

echo "📉 Scaling down Keycloak instance '$KEYCLOAK_CR_NAME' to 0..."
kubectl patch keycloak "$KEYCLOAK_CR_NAME" \
  -n "$NAMESPACE" --context "$KUBE_CONTEXT" \
  --type=merge \
  -p '{"spec": {"instances": 0}}'

echo "⏳ Waiting for Keycloak pods to terminate..."
kubectl wait --for=delete pod \
  -l app.kubernetes.io/name=keycloak,app.kubernetes.io/instance=$KEYCLOAK_CR_NAME \
  -n "$NAMESPACE" --context "$KUBE_CONTEXT" --timeout=90s

# === DROP & RECREATE DATABASE ===
echo "🔥 Dropping database '$DB_NAME'..."
kubectl exec -n "$NAMESPACE" --context "$KUBE_CONTEXT" "$POSTGRES_POD" -- bash -c \
  "PGPASSWORD='$DB_PASSWORD' psql -U '$DB_USER' -d postgres -c 'DROP DATABASE IF EXISTS $DB_NAME;'"

if [ $? -ne 0 ]; then
  echo "❌ Failed to drop the database."
  exit 1
fi

echo "🛠️ Creating database '$DB_NAME'..."
kubectl exec -n "$NAMESPACE" --context "$KUBE_CONTEXT" "$POSTGRES_POD" -- bash -c \
  "PGPASSWORD='$DB_PASSWORD' psql -U '$DB_USER' -d postgres -c 'CREATE DATABASE $DB_NAME;'"

if [ $? -ne 0 ]; then
  echo "❌ Failed to create the database."
  exit 1
fi

# === EXECUTE RESTORE ===
echo "🔄 Restoring database in pod '$POSTGRES_POD'..."
kubectl exec -n "$NAMESPACE" --context "$KUBE_CONTEXT" "$POSTGRES_POD" -- bash -c \
  "PGPASSWORD='$DB_PASSWORD' psql -U '$DB_USER' -d '$DB_NAME' -f /tmp/keycloak_restore.sql"

if [ $? -eq 0 ]; then
  echo "✅ Restore completed successfully."
else
  echo "❌ Restore failed."
  exit 1
fi

echo "📈 Scaling Keycloak instance '$KEYCLOAK_CR_NAME' back up..."
kubectl patch keycloak "$KEYCLOAK_CR_NAME" \
  -n "$NAMESPACE" --context "$KUBE_CONTEXT" \
  --type=merge \
  -p '{"spec": {"instances": 2}}'