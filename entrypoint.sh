#!/bin/bash
# This file is provided by the wikibase/wikibase docker image.

# Copy LocalSettings from share if exists
if [ -e "/shared/LocalSettings.php" ]; then
  cp /shared/LocalSettings.php /var/www/html/LocalSettings.php
else
  # Test if required environment variables have been set
  REQUIRED_VARIABLES=(MW_ADMIN_NAME MW_ADMIN_PASS MW_ADMIN_EMAIL MW_WG_SECRET_KEY MYSQL_SERVER MYSQL_USER MYSQL_PASSWORD MYSQL_DATABASE)
  for i in ${REQUIRED_VARIABLES[@]}; do
      eval THISSHOULDBESET=\$$i
      if [ -z "$THISSHOULDBESET" ]; then
      echo "$i is required but isn't set. You should pass it to docker. See: https://docs.docker.com/engine/reference/commandline/run/#set-environment-variables--e---env---env-file";
      exit 1;
      fi
  done
  set -eu
  php /var/www/html/maintenance/install.php --dbuser "$MYSQL_USER" --dbpass "$MYSQL_PASSWORD" --dbname "$MYSQL_DATABASE" --dbserver "$MYSQL_SERVER" --lang "$MW_SITE_LANG" --pass "$MW_ADMIN_PASS" "$MW_SITE_NAME" "$MW_ADMIN_NAME"
  
  # Copy our LocalSettings into place after install from the template
  # https://stackoverflow.com/a/24964089/4746236
  export DOLLAR='$'
  envsubst < /LocalSettings.php.template > /var/www/html/LocalSettings.php
  # Copy LocalSettings to shared location
  cp /var/www/html/LocalSettings.php /shared/LocalSettings.php
  cp -r /var/www/html/LocalSettings.d /shared/LocalSettings.d

  # Run update.php to install Wikibase
  php /var/www/html/maintenance/update.php --quick

  php /var/www/html/maintenance/resetUserEmail.php --no-reset-password "$MW_ADMIN_NAME" "$MW_ADMIN_EMAIL"

  # Run extrascripts on first run
  if [ -f /extra-install.sh ]; then
      source /extra-install.sh
  fi

fi

# Create bot user
if [[ "${BOTUSER_NAME:-}" ]]; then
  php /var/www/html/maintenance/createAndPromote.php $BOTUSER_NAME $BOTUSER_PW --bot
fi

# Starting the cron-service for regular_maintenance
/etc/init.d/cron start

# Run the actual entry point
(cd /var/www/html/extensions/VisualEditor/lib/ve/rebaser;npm start) &
docker-php-entrypoint apache2-foreground
