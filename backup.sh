#!/bin/bash

# Creates a backup of the SQL database and an XML backup of all pages (last version only).
# Called by the cronjob (or manually, see README)

set +e # continue on error

LOG_FILE="/data/backup.log" # internal path to log file
BACKUP_DIR="/data" # internal mount path of backup directory on the host
DATE_STRING=`date +\%Y.\%m.\%d_%H.%M.%S` # date string to use in file names


# redirect all output to log file
exec 1>>$LOG_FILE
exec 2>&1

# Backups the portal wiki database.
# https://mariadb.com/kb/en/mysqldump/
mysql_dump() {
    printf "MySQL backup\n"
    MYSQL_DUMP_FILE=portal_db_backup_${DATE_STRING}.gz
    mysqldump -u${DB_USER} -p${DB_PASS} -h${DB_HOST} --databases ${DB_NAME} | gzip > ${BACKUP_DIR}/${MYSQL_DUMP_FILE}
    if [[ -f ${BACKUP_DIR}/${MYSQL_DUMP_FILE} ]]; then
        printf " - MySQL dump written to ${MYSQL_DUMP_FILE}\n"
    else
        printf " - MySQL dump failed with status $?\n"
    fi
}

# Backups the portal wiki pages as xml.
# https://www.mediawiki.org/wiki/Manual:DumpBackup.php
xml_dump() {
    printf "XML backup\n"
    XML_DUMP_FILE=portal_xml_backup_${DATE_STRING}.gz
    # parsoid requires script to be executed from mw root
    cd /var/www/html/
    /usr/local/bin/php /var/www/html/maintenance/dumpBackup.php --current --output=gzip:${BACKUP_DIR}/${XML_DUMP_FILE} --quiet --conf /shared/LocalSettings.php
    if [[ -f ${BACKUP_DIR}/${XML_DUMP_FILE} ]]; then
        printf " - XML dump written to ${XML_DUMP_FILE}\n"
    else
        printf " - XML dump failed with status $?\n"
    fi    
}

# Backups uploaded files
files_dump() {
    printf "Files backup\n"
    IMAGES_FILE=images_${DATE_STRING}.tar.gz
    tar -czf ${BACKUP_DIR}/${IMAGES_FILE} -C /var/www/html/ images
    if [[ -f ${BACKUP_DIR}/${IMAGES_FILE} ]]; then
        printf " - Uploaded images backup written to ${IMAGES_FILE}\n"
    else
        printf " - Uploaded images backup failed with status $?\n"
    fi
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

# main script
printf "Backup started ${DATE_STRING}\n" 
mysql_dump 
xml_dump
files_dump
cleanup
printf "\n"

# to do send mail
# export AMB_REMOTE_EXEC="ssh -C $AMB_TARGET"
# | mail -s "AutoMySQLBackup | $AMB_TARGET | `date +'%Y-%m-%d %r %Z'`" root
