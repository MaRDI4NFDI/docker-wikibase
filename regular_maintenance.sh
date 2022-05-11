#!/bin/sh
# Refreshing the content of external pages imported pages.
# Only use this for maintenance scripts which do not take much time.
echo "starting regular_maintenance at:"`date +"%Y-%m-%d %T"`
php /var/www/html/extensions/ExternalContent/maintenance/RefreshExternalContent.php
echo "done with regular_maintenance at:"`date +"%Y-%m-%d %T"`


