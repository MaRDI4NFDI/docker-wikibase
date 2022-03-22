#!/bin/bash

# Creates a backup of the SQL database and an XML backup of all pages (last version only).
# Called by the cronjob (or manually, see README)

set +e # continue on error

LOG_FILE="/data/backup.log" # internal path to log file
BACKUP_DIR="/data" # internal mount path of backup directory on the host
DATE_STRING=`date +\%Y.\%m.\%d_%H.%M.%S` # date string to use in file names

NODE_EXPORTER_DIR="/data/"  # path where node_exporter metrics are stored
XML_SIZE=0
MYSQL_SIZE=0
FILES_SIZE=0

# redirect all output to log file
exec 1>>$LOG_FILE
exec 2>&1

# Backups the portal wiki database.
# https://mariadb.com/kb/en/mysqldump/
mysql_dump() {
    printf "MySQL backup\n"
    MYSQL_DUMP_FILE=portal_db_backup_${DATE_STRING}.gz
    mysqldump -u${DB_USER} -p${DB_PASS} -h${DB_HOST} --databases ${DB_NAME} | gzip > ${BACKUP_DIR}/${MYSQL_DUMP_FILE}
    STATUS=$?
    if [[ -f ${BACKUP_DIR}/${MYSQL_DUMP_FILE} ]]; then
        printf " - MySQL dump written to ${MYSQL_DUMP_FILE}\n"
        MYSQL_SIZE=$(du "${BACKUP_DIR}/${MYSQL_DUMP_FILE}" | cut -f1)
    else
        printf " - MySQL dump failed with status $STATUS\n"
    fi
    return $STATUS
}

# Backups the portal wiki pages as xml.
# https://www.mediawiki.org/wiki/Manual:DumpBackup.php
xml_dump() {
    printf "XML backup\n"
    XML_DUMP_FILE=portal_xml_backup_${DATE_STRING}.gz
    # parsoid requires script to be executed from mw root
    cd /var/www/html/
    /usr/local/bin/php /var/www/html/maintenance/dumpBackup.php --current --output=gzip:${BACKUP_DIR}/${XML_DUMP_FILE} --quiet --conf /shared/LocalSettings.php
    STATUS=$?
    if [[ -f ${BACKUP_DIR}/${XML_DUMP_FILE} ]]; then
        printf " - XML dump written to ${XML_DUMP_FILE}\n"
        XML_SIZE=$(du "${BACKUP_DIR}/${XML_DUMP_FILE}" | cut -f1)
    else
        printf " - XML dump failed with status $STATUS\n"
    fi    
    return $STATUS
}

# Backups uploaded files
files_dump() {
    printf "Files backup\n"
    IMAGES_FILE=images_${DATE_STRING}.tar.gz
    tar -czf ${BACKUP_DIR}/${IMAGES_FILE} -C /var/www/html/ images
    STATUS=$?
    if [[ -f ${BACKUP_DIR}/${IMAGES_FILE} ]]; then
        printf " - Uploaded images backup written to ${IMAGES_FILE}\n"
        FILES_SIZE=$(du "${BACKUP_DIR}/${IMAGES_FILE}" | cut -f1)
    else
        printf " - Uploaded images backup failed with status $STATUS\n"
    fi
    return $STATUS
}

# Cleanups backup files older than KEEP_DAYS.
# Logs the deleted files if any.
cleanup() {
    printf "Cleanup\n"
    DELETED=$(find "${BACKUP_DIR}" -maxdepth 1 -name "*.gz"  -type f -mtime +"${KEEP_DAYS}" -print -delete)
    if [[ -z $DELETED ]]; then
        printf " - No files deleted"
    fi
    printf "\n"
}

# export metrics for prometheus/node_exporter textfile collector
# metrics: 
#   - date of last backup
#   - backup file sizes
#   - duration
metrics_dump() {
    printf "Writing backup metrics to file ${NODE_EXPORTER_DIR}/backup_full.prom\n"

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
EOF
    
    mv "${NODE_EXPORTER_DIR}/backup_full.prom.$$" "${NODE_EXPORTER_DIR}/backup_full.prom"
}


# main script
printf "Backup started ${DATE_STRING}\n" 
START="$(date +%s)"

mysql_dump 
EXIT_CODE_MYSQL=$?

xml_dump
EXIT_CODE_XML=$?

files_dump
EXIT_CODE_FILES=$?

END="$(date +%s)"

TOTAL_BACKUP_SIZE="$(du -s ${BACKUP_DIR} | cut -f1)"

metrics_dump

cleanup
printf "\n"

# to do send mail
# export AMB_REMOTE_EXEC="ssh -C $AMB_TARGET"
# | mail -s "AutoMySQLBackup | $AMB_TARGET | `date +'%Y-%m-%d %r %Z'`" root
