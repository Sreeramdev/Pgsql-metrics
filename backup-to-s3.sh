#!/bin/bash

# Config
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
BACKUP_FILE="/tmp/backup-$TIMESTAMP.sql.gz"
DB_NAME="sampledb"
DB_USER="postgres"  # Change from admin to postgres
DB_PASSWORD="admin123"
DB_HOST="localhost"  # Use the service/container name (or localhost if on the host directly)
DB_PORT="5432"
S3_BUCKET="one-last-postgres"
S3_FILE="backup-$TIMESTAMP.sql.gz"
S3_PATH="s3://$S3_BUCKET/$S3_FILE"

# Export password so pg_dump can use it
export PGPASSWORD=$DB_PASSWORD

echo "📦 Creating backup from $DB_HOST:$DB_PORT/$DB_NAME..."
pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" "$DB_NAME" | gzip > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "🚀 Uploading backup to S3..."
    aws s3 cp "$BACKUP_FILE" "$S3_PATH"
    echo "✅ Backup uploaded successfully: $S3_FILE"
    rm "$BACKUP_FILE"
else
    echo "❌ Backup failed!"
fi
