#!/bin/bash
# Load environment variables if .env exists
if [ -f .env ]; then
  export $(echo $(cat .env | sed 's/#.*//g' | xargs) | envsubst)
fi

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="${DB_NAME}_${TIMESTAMP}"

echo "Starting backup for $DB_NAME..."

# 1. Create dump
mongodump --uri="$MONGO_URI" --archive="${BACKUP_NAME}.archive" --gzip

# 2. Upload to R2/B2
aws s3 cp "${BACKUP_NAME}.archive" "s3://${R2_BUCKET}/${BACKUP_NAME}.archive" --endpoint-url "$R2_ENDPOINT"

# 3. Cleanup local file
rm "${BACKUP_NAME}.archive"

echo "Backup $BACKUP_NAME uploaded successfully!"