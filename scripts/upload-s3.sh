#!/usr/bin/env bash
set -e

# This script uploads the backups and exports to an S3 bucket
# It is meant to be run after the backup script

# Env variables
required_env_variables=(BACKUP_DIRECTORY S3CMD_CONFIG_FILE S3_BUCKET)

# Check that all required env variables are set
for env_variable in "${required_env_variables[@]}"; do
    if [ -z "${!env_variable}" ]; then
        echo "Error: ${env_variable} env var is not set"
        exit 1
    fi
done

# Remove trailing slashes if any
BACKUP_DIRECTORY=${BACKUP_DIRECTORY%/}

# Check that the directories exist
if [ ! -d ${BACKUP_DIRECTORY} ]; then
    echo "Error: ${BACKUP_DIRECTORY} does not exist"
    exit 1
fi

# Check that the s3cmd config file exists and is readable
if [ ! -f  ${S3CMD_CONFIG_FILE} ]; then
    echo "Error: ${S3CMD_CONFIG_FILE} does not exist"
    exit 1
fi

if [ ! -r ${S3CMD_CONFIG_FILE} ]; then
    echo "Error: ${S3CMD_CONFIG_FILE} is not readable"
    exit 1
fi

# Check that the s3cmd is installed
if ! command -v s3cmd &> /dev/null; then
    echo "Error: s3cmd is not installed (https://s3tools.org/s3cmd)"
    exit 1
fi

# Get the latest backup file
BACKUP_FILE_PATH=$(ls -t ${BACKUP_DIRECTORY}/*.sql.gz | head -n 1)

# Upload the files to S3
echo "Uploading backups and exports to S3..."
s3cmd --config=${S3CMD_CONFIG_FILE} put ${BACKUP_FILE_PATH} s3://${S3_BUCKET}/db-backups/
echo "Backups and exports uploaded succesfully to S3"
