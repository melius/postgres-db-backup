#!/usr/bin/env bash
set -e

# This script removes backups located in the local directories older than X days

# Env variables
required_env_variables=(BACKUP_DIRECTORY RETENTION_DAYS_LOCAL)

# Check that all required env variables are set
for env_variable in "${required_env_variables[@]}"; do
    if [ -z "${!env_variable}" ]; then
        echo "Error: ${env_variable} env var is not set"
        exit 1
    fi
done

# Remove trailing slashes if any
BACKUP_DIRECTORY=${BACKUP_DIRECTORY%/}

# Check that the directories exist and are writable
if [ ! -d ${BACKUP_DIRECTORY} ]; then
    echo "Error: ${BACKUP_DIRECTORY} does not exist"
    exit 1
fi

if [ ! -w ${BACKUP_DIRECTORY} ]; then
    echo "Error: ${BACKUP_DIRECTORY} is not writable"
    exit 1
fi

echo "Removing backups older than ${RETENTION_DAYS_LOCAL} days from ${BACKUP_DIRECTORY}..."
find ${BACKUP_DIRECTORY} -type f -name "*.sql.gz" -mtime +${RETENTION_DAYS_LOCAL} -exec rm -f {} \;
echo "Done"
