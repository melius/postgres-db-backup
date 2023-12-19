#!/usr/bin/env bash
set -e

# This script dumps the database to a compressed file to be used for backups

# Env variables
required_env_variables=(POSTGRES_HOST POSTGRES_PORT POSTGRES_DATABASE POSTGRES_USER POSTGRES_PASSWORD BACKUP_DIRECTORY)

# Check that all required env variables are set
for env_variable in "${required_env_variables[@]}"; do
    if [ -z "${!env_variable}" ]; then
        echo "Error: ${env_variable} env var is not set"
        exit 1
    fi
done

# Remove trailing slash if any
BACKUP_DIRECTORY=${BACKUP_DIRECTORY%/}

# Check that BACKUP_DIRECTORY exists and user has write permissions to it
if [ ! -d ${BACKUP_DIRECTORY} ]; then
    echo "Error: BACKUP_DIRECTORY (${BACKUP_DIRECTORY}) does not exist"
    exit 1
fi

if [ ! -w ${BACKUP_DIRECTORY} ]; then
    echo "Error: BACKUP_DIRECTORY (${BACKUP_DIRECTORY}) is not writable"
    exit 1
fi

# Define backup name
BACKUP_NAME=db-backup-$(date +%Y-%m-%dT%H_%M_%SZ).sql.gz

# Dump the database
echo "Dumping the database..."
PGPASSWORD=$POSTGRES_PASSWORD pg_dump -U $POSTGRES_USER -h $POSTGRES_HOST -p $POSTGRES_PORT -d $POSTGRES_DATABASE | gzip > ${BACKUP_DIRECTORY}/${BACKUP_NAME}
echo "Database dumped succesfully to ${BACKUP_DIRECTORY}/${BACKUP_NAME}"
