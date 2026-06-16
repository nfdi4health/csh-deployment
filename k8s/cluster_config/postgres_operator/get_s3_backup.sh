#!/bin/bash

# === Required Variables ===
# S3 API address
S3_ENDPOINT="s3.de-west-1.psmanaged.com"
# Name of the bucket where zalando backups are stored!
LOGICAL_BACKUP_S3_BUCKET=""
AWS_ACCESS_KEY_ID=""
AWS_SECRET_ACCESS_KEY=""

# Name of the postgres instance
SCOPE=""
# Hash to identify the instance, you need to look this up in S3!
LOGICAL_BACKUP_S3_BUCKET_SCOPE_SUFFIX=""

# === Construct S3 URL and backup path ===
BACKUP_PREFIX="s3://${LOGICAL_BACKUP_S3_BUCKET}/spilo/${SCOPE}/${LOGICAL_BACKUP_S3_BUCKET_SCOPE_SUFFIX}/logical_backups/"

# === Find latest backup file ===
echo "🔍 Listing files at: $BACKUP_PREFIX"
LAST_BACKUP_FILE=$(s3cmd ls "$BACKUP_PREFIX" \
  --access_key="$AWS_ACCESS_KEY_ID" \
  --secret_key="$AWS_SECRET_ACCESS_KEY" \
  --host="$S3_ENDPOINT" \
  --host-bucket="%(bucket)s.$S3_ENDPOINT" \
  | sort | tail -n 1 | awk '{print $4}')

if [[ -z "$LAST_BACKUP_FILE" ]]; then
  echo "❌ No backup file found in: $BACKUP_PREFIX"
  exit 1
fi

# === Extract original filename from S3 path ===
ORIGINAL_FILENAME=$(basename "$LAST_BACKUP_FILE")

# === Download the backup file from S3 ===
echo "⬇️ Downloading backup..."
s3cmd get "$LAST_BACKUP_FILE" "$ORIGINAL_FILENAME" \
  --access_key="$AWS_ACCESS_KEY_ID" \
  --secret_key="$AWS_SECRET_ACCESS_KEY" \
  --host="$S3_ENDPOINT" \
  --host-bucket="%(bucket)s.$S3_ENDPOINT" \
  --skip-existing

# === Generate formatted timestamp from original filename ===
UNIX_TIMESTAMP="${ORIGINAL_FILENAME%.sql.gz}"
TIMESTAMP=$(date -d "@$UNIX_TIMESTAMP" +"%Y%m%d_%H%M%S")

# === Construct new file name ===
NEW_FILENAME="${SCOPE}_${TIMESTAMP}.sql.gz"

# === Rename the file ===
mv "$ORIGINAL_FILENAME" "$NEW_FILENAME"

# === Final confirmation ===
if [[ $? -eq 0 ]]; then
  echo "✅ Backup downloaded and renamed: $NEW_FILENAME"
else
  echo "❌ Failed to rename or download backup."
  exit 1
fi
