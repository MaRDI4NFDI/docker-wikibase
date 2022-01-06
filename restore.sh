#!/bin/bash
set -e # do not continue on error

LOG_FILE="/data/backup.log" # internal path to log file
BACKUP_DIR="/data" # internal mount path of backup directory on the host

# redirect all output to log file
exec 1>>$LOG_FILE
exec 2>&1

# Restores the most recent database backup
restore_db_backup() {
    # find the most recent backup file
    recent_file=$(ls -t ${BACKUP_DIR}/portal_db_backup_*.gz | head -1)
    printf "Attempting to restore database backup from $recent_file\n"
    # unzip the backup file and restore the database
    gzip -d -c $recent_file|mysql -u${DB_USER} -p${DB_PASS} -h${DB_HOST} --database ${DB_NAME} 
    if [[ $? -eq 0 ]]; then
        printf "done\n"
    else
        printf "ERROR restoring database\n"
    fi
}

printf "Restore started at `date +\%Y.\%m.\%d_%H.%M.%S`\n"
restore_db_backup
printf "\n"
