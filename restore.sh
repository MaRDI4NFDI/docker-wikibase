#!/bin/bash

# Restores backup, either SQL database dump or XML pages backup.
# Call this manually, see README

set -e # do not continue on error

LOG_FILE="/data/backup.log" # internal path to log file
BACKUP_DIR="/data" # internal mount path of backup directory on the host

# redirect all output to log file
exec 1>>$LOG_FILE
exec 2>&1

# Determine the full path to the backup file (as mounted in the container).
# If no file was specified, then sets the most recent backup file,
# depending on which backup type was set, the most recent SQL or XML backup file is set.
_det_file() {
    # check if BACKUP_FILE has been passed as parameter to the script
    if [[ -z ${BACKUP_FILE}  ]]; then
        # no backup file passed to the command line, find the most recent backup file
        case ${BACKUP_TYPE} in
            sql) BACKUP_FILE=$(ls -t ${BACKUP_DIR}/portal_db_backup_*.gz | head -1);;
            xml) BACKUP_FILE=$(ls -t ${BACKUP_DIR}/portal_xml_backup_*.gz | head -1);;
        esac
    else
        # a backup file was passed to the command line, prepend the full path to the backup folder (as mounted in the container)
        BACKUP_FILE=${BACKUP_DIR}/${BACKUP_FILE}
        # check that the backup file exists
        if [[ ! -f ${BACKUP_FILE} ]]; then
           printf "ERROR file ${BACKUP_FILE} not found\n\n"
           exit 1
        fi
    fi
}

# Restores the wiki database from a SQL backup
# If no SQL file was specified from the command line (-f filename), then the most recent SQL backup is restored.
restore_db_backup() {
    _det_file
    printf "Restoring SQL database backup from $BACKUP_FILE\n"
    # unzip the backup file and restore the database
    gzip -d -c $BACKUP_FILE|mysql -u${DB_USER} -p${DB_PASS} -h${DB_HOST} --database ${DB_NAME} 
    if [[ $? -eq 0 ]]; then
        printf "Done\n"
    else
        printf "ERROR restoring database\n\n"
        exit 1
    fi
}

# Restores a XML backup
# If no XML file was specified from the command line (-f filename), then the most recent XML backup is restored.
# https://www.mediawiki.org/wiki/Manual:Importing_XML_dumps
restore_xml_backup() {
    _det_file
    printf "Attempting to restore XML backup from $BACKUP_FILE\n"
    cd /var/www/html/ && php maintenance/importDump.php --conf /shared/LocalSettings.php $BACKUP_FILE --username-prefix=""
}

###########################
#       Main script       #
###########################

printf "Restore started at `date +\%Y.\%m.\%d_%H.%M.%S`\n"

# Handle input flags
BACKUP_TYPE=sql
while getopts "t:f:" flag; do
case ${flag} in
    t) BACKUP_TYPE=$OPTARG;;
    f) BACKUP_FILE=$OPTARG;;
esac
done

# call restore from sql backup by default
if [[ -z "${BACKUP_TYPE}" ]]; then
    restore_db_backup
else
    # a backup type was set explicitly
    case ${BACKUP_TYPE} in
        sql) restore_db_backup;;
        xml) restore_xml_backup;;
        *) printf "Unknown backup type ${BACKUP_TYPE}\n\n"; exit 1;;
    esac
fi
printf "\n"
