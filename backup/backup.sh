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
    echo
    echo "MySQL backup"
    MYSQL_DUMP_FILE=portal_db_backup_${DATE_STRING}.gz
    mysqldump -u"${DB_USER}" -p"${DB_PASS}" -h"${DB_HOST}" --single-transaction --quick --databases "${DB_NAME}" | gzip > "${BACKUP_DIR}/${MYSQL_DUMP_FILE}"
    PSTAT=(${PIPESTATUS[@]})
    if [[ ${PSTAT[0]} -eq 0 ]] && [[ ${PSTAT[1]} -eq 0 ]]; then
        STATUS=0
        if [[ -f "${BACKUP_DIR}/${MYSQL_DUMP_FILE}" ]]; then
            echo " SUCCESS: MySQL dump written to ${BACKUP_DIR}/${MYSQL_DUMP_FILE}"
            MYSQL_SIZE=$(du "${BACKUP_DIR}/${MYSQL_DUMP_FILE}" | cut -f1)
        else
            echo " ERROR: MySQL dump terminated successfully, but backup file ${BACKUP_DIR}/${MYSQL_DUMP_FILE} was not created!"
            STATUS=255
        fi
    else
        STATUS=${PSTAT[0]}
        echo " ERROR: MYSQL backup failed with status mysqldump: ${PSTAT[0]}, gunzip: ${PSTAT[1]}"
    fi
    return "$STATUS"
}

# Backups the portal wiki pages as xml.
# https://www.mediawiki.org/wiki/Manual:DumpBackup.php
xml_dump() {
    echo
    echo "XML backup"
    XML_DUMP_FILE=portal_xml_backup_${DATE_STRING}.gz
    # parsoid requires script to be executed from mw root
    cd /var/www/html/ || return 255
    if /usr/local/bin/php /var/www/html/maintenance/dumpBackup.php --current --output=gzip:"${BACKUP_DIR}/${XML_DUMP_FILE}" --quiet --conf /shared/LocalSettings.php
    then
        STATUS=$?
        if [[ -f ${BACKUP_DIR}/${XML_DUMP_FILE} ]]; then
            echo " SUCCESS: XML dump written to ${BACKUP_DIR}/${XML_DUMP_FILE}"
            XML_SIZE=$(du "${BACKUP_DIR}/${XML_DUMP_FILE}" | cut -f1)
        else
            echo " ERROR: XML dump terminated successfully, but backup file ${BACKUP_DIR}/${XML_DUMP_FILE} was not created!"
            STATUS=255
        fi
    else
        STATUS=$?
        echo " ERROR: XML dump failed with status $STATUS"
    fi    
    return $STATUS
}

# Backups uploaded files
files_dump() {
    echo
    echo "Uploaded files backup"
    IMAGES_FILE=images_${DATE_STRING}.tar.gz
    if \
        tar --exclude='images/cache' --exclude='images/temp' -czf "${BACKUP_DIR}/${IMAGES_FILE}" -C /var/www/html/ images
    then
        STATUS=$?
        if [[ -f ${BACKUP_DIR}/${IMAGES_FILE} ]]; then
            echo " SUCCESS: Uploaded images backup written to ${BACKUP_DIR}/${IMAGES_FILE}"
            FILES_SIZE=$(du "${BACKUP_DIR}/${IMAGES_FILE}" | cut -f1)
        else
            echo " ERROR: Files backup terminated successfully, but backup file ${BACKUP_DIR}/${IMAGES_FILE} was not created!"
            STATUS=255
        fi
    else
        STATUS=$?
        echo " ERROR: Files backup failed with status $STATUS"
    fi
    return $STATUS
}

# Backups the json files for grafana dashboards
grafana_dashboard_dump() {
    echo
    echo "Grafana dashboards backup"
    [ ! -d "${BACKUP_DIR}/dashboards" ] && mkdir -p ${BACKUP_DIR}/dashboards
    STATUS=0
    for dashboard in $(curl -sS -k -H "Authorization: Bearer ${GF_API_KEY}" ${WIKIBASE_SCHEME}://${GF_PUBLIC_HOST_AND_PORT}/api/search\?query\=\& | jq '.' | jq '.[]' | jq '.uid' | cut -d '"' -f2); do
        GF_DB_FILE=grafana_dashboard_${dashboard}_${DATE_STRING}.json
        curl -sSL -k -H "Authorization: Bearer ${GF_API_KEY}" "${WIKIBASE_SCHEME}://${GF_PUBLIC_HOST_AND_PORT}/api/dashboards/uid/${dashboard}" | jq '.dashboard' > ${BACKUP_DIR}/dashboards/${GF_DB_FILE}
        if [[ -f "${BACKUP_DIR}/dashboards/${GF_DB_FILE}" ]]; then
            echo " SUCCESS: Dashboard ${dashboard} JSON written to ${BACKUP_DIR}/dashboards/${GF_DB_FILE}"
        else
            echo " ERROR: Dashboard ${dashboard} backup file ${BACKUP_DIR}/dashboards/${GF_DB_FILE} was not created!"
            STATUS=255
        fi
    done
    return "$STATUS"
}

# Cleanups backup files older than KEEP_DAYS.
# Logs the deleted files if any.
cleanup() {
    echo
    echo "Cleanup"
    DELETED=$(find "${BACKUP_DIR}" -maxdepth 1 -name "*.gz" -type f -daystart -mtime +"${KEEP_DAYS}" -print -delete)
    # convert to array
    set -f # disable glob (wildcard) expansion
    IFS=$'\n' # split on newline chars
    DELETED=(${DELETED})
    NUM_DELETED=${#DELETED[@]}
    if [[ -z $DELETED ]]; then
        echo " - No files deleted"
    else
        echo " - Deleted $NUM_DELETED files older than $KEEP_DAYS days"
        for d in "${DELETED[@]}"; do
            echo "    $d"
        done
    fi

    echo
    echo "Cleanup Grafana dashboards"
    DELETED=$(find "${BACKUP_DIR}/dashboards" -maxdepth 1 -name "*.json" -type f -daystart -mtime +"${KEEP_DAYS}" -print -delete)
    # convert to array
    set -f # disable glob (wildcard) expansion
    IFS=$'\n' # split on newline chars
    DELETED=(${DELETED})
    NUM_DELETED=${#DELETED[@]}
    if [[ -z $DELETED ]]; then
        echo " - No grafana dashboards deleted"
    else
        echo " - Deleted $NUM_DELETED grafana dashboard backups older than $KEEP_DAYS days"
        for d in "${DELETED[@]}"; do
            echo "    $d"
        done
    fi
}

# export metrics for prometheus/node_exporter textfile collector
# metrics: 
#   - date of last backup
#   - backup file sizes
#   - duration
metrics_dump() {
    echo 
    echo "Writing backup metrics to file $NODE_EXPORTER_DIR/backup_full.prom"

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
echo "=================================="
echo "Backup started $DATE_STRING"
echo "=================================="
START="$(date +%s)"

mysql_dump 
EXIT_CODE_MYSQL=$?

# xml_dump
# EXIT_CODE_XML=$?

files_dump
EXIT_CODE_FILES=$?

grafana_dashboard_dump
EXIT_CODE_GRAFANA=$?

END="$(date +%s)"

cleanup

TOTAL_BACKUP_SIZE="$(du -s "${BACKUP_DIR}" | cut -f1)"

metrics_dump

echo

