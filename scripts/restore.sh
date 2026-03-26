#!/bin/bash
if [ -f .env ]; then
  export $(echo $(cat .env | sed 's/#.*//g' | xargs) | envsubst)
fi

# Get the latest backup filename from S3
LATEST_BACKUP=$(aws s3 ls "s3://${R2_BUCKET}/" --endpoint-url "$R2_ENDPOINT" | sort | tail -n 1 | awk '{print $4}')

if [ -z "$LATEST_BACKUP" ]; then
  echo "No backups found in bucket!"
  exit 1
fi

echo "Downloading latest backup: $LATEST_BACKUP..."
aws s3 cp "s3://${R2_BUCKET}/$LATEST_BACKUP" "$LATEST_BACKUP" --endpoint-url "$R2_ENDPOINT"

echo "Restoring to MongoDB..."
mongorestore --uri="$MONGO_URI" --archive="$LATEST_BACKUP" --gzip --drop

echo "Restore complete! Cleaning up..."
rm "$LATEST_BACKUP"