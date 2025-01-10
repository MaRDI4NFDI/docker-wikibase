#!/bin/bash

# Do the mediawiki install (only if LocalSettings doesn't already exist)
if [ ! -e "/var/www/html/LocalSettings.php" ]; then
    set -euxo pipefail
    php maintenance/install.php \
      --server "$MW_SERVER" \
      --scriptpath="$MW_SCRIPT_PATH" \
      --dbtype "$MW_DBTYPE" \
      --dbpath "$MW_DBPATH" \
      --lang "$MW_LANG" \
      --pass "$MW_PASS" \
      --with-developmentsettings \
      --skins Vector \
      "$MW_SITENAME" "$MW_USER"
    # Run update.php to install Wikibase
    php /var/www/html/maintenance/update.php --quick
fi

# Run the actual entry point
/usr/sbin/apache2ctl -D FOREGROUND

