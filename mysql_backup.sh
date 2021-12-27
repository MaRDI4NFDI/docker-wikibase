#!/usr/bin/env bash

# Backup the portal wiki database
# https://mariadb.com/kb/en/mysqldump/
mysqldump -u$DB_USER -p$DB_PASS -h$DB_HOST --databases $DB_NAME | gzip > /data/portal_db_backup_`date +\%Y.\%m.\%d_%H.%M.%S`.gz

