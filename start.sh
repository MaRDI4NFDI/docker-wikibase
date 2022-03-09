#!/bin/sh

# Entrypopint of the Dockerfile.
# Sets up the crontab to call backup.sh on a regular basis

set +e

# Adjust timezone.
# TIMEZONE is set in the Dockerfile
cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
echo ${TIMEZONE} > /etc/timezone
echo "Date: `date`."

# Set up backup group.
# BACKUP_GID is set in the Dockerfile
: ${BACKUP_GID:="$BACKUP_DEFAULT_GID"}
if [ "$(id -g backup)" != "$BACKUP_GID" ]; then
	groupmod -o -g "$BACKUP_GID" backup
fi
echo "Using group ID $(id -g backup)."

# Set up backup user.
# BACKUP_UID is set in the Dockerfile
: ${BACKUP_UID:="$BACKUP_DEFAULT_UID"}
if [ "$(id -u backup)" != "$BACKUP_UID" ]; then
	usermod -o -u "$BACKUP_UID" backup
fi
echo "Using user ID $(id -u backup)."

# Make sure the files are owned by the user executing backup, as we
# will need to add/delete files.
chown backup:backup /app/backup.sh
chown -R backup:backup /data

# Set up crontab.
# CRONTAB is set in the Dockerfile
# CRON_SCHEDULE and the other environment variables are set in docker-compose.yml
echo "" > $CRONTAB
echo "${BACKUP_SCHEDULE} DB_HOST=${DB_HOST} DB_NAME=${DB_NAME} DB_USER=${DB_USER} DB_PASS=${DB_PASS} KEEP_DAYS=${KEEP_DAYS} /app/backup.sh" >> $CRONTAB
crontab -u backup - < /var/spool/cron/crontabs/backup

#echo "Starting cron."
exec cron -l 8 -f
