#!/bin/bash

# Creates a backup of the SQL database and an XML backup of all pages (last version only).
# Called by the cronjob (or manually, see README)

set +e # continue on error

DATE_STRING=$(date +%Y.%m.%d_%H.%M.%S)  # date string to use in file names

# redirect all output to stdout && log file
# Note: $BACKUP_DIR is set in the Dockerfile.
exec &> >(tee -a "$BACKUP_DIR/backup.log")

NODE_EXPORTER_DIR="$BACKUP_DIR"  # path where node_exporter metrics are stored
XML_SIZE=0
MYSQL_SIZE=0
FILES_SIZE=0

# Backups the portal wiki database.
# https://mariadb.com/kb/en/mysqldump/
mysql_dump() {
    printf "\nMySQL backup\n"
    MYSQL_DUMP_FILE=portal_db_backup_${DATE_STRING}.gz
    mysqldump -u"${DB_USER}" -p"${DB_PASS}" -h"${DB_HOST}" --databases "${DB_NAME}" | gzip > "${BACKUP_DIR}/${MYSQL_DUMP_FILE}"
    PSTAT=(${PIPESTATUS[@]})
    if [[ ${PSTAT[0]} -eq 0 ]] && [[ ${PSTAT[1]} -eq 0 ]]; then
        STATUS=0
        if [[ -f "${BACKUP_DIR}/${MYSQL_DUMP_FILE}" ]]; then
            printf ' SUCCESS: MySQL dump written to %s\n' "$MYSQL_DUMP_FILE"
            MYSQL_SIZE=$(du "${BACKUP_DIR}/${MYSQL_DUMP_FILE}" | cut -f1)
        else
            printf ' ERROR: MySQL dump terminated successfully, but backup file %s was not created!\n' "${BACKUP_DIR}/${MYSQL_DUMP_FILE}"
            STATUS=255
        fi
    else
        STATUS=${PSTAT[0]}
        printf ' ERROR: MYSQL backup failed with status mysqldump: %s, gunzip: %s\n' "${PSTAT[0]}" "${PSTAT[1]}"
    fi
    return "$STATUS"
}

# Backups the portal wiki pages as xml.
# https://www.mediawiki.org/wiki/Manual:DumpBackup.php
xml_dump() {
    printf "\nXML backup\n"
    XML_DUMP_FILE=portal_xml_backup_${DATE_STRING}.gz
    # parsoid requires script to be executed from mw root
    cd /var/www/html/ || return 255
    if /usr/local/bin/php /var/www/html/maintenance/dumpBackup.php --current --output=gzip:"${BACKUP_DIR}/${XML_DUMP_FILE}" --quiet --conf /shared/LocalSettings.php
    then
        STATUS=$?
        if [[ -f ${BACKUP_DIR}/${XML_DUMP_FILE} ]]; then
            printf ' SUCCESS: XML dump written to %s\n' "$XML_DUMP_FILE"
            XML_SIZE=$(du "${BACKUP_DIR}/${XML_DUMP_FILE}" | cut -f1)
        else
            printf ' ERROR: XML dump terminated successfully, but backup file %s was not created!\n' "${BACKUP_DIR}/${XML_DUMP_FILE}"
            STATUS=255
        fi
    else
        STATUS=$?
        printf ' ERROR: XML dump failed with status %s\n' "$STATUS"
    fi    
    return $STATUS
}

# Backups uploaded files
files_dump() {
    printf "\nUploaded files backup\n"
    IMAGES_FILE=images_${DATE_STRING}.tar.gz
    if \
        tar -czf "${BACKUP_DIR}/${IMAGES_FILE}" -C /var/www/html/ images
    then
        STATUS=$?
        if [[ -f ${BACKUP_DIR}/${IMAGES_FILE} ]]; then
            printf ' SUCCESS: Uploaded images backup written to %s\n' "$IMAGES_FILE"
            FILES_SIZE=$(du "${BACKUP_DIR}/${IMAGES_FILE}" | cut -f1)
        else
            printf ' ERROR: Files backup terminated successfully, but backup file %s was not created!\n' "${BACKUP_DIR}/${IMAGES_FILE}"
            STATUS=255
        fi
    else
        STATUS=$?
        printf ' ERROR: Files backup failed with status %s\n' "$STATUS"
    fi
    return $STATUS
}

# Cleanups backup files older than KEEP_DAYS.
# Logs the deleted files if any.
cleanup() {
    printf "\nCleanup\n"
    DELETED=$(find "${BACKUP_DIR}" -maxdepth 1 -name "*.gz"  -type f -daystart -mtime +"${KEEP_DAYS}" -print -delete)
    # convert to array
    set -f # disable glob (wildcard) expansion
    IFS=$'\n' # split on newline chars
    DELETED=(${DELETED})
    NUM_DELETED=${#DELETED[@]}
    if [[ -z $DELETED ]]; then
        printf " - No files deleted\n"
    else
        printf ' - Deleted %s files older than %s days\n' "$NUM_DELETED" "$KEEP_DAYS"
        for d in "${DELETED[@]}"; do
            printf '    %s\n' "$d"
        done
    fi
}

# export metrics for prometheus/node_exporter textfile collector
# metrics: 
#   - date of last backup
#   - backup file sizes
#   - duration
metrics_dump() {
    printf 'Writing backup metrics to file %s/backup_full.prom\n' "$NODE_EXPORTER_DIR"

    cat << EOF > "${NODE_EXPORTER_DIR}/backup_full.prom.$$"
# HELP backup_last_time_seconds system time of last backup in seconds
# TYPE backup_last_time_seconds counter
backup_last_time_seconds $END
# HELP backup_last_duration_seconds duration of last backup in seconds
# TYPE backup_last_duration_seconds gauge
backup_last_duration_seconds $((END - START))
# HELP backup_last_size_bytes file sizes in bytes of last backup
# TYPE backup_last_size_bytes gauge
backup_last_size_bytes{type="mysql"} $MYSQL_SIZE
backup_last_size_bytes{type="xml"} $XML_SIZE
backup_last_size_bytes{type="files"} $FILES_SIZE
# HELP backup_total_size_bytes total size of backup folder in bytes
# TYPE backup_total_size_bytes gauge
backup_total_size_bytes $TOTAL_BACKUP_SIZE
# HELP backup_last_status_code  status code of last backup call
# TYPE backup_last_status_code gauge
backup_last_status_code{type="mysql"} $EXIT_CODE_MYSQL
backup_last_status_code{type="xml"} $EXIT_CODE_XML
backup_last_status_code{type="files"} $EXIT_CODE_FILES
# HELP backup_cleanup_deleted_num number of deleted files by cleanup
# TYPE backup_cleanup_deleted_num gauge
backup_cleanup_deleted_num $NUM_DELETED
EOF
    
    mv "${NODE_EXPORTER_DIR}/backup_full.prom.$$" "${NODE_EXPORTER_DIR}/backup_full.prom"
}


# main script
printf '==================================\n'
printf 'Backup started %s\n' "$DATE_STRING"
printf '==================================\n'
START="$(date +%s)"

mysql_dump 
EXIT_CODE_MYSQL=$?

xml_dump
EXIT_CODE_XML=$?

files_dump
EXIT_CODE_FILES=$?

END="$(date +%s)"

cleanup

TOTAL_BACKUP_SIZE="$(du -s ${BACKUP_DIR} | cut -f1)"

metrics_dump

printf "\n"
