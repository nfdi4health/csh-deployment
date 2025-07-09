SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export DATAVERSE_API_KEY_B64=$(echo "\"$(printf "%s" "$DATAVERSE_API_KEY" | base64)\"")

cat $SCRIPT_DIR/publish_job.yaml | envsubst | kubectl apply -f -