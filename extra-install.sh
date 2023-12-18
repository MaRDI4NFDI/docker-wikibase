#!/bin/bash

php /var/www/html/extensions/CirrusSearch/maintenance/UpdateSearchIndexConfig.php
php /var/www/html/extensions/CirrusSearch/maintenance/ForceSearchIndex.php --skipParse
php /var/www/html/extensions/CirrusSearch/maintenance/ForceSearchIndex.php --skipLinks --indexOnSkip

