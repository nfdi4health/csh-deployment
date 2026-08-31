

# === FUNCTION: Extract DB Credentials ===
extract_db_credentials() {
  SECRET_NAME="postgres.$CLUSTER_NAME.credentials.postgresql.acid.zalan.do"
  echo "🔐 Reading DB credentials from secret '$SECRET_NAME'..."
  DB_USER=$(kubectl get secret "$SECRET_NAME" --context "$KUBE_CONTEXT" -n "$NAMESPACE" \
    -o jsonpath="{.data.username}" | base64 --decode)
  DB_PASSWORD=$(kubectl get secret "$SECRET_NAME" --context "$KUBE_CONTEXT" -n "$NAMESPACE" \
    -o jsonpath="{.data.password}" | base64 --decode)

  if [[ -z "$DB_USER" || -z "$DB_PASSWORD" ]]; then
    echo "❌ Failed to extract DB credentials."
    exit 1
  fi
}

# === FUNCTION: Find Postgres Pod ===
find_postgres_pod() {
  POSTGRES_POD=$(kubectl get pods --context "$KUBE_CONTEXT" -n "$NAMESPACE" \
    -l "application=spilo,cluster-name=$CLUSTER_NAME" \
    -o jsonpath="{.items[0].metadata.name}")

  if [[ -z "$POSTGRES_POD" ]]; then
    echo "❌ No Postgres pod found for cluster '$CLUSTER_NAME'."
    exit 1
  fi
}

# === FUNCTION: Copy and Prepare Backup ===
prepare_backup_on_pod() {
  echo "📦 Copying backup to pod '$POSTGRES_POD'..."
  kubectl cp "$BACKUP_FILE" --context "$KUBE_CONTEXT" "$NAMESPACE/$POSTGRES_POD:/tmp/db_restore.sql.gz" || {
    echo "❌ Failed to copy the backup file to pod."
    exit 1
  }

  echo "🗜️ Decompressing backup on the pod..."
  kubectl exec --context "$KUBE_CONTEXT" -n "$NAMESPACE" "$POSTGRES_POD" -- \
    gzip -d /tmp/db_restore.sql.gz
}

# === FUNCTION: Restore Backup ===
restore_pg_dumpall() {
    ## === Drop all user-created databases ===
  #kubectl exec --context "$KUBE_CONTEXT" -n "$NAMESPACE" "$POSTGRES_POD" -- \
  #  bash -c "PGPASSWORD='$DB_PASSWORD' psql -U '$DB_USER' -d postgres -Atc \
  #  \"SELECT 'DROP DATABASE IF EXISTS \\\"' || datname || '\\\";'
  #   FROM pg_database
  #
  #   WHERE datname NOT IN ('template0', 'template1', 'postgres');\"" > /tmp/drop_dbs.sql
  #
  #kubectl exec --context "$KUBE_CONTEXT" -n "$NAMESPACE" "$POSTGRES_POD" -- \
  #  bash -c "PGPASSWORD='$DB_PASSWORD' psql -U '$DB_USER' -d postgres -f -" < /tmp/drop_dbs.sql
  #
  ## === Optional: Drop user roles except 'postgres' ===
  #kubectl exec --context "$KUBE_CONTEXT" -n "$NAMESPACE" "$POSTGRES_POD" -- \
  #  bash -c "PGPASSWORD='$DB_PASSWORD' psql -U '$DB_USER' -d postgres -Atc \
  #  \"SELECT 'DROP ROLE IF EXISTS \\\"' || rolname || '\\\";'
  #   FROM pg_roles
  #   WHERE rolname NOT IN ('postgres', 'standby','pooler');\"" > /tmp/drop_roles.sql
  #
  #kubectl exec --context "$KUBE_CONTEXT" -n "$NAMESPACE" "$POSTGRES_POD" -- \
  #  bash -c "PGPASSWORD='$DB_PASSWORD' psql -U '$DB_USER' -d postgres -f -" < /tmp/drop_roles.sql
  #
  #echo "🧹 Dropping all user schemas from 'postgres' database..."
  #kubectl exec --context "$KUBE_CONTEXT" -n "$NAMESPACE" "$POSTGRES_POD" -- \
  #  bash -c "PGPASSWORD='$DB_PASSWORD' psql -U '$DB_USER' -d postgres -Atc \
  #  \"SELECT 'DROP SCHEMA IF EXISTS \\\"' || nspname || '\\\" CASCADE;'
  #   FROM pg_namespace
  #   WHERE nspname NOT IN ('pg_catalog', 'information_schema', 'public');\"" > /tmp/drop_schemas.sql
  #
  #kubectl exec --context "$KUBE_CONTEXT" -n "$NAMESPACE" "$POSTGRES_POD" -- \
  #  bash -c "PGPASSWORD='$DB_PASSWORD' psql -U '$DB_USER' -d postgres -f -" < /tmp/drop_schemas.sql
  #
  #rm -f /tmp/drop_dbs.sql /tmp/drop_roles.sql /tmp/drop_schemas.sql

  echo "🧱 Recreating 'public' schema..."
  kubectl exec "$POSTGRES_POD" --context "$KUBE_CONTEXT" -n "$NAMESPACE" -- \
  psql -P pager=off -U postgres -d postgres -c "
    DROP SCHEMA public CASCADE;
    CREATE SCHEMA public;
    GRANT ALL ON SCHEMA public TO postgres;
    GRANT ALL ON SCHEMA public TO public;
  "

  echo "🔄 Restoring full cluster dump using psql into 'postgres' DB..."
  kubectl exec --context "$KUBE_CONTEXT" -n "$NAMESPACE" "$POSTGRES_POD" -- bash -c \
    "PGPASSWORD='$DB_PASSWORD' psql -U postgres -d postgres -f /tmp/db_restore.sql"

  if [[ $? -eq 0 ]]; then
    echo "✅ Restore completed."
  else
    echo "❌ Restore failed."
    exit 1
  fi
}

# === FUNCTION: Update Passwords ===
update_pg_user_passwords() {
  echo "🔐 Updating PostgreSQL user passwords to match Kubernetes secrets..."
  kubectl get secret --context "$KUBE_CONTEXT" -n "$NAMESPACE" | \
  grep "$CLUSTER_NAME.credentials.postgresql.acid.zalan.do" | \
  awk '{print $1}' | while read SECRET; do
    USERNAME=$(echo "$SECRET" | awk -F. '{print $1}')
    PASSWORD=$(kubectl get secret "$SECRET" -n "$NAMESPACE" --context "$KUBE_CONTEXT" \
      -o jsonpath="{.data.password}" | base64 -d)
    echo "🔄 Updating password for user: $USERNAME"
    kubectl exec "$POSTGRES_POD" --context "$KUBE_CONTEXT" -n "$NAMESPACE" -- \
      psql -U postgres -d postgres -c "ALTER USER \"$USERNAME\" WITH PASSWORD '$PASSWORD';"
  done
}

# === FUNCTION: Cleanup Temporary Files ===
cleanup_restore_files() {
  echo "🧹 Cleaning up restore files from pod..."
  kubectl exec --context "$KUBE_CONTEXT" -n "$NAMESPACE" "$POSTGRES_POD" -- rm -f /tmp/db_restore.sql.gz /tmp/db_restore.sql
}
