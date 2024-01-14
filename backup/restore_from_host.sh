#!/bin/bash
# testfile moritz
FILENAME=./portal_db_backup_2024.01.12_04.15.01.gz
echo "Starting restoring to $FILENAME"
gunzip -c $FILENAME | docker exec -i mardi-mysql sh -c 'exec mysql $MYSQL_DATABASE -u $MYSQL_USER -p$MYSQL_PASSWORD'
echo "Restore done"
