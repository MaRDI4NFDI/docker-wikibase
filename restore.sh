#!/bin/bash
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
       printf 'ERROR file %s not found\n\n' "$BACKUP_FILE"
       exit 1
    fi
}


################################################################################
## Restore functions

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


# restore images by copying backup of /var/www/html/images folder
restore_images_backup() {
    _det_file
    printf 'Restoring images directory backup from %s\n' "$BACKUP_FILE"
    if \
        tar --overwrite --owner www-data --group www-data -xzv -f "$BACKUP_FILE" -C /var/www/html/ images
    then
         printf "Done\n"
    else
        printf "ERROR restoring images directory\n\n"
        exit 1
    fi
}


# restore images by uploading images to the wiki as new files
restore_images_backup_import() {
    _det_file
    printf 'Importing images directory backup from %s\n' "$BACKUP_FILE"
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

################################################################################
## Help text

_help() {
    printf "Usage:  restore.sh [-t <type> [-f <file>]]\n"
    printf "\n"
    printf "Backup type (-t):\n"
    printf "  -t sql            Restore database from MySQL backup\n"
    printf "  -t xml            Restore database from XML backup (does not preserve edit\n"
    printf "                    history).\n"
    printf "  -t img            Restore uploaded images via copy; overwrites existing \n"
    printf "                    files and keeps files not included in the backup.\n"
    printf "                    This works only if the DB is intact or is restored via\n"
    printf "                    SQL backup!\n"
    printf "  -t img-import     Restore uploaded images via ImportImages.php; uploads all\n"
    printf "                    image files found in backup folder, ignoring subfolders\n"
    printf "                    archive, deleted, thumb, temp).\n"
    printf "                    This is a re-upload and may cause duplicates; useful\n"
    printf "                    together with restoring the Wiki from a XML backup.\n"
    printf "\n"
    printf "Backup file (-f):\n"
    printf "  -f                Restore backup from specified file. Requires -t type!\n"
    printf "                    If -f is not set, the most recent file is used, matching\n"
    printf "                    the given backup type (-t)\n"
    printf "\n"
    printf "Examples:\n\n"
    printf "  * Default: restore MySQL backup (type=sql) and image backup (type=img),\n"
    printf "    using the most recent backup files:\n"
    printf "\n"
    printf "      restore.sh\n"
    printf "\n"
    printf "  * Restore backup of <type> xml|img|sql|img-import, using the most recent\n"
    printf "    backup file:\n"
    printf "\n"
    printf "      restore.sh -t <type>\n"
    printf "\n"
    printf "  * Restore backup of <type> xml|img|sql|img-import from <file>:\n"
    printf "\n"
    printf "      restore.sh -t <type> -f <file>\n"
    printf "\n"
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
    printf "ERROR: missing option -t type\n\n"
    _help
    exit 1
fi

printf '=============================\n'
printf 'Restore started at %s\n' "$(date +%Y.%m.%d_%H.%M.%S)"
printf '=============================\n\n'

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
        *) printf 'ERROR: Unknown backup type "%s"\n\n' "$BACKUP_TYPE"
            _help
            exit 1;;
    esac
fi
printf "\n"
