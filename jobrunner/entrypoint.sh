#!/bin/bash
set -e

# Do the environment substitution from the original image
export DOLLAR='$'
envsubst < /LocalSettings.php.template > /var/www/html/w/LocalSettings.php

exec "$@"