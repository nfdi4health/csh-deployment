#!/bin/bash

# === Configuration ===
KUBE_CONTEXT=""
# Namespace
NAMESPACE="default"
# Name of your  Postgres cluster
CLUSTER_NAME="keycloak-example-postgres"


TIMESTAMP=$(date +"%Y%m%d_%H%M%S")              # timestamp for versioning
TMP_FILE="${CLUSTER_NAME}_${TIMESTAMP}.sql.gz"

# === Find Postgres pod ===
POD=$(kubectl get pods --context "$KUBE_CONTEXT" -n "$NAMESPACE" \
  -l application=spilo,cluster-name="$CLUSTER_NAME" \
  -o jsonpath="{.items[0].metadata.name}")

if [[ -z "$POD" ]]; then
  echo "❌ Could not find Postgres pod for cluster '$CLUSTER_NAME'"
  exit 1
fi

# === Run pg_dumpall inside the pod and compress ===
echo "📦 Running pg_dumpall inside pod '$POD'..."
kubectl exec --context "$KUBE_CONTEXT" -n "$NAMESPACE" "$POD" -- \
  bash -c "pg_dumpall -U postgres | gzip > /tmp/backup.sql.gz"

# === Copy compressed backup from pod to local file ===
echo "⬇️ Copying backup from pod to: $TMP_FILE"
kubectl cp --context "$KUBE_CONTEXT" "$NAMESPACE/$POD:/tmp/backup.sql.gz" "$TMP_FILE"

# === Clean up temporary file on the pod ===
echo "🧹 Cleaning up pod backup file..."
kubectl exec --context "$KUBE_CONTEXT" -n "$NAMESPACE" "$POD" -- rm -f /tmp/backup.sql.gz
