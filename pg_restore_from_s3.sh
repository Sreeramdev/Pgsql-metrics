#!/bin/bash

# Configuration
S3_BUCKET="postres-s3-backups"  # Replace with your bucket name

if [ -z "$1" ]; then
  echo "Usage: $0 <backup-file-name>"
  echo "Example: $0 sampledb_backup_20240101_120000.sql.gz"
  exit 1
fi

BACKUP_FILE=$1

# Download from S3
aws s3 cp s3://${S3_BUCKET}/postgres-backups/${BACKUP_FILE} .

# Uncompress
gunzip ${BACKUP_FILE}

# Get the uncompressed filename (removes .gz extension)
SQL_FILE=${BACKUP_FILE%.gz}

# Restore to database
docker exec -i postgres psql -U admin -d sampledb < ${SQL_FILE}

# Clean up
rm ${SQL_FILE}

echo "Restored database from ${BACKUP_FILE}"
echo "Verifying data..."

# Show sample data after restore (modify as needed)
docker exec -t postgres psql -U admin -d sampledb -c "SELECT * FROM your_table_name LIMIT 5;"
