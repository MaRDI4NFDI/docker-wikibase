#!/bin/bash

# Restores backup, either SQL database dump or XML pages backup.
# Call this manually, see README

set -e # do not continue on error

BACKUP_DIR="/data" # internal mount path of backup directory on the host

# Determine the full path to the backup file (as mounted in the container).
# If no file was specified, then sets the most recent backup file,
# depending on which backup type was set, the most recent SQL or XML backup file is set.
_det_file() {
    # check if BACKUP_FILE has been passed as parameter to the script
    if [[ -z ${BACKUP_FILE}  ]]; then
        # no backup file passed to the command line, find the most recent backup file
        case ${BACKUP_TYPE} in
            sql) BACKUP_FILE=$(find $BACKUP_DIR -name "portal_db_backup_*.gz" -printf "%T@ %P\n" | sort -n | tail -1 | cut -d' ' -f2);;
            xml) BACKUP_FILE=$(find $BACKUP_DIR -name "portal_xml_backup_*.gz" -printf "%T@ %P\n" | sort -n | tail -1 | cut -d' ' -f2);;
            img) BACKUP_FILE=$(find $BACKUP_DIR -name "images_*.gz" -printf "%T@ %P\n" | sort -n | tail -1 | cut -d' ' -f2);;
        esac
    fi
    BACKUP_FILE=${BACKUP_DIR}/${BACKUP_FILE}
    # check that the backup file exists
    if [[ ! -f ${BACKUP_FILE} ]]; then
       printf 'ERROR file %s not found\n\n' "$BACKUP_FILE"
       exit 1
    fi
}

# Restores the wiki database from a SQL backup
# If no SQL file was specified from the command line (-f filename), then the most recent SQL backup is restored.
restore_db_backup() {
    _det_file
    printf 'Restoring SQL database backup from %s\n' "$BACKUP_FILE"
    # unzip the backup file and restore the database
    if \
        gzip -d -c "$BACKUP_FILE"|mysql -u"$DB_USER" -p"$DB_PASS" -h"$DB_HOST" --database "$DB_NAME" 
    then
    # if [[ $? -eq 0 ]]; then
        printf "Done\n"
    else
        printf "ERROR restoring database\n\n"
        exit 1
    fi
}

restore_images_backup() {
    _det_file
    printf 'Restoring images directory backup from %s\n' "$BACKUP_FILE"
    # use importImages.php maintenance script https://www.mediawiki.org/wiki/Manual:ImportImages.php
    # extract files to /tmp/
    IGNORE_FOLDERS=(deleted thumb)
    FILE_NAME=$(basename -- "$BACKUP_FILE")
    IMAGE_BACKUP_DIR=/tmp/${FILE_NAME%.*.*}
    mkdir -p "$IMAGE_BACKUP_DIR"
    tar -xzf "$BACKUP_FILE" -C "$IMAGE_BACKUP_DIR" images
    for ignore in "${IGNORE_FOLDERS[@]}"; do
        rm -rf "$IMAGE_BACKUP_DIR/images/$ignore"
    done
    # import images as apache user, in order to get the correct permissions
    if \
        su -l www-data -s /bin/bash -c 'php /var/www/html/maintenance/importImages.php --search-recursively --conf /shared/LocalSettings.php --comment "Importing images backup" '"$IMAGE_BACKUP_DIR"'/images' &&\
        rm -rf "$IMAGE_BACKUP_DIR"
    then
         printf "Done\n"
    else
        printf "ERROR restoring images directory\n\n"
        exit 1
    fi
}

# Restores a XML backup
# If no XML file was specified from the command line (-f filename), then the most recent XML backup is restored.
# https://www.mediawiki.org/wiki/Manual:Importing_XML_dumps
restore_xml_backup() {
    _det_file
    printf 'Attempting to restore XML backup from %s\n' "$BACKUP_FILE"
    if \
        cd /var/www/html/ && php maintenance/importDump.php --conf /shared/LocalSettings.php "$BACKUP_FILE" --username-prefix=""
    then
        printf "Done\n"
    else
        printf "ERROR restoring database\n\n"
        exit 1
    fi
}

_help() {
    printf "Usage:  restore.sh                      restore last MySQL and images backups\n"
    printf "        restore.sh -t type              restore last backup of given type\n"
    printf "        restore.sh -t type -f file      restore backup of given type from file\n\n"
    printf "                                        supported type:\n"
    printf "                                            -t xml     XML backup\n"
    printf "                                            -t sql     MySQL backup\n"
    printf "                                            -t img     images backup\n"

}


###########################
#       Main script       #
###########################

# Handle input flags
while getopts "ht:f:" flag; do
case ${flag} in
    t) BACKUP_TYPE=$OPTARG;;
    f) BACKUP_FILE=$OPTARG;;
    h) _help
        exit 0;;
    \?) _help
        exit 1;;
esac
done

if [[ "$BACKUP_FILE" ]] && [[ -z "$BACKUP_TYPE" ]]; then
    printf "ERROR: missing option -t type\n\n"
    _help
    exit 1
fi

printf 'Restore started at %s\n' "$(date +%Y.%m.%d_%H.%M.%S)"

# call restore from sql backup by default
if [[ -z "$BACKUP_TYPE" ]]; then
    BACKUP_TYPE=sql
    restore_db_backup
    unset BACKUP_FILE
    BACKUP_TYPE=img
    restore_images_backup
else
    # a backup type was set explicitly
    case ${BACKUP_TYPE} in
        sql) restore_db_backup;;
        xml) restore_xml_backup;;
        img) restore_images_backup;;
        *) printf 'ERROR: Unknown backup type "%s"\n\n' "$BACKUP_TYPE"
            _help
            exit 1;;
    esac
fi
printf "\n"
