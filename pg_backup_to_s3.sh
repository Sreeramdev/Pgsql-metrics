#!/bin/bash

# Configuration
BACKUP_FILE="sampledb_backup_$(date +"%Y%m%d_%H%M%S").sql"
S3_BUCKET="postres-s3-backups"  # Replace with your bucket name

# Create backup (plain SQL format for easy inspection)
docker exec -t postgres pg_dump -U admin -d sampledb > $BACKUP_FILE

# Compress the backup
gzip $BACKUP_FILE

# Upload to S3 (ensure AWS CLI is configured on your host)
aws s3 cp ${BACKUP_FILE}.gz s3://${S3_BUCKET}/postgres-backups/

# Clean up local file
rm ${BACKUP_FILE}.gz

echo "Backup completed and uploaded to S3: s3://${S3_BUCKET}/postgres-backups/${BACKUP_FILE}.gz"
