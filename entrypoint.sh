#!/bin/bash
# This file is provided by the wikibase/wikibase docker image.


if [[ "${DB_SERVER:-}" ]]; then
  # Wait for the db to come up
  /wait-for-it.sh $DB_SERVER -t 300
  # Sometimes it appears to come up and then go back down meaning MW install fails
  # So wait for a second and double check!
  sleep 1
  /wait-for-it.sh $DB_SERVER -t 300
fi

# Run extra scripts everytime
if [ -f /extra-entrypoint-run-first.sh ]; then
    source /extra-entrypoint-run-first.sh
fi

# Copy LocalSettings from share if exists
if [ -e "/shared/LocalSettings.php" ]; then
  cp /shared/LocalSettings.php /var/www/html/w/LocalSettings.php
fi

# Do the mediawiki install (only if LocalSettings doesn't already exist)
if [ ! -e "/var/www/html/w/LocalSettings.php" ]; then
    # Test if required environment variables have been set
    REQUIRED_VARIABLES=(MW_ADMIN_NAME MW_ADMIN_PASS MW_ADMIN_EMAIL MW_WG_SECRET_KEY DB_SERVER DB_USER DB_PASS DB_NAME)
    for i in ${REQUIRED_VARIABLES[@]}; do
        eval THISSHOULDBESET=\$$i
        if [ -z "$THISSHOULDBESET" ]; then
        echo "$i is required but isn't set. You should pass it to docker. See: https://docs.docker.com/engine/reference/commandline/run/#set-environment-variables--e---env---env-file";
        exit 1;
        fi
    done
    set -eu
    php /var/www/html/w/maintenance/install.php --dbuser "$DB_USER" --dbpass "$DB_PASS" --dbname "$DB_NAME" --dbserver "$DB_SERVER" --lang "$MW_SITE_LANG" --pass "$MW_ADMIN_PASS" "$MW_SITE_NAME" "$MW_ADMIN_NAME"

    # Copy our LocalSettings into place after install from the template
    # https://stackoverflow.com/a/24964089/4746236
    export DOLLAR='$'
    envsubst < /LocalSettings.php.template > /var/www/html/w/LocalSettings.php
    # Copy LocalSettings to shared location
    cp /var/www/html/w/LocalSettings.php /shared/LocalSettings.php

    # Run update.php to install Wikibase
    php /var/www/html/w/maintenance/update.php --quick

    php /var/www/html/w/maintenance/resetUserEmail.php --no-reset-password "$MW_ADMIN_NAME" "$MW_ADMIN_EMAIL"

    # Run extrascripts on first run
    if [ -f /extra-install.sh ]; then
        source /extra-install.sh
    fi

fi

# Copy LocalSettings to shared location
if [ ! -e "/shared/LocalSettings.php" ]; then
  cp /var/www/html/w/LocalSettings.php /shared/LocalSettings.php
fi

if [[ "${BOTUSER_NAME:-}" ]]; then
  php /var/www/html/w/maintenance/createAndPromote.php $BOTUSER_NAME $BOTUSER_PW --bot
fi


# Starting the cron-service for regular_maintenance
/etc/init.d/cron start

# Run the actual entry point
(cd /var/www/html/w/extensions/VisualEditor/lib/ve/rebaser;npm start) &
docker-php-entrypoint apache2-foreground
