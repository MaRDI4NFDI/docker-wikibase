#!/bin/bash

 # Restores backup, either SQL database dump or XML pages backup, and uploaded images.
# Call this manually, see README

set -e # do not continue on error

# redirect all output to stdout && log file
# Note: $BACKUP_DIR is set in the Dockerfile.
exec &> >(tee -a "$BACKUP_DIR/restore.log")


################################################################################
## Determine backup file

# Determine the full path to the backup file (as mounted in the container).
# If no file was specified, then sets the most recent backup file,
# depending on which backup type was set, the most recent SQL or XML backup file is set.
_det_file() {
    # check if BACKUP_FILE has been passed as parameter to the script
    if [[ -z ${BACKUP_FILE}  ]]; then
        # no backup file passed to the command line, find the most recent backup file
        case ${BACKUP_TYPE} in
            sql) BACKUP_FILE=$(find "$BACKUP_DIR" -name "portal_db_backup_*.gz" -printf "%T@ %P\n" | sort -n | tail -1 | cut -d' ' -f2);;
            xml) BACKUP_FILE=$(find "$BACKUP_DIR" -name "portal_xml_backup_*.gz" -printf "%T@ %P\n" | sort -n | tail -1 | cut -d' ' -f2);;
            img) BACKUP_FILE=$(find "$BACKUP_DIR" -name "images_*.gz" -printf "%T@ %P\n" | sort -n | tail -1 | cut -d' ' -f2);;
            img-import) BACKUP_FILE=$(find "$BACKUP_DIR" -name "images_*.gz" -printf "%T@ %P\n" | sort -n | tail -1 | cut -d' ' -f2);;
        esac
    fi
    BACKUP_FILE=${BACKUP_DIR}/${BACKUP_FILE}
    # check that the backup file exists
    if [[ ! -f ${BACKUP_FILE} ]]; then
       echo "ERROR file $BACKUP_FILE not found"; echo
       exit 1
    fi
}


################################################################################
## Restore functions

# Restores the wiki database from a SQL backup
# If no SQL file was specified from the command line (-f filename), then the most recent SQL backup is restored.
restore_db_backup() {
    _det_file
    echo "Restoring SQL database backup from $BACKUP_FILE"
    # unzip the backup file and restore the database
    if \
        gzip -d -c "$BACKUP_FILE"|mysql -u"$DB_USER" -p"$DB_PASS" -h"$DB_HOST" --database "$DB_NAME" 
    then
    # if [[ $? -eq 0 ]]; then
        echo "Done"
    else
        echo "ERROR restoring database"; echo
        exit 1
    fi
}


# restore images by copying backup of /var/www/html/w/images folder
restore_images_backup() {
    _det_file
    echo "Restoring images directory backup from $BACKUP_FILE"
    if \
        tar --overwrite --owner www-data --group www-data -xzv -f "$BACKUP_FILE" -C /var/www/html/w/ images
    then
         echo "Done"
    else
        echo "ERROR restoring images directory"; echo
        exit 1
    fi
}


# restore images by uploading images to the wiki as new files
restore_images_backup_import() {
    _det_file
    echo "Importing images directory backup from $BACKUP_FILE"
    # use importImages.php maintenance script https://www.mediawiki.org/wiki/Manual:ImportImages.php
    # extract files to /tmp/
    IGNORE_FOLDERS=(deleted thumb archive)
    FILE_NAME=$(basename -- "$BACKUP_FILE")
    IMAGE_BACKUP_DIR=/tmp/${FILE_NAME%.*.*}
    mkdir -p "$IMAGE_BACKUP_DIR"
    tar -xzf "$BACKUP_FILE" -C "$IMAGE_BACKUP_DIR" images
    for ignore in "${IGNORE_FOLDERS[@]}"; do
        rm -rf "$IMAGE_BACKUP_DIR/images/$ignore"
    done
    # import images as apache user, in order to get the correct permissions
    if \
        su -l www-data -s /bin/bash -c 'php /var/www/html/w/maintenance/importImages.php --search-recursively --conf /shared/LocalSettings.php --comment "Importing images backup" '"$IMAGE_BACKUP_DIR"'/images' &&\
        rm -rf "$IMAGE_BACKUP_DIR"
    then
         echo "Done"
    else
        echo "ERROR restoring images directory"; echo
        exit 1
    fi
}

# Restores a XML backup
# If no XML file was specified from the command line (-f filename), then the most recent XML backup is restored.
# https://www.mediawiki.org/wiki/Manual:Importing_XML_dumps
restore_xml_backup() {
    _det_file
    echo "Attempting to restore XML backup from $BACKUP_FILE"
    if \
        cd /var/www/html/W/ && php maintenance/importDump.php --conf /shared/LocalSettings.php "$BACKUP_FILE" --username-prefix=""
    then
        echo "Done"
    else
        echo "ERROR restoring database"; echo
        exit 1
    fi
}

################################################################################
## Help text

_help() {
    echo "Usage:  restore.sh [-t <type> [-f <file>]]"
    echo 
    echo "Backup type (-t):"
    echo "  -t sql            Restore database from MySQL backup"
    echo "  -t xml            Restore database from XML backup (does not preserve edit"
    echo "                    history)."
    echo "  -t img            Restore uploaded images via copy; overwrites existing "
    echo "                    files and keeps files not included in the backup."
    echo "                    This works only if the DB is intact or is restored via"
    echo "                    SQL backup!"
    echo "  -t img-import     Restore uploaded images via ImportImages.php; uploads all"
    echo "                    image files found in backup folder, ignoring subfolders"
    echo "                    archive, deleted, thumb, temp)."
    echo "                    This is a re-upload and may cause duplicates; useful"
    echo "                    together with restoring the Wiki from a XML backup."
    echo ""
    echo "Backup file (-f):"
    echo "  -f                Restore backup from specified file. Requires -t type!"
    echo "                    If -f is not set, the most recent file is used, matching"
    echo "                    the given backup type (-t)"
    echo 
    echo "Examples:"
    echo
    echo "  * Default: restore MySQL backup (type=sql) and image backup (type=img),"
    echo "    using the most recent backup files:"
    echo
    echo "      restore.sh"
    echo
    echo "  * Restore backup of <type> xml|img|sql|img-import, using the most recent"
    echo "    backup file:"
    echo
    echo "      restore.sh -t <type>"
    echo
    echo "  * Restore backup of <type> xml|img|sql|img-import from <file>:"
    echo
    echo "      restore.sh -t <type> -f <file>"
    echo
}



################################################################################
#                                  MAIN                                        #
################################################################################

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
    echo "ERROR: missing option -t type"; echo
    _help
    exit 1
fi

echo "==================================="
echo "Restore started at $(date +%Y.%m.%d_%H.%M.%S)"
echo "==================================="
echo

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
        img-import) restore_images_backup_import;;
        *) echo "ERROR: Unknown backup type \"$BACKUP_TYPE\""; echo
            _help
            exit 1;;
    esac
fi
echo
