#!/bin/sh
set -eu

case "${APACHE_MAX_REQUEST_WORKERS:-}" in
    "")
        APACHE_MAX_REQUEST_WORKERS_DIRECTIVE=""
        ;;
    *[!0-9]*|0)
        echo "APACHE_MAX_REQUEST_WORKERS must be a positive integer" >&2
        exit 1
        ;;
    *)
        APACHE_MAX_REQUEST_WORKERS_DIRECTIVE="MaxRequestWorkers ${APACHE_MAX_REQUEST_WORKERS}"
        ;;
esac

export APACHE_MAX_REQUEST_WORKERS_DIRECTIVE
envsubst '${WIKIBASE_HOST} ${APACHE_MAX_REQUEST_WORKERS_DIRECTIVE}' \
    < /usr/local/apache2/conf/extra/mediawiki.conf.template \
    > /usr/local/apache2/conf/extra/mediawiki.conf

exec httpd-foreground
