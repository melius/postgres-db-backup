#!/usr/bin/env bash
set -e

# This scripts calls all the other scripts in the right order to perform a backup

echo "Starting backup..."

# Get the directory of this script
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

$CURRENT_DIR/scripts/clean-up-local.sh
$CURRENT_DIR/scripts/dump-db.sh
$CURRENT_DIR/scripts/upload-s3.sh

echo "Backup completed successfully"
