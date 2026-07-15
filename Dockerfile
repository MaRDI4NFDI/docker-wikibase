######################
# Global settings
######################
ARG MEDIAWIKI_VERSION=stable-fpm

################
# Fetcher
################
FROM ubuntu:jammy AS fetcher

RUN apt-get update && \
    apt-get install --yes --no-install-recommends git=1:2.* ssh unzip=6.* jq=1.* curl=7.* ca-certificates patch && \
    apt-get install --reinstall ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /

COPY wikibase-submodules-from-github-instead-of-phabricator.patch wikibase-local-media-parser-options.patch clone_all.sh ./

RUN bash clone_all.sh

################
# Composer
################
FROM mediawiki:${MEDIAWIKI_VERSION} AS build

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install --yes --no-install-recommends \
    zlib1g-dev libjpeg-dev libpng-dev libfreetype6-dev libzip-dev zip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN set -xe && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install gd && \
    docker-php-ext-enable gd && \
    docker-php-ext-install zip

RUN rm -rf /var/www/html/*

COPY --from=fetcher /mediawiki /var/www/html
COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY composer.local.json /var/www/html/composer.local.json

WORKDIR /var/www/html/

ENV COMPOSER_ALLOW_SUPERUSER=1

RUN git config --global --add safe.directory /var/www/html && \
    composer install --no-dev

#######################################
# MaRDI wikibase
# Build from official mediawiki image
#######################################
FROM mediawiki:${MEDIAWIKI_VERSION}

ARG WIKIBASE_VERSION=unknown
ARG WIKIBASE_COMMIT=unknown
ARG WIKIBASE_BUILT_AT=unknown

# Site/runtime defaults and deployment metadata
ENV MW_SITE_NAME=wikibase-docker \
    MW_SITE_LANG=en \
    PHP_FPM_PM=dynamic \
    PHP_FPM_MAX_CHILDREN=75 \
    PHP_FPM_START_SERVERS=25 \
    PHP_FPM_MIN_SPARE_SERVERS=10 \
    PHP_FPM_MAX_SPARE_SERVERS=40 \
    PHP_FPM_MAX_REQUESTS=1000 \
    PHP_FPM_REQUEST_TIMEOUT=60s \
    OPCACHE_MEMORY_CONSUMPTION=512 \
    OPCACHE_MAX_ACCELERATED_FILES=50000 \
    OPCACHE_INTERNED_STRINGS_BUFFER=32 \
    OPCACHE_VALIDATE_TIMESTAMPS=0 \
    OPCACHE_REVALIDATE_FREQ=0 \
    OPCACHE_JIT_BUFFER_SIZE=128M \
    WIKIBASE_VERSION=$WIKIBASE_VERSION \
    WIKIBASE_COMMIT=$WIKIBASE_COMMIT \
    WIKIBASE_BUILT_AT=$WIKIBASE_BUILT_AT \
    TZ=Europe/Berlin

LABEL org.opencontainers.image.title="MaRDI wikibase Container" \
      org.opencontainers.image.description="Mediawiki/Wikibase image for the MaRDI portal" \
      org.opencontainers.image.source="https://github.com/MaRDI4NFDI/docker-wikibase" \
      org.opencontainers.image.documentation="https://github.com/MaRDI4NFDI/docker-wikibase" \
      org.opencontainers.image.vendor="MaRDI4NFDI"

WORKDIR /var/www/html/w/

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install --yes --no-install-recommends \
    nano jq=1.* libbz2-dev=1.* gettext-base cron vim librsvg2-bin libpq-dev libyaml-dev \
    lua5.1 liblua5.1-0-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN install -d /var/log/mediawiki -o www-data && \
    pecl install yaml && \
    docker-php-ext-enable yaml && \
    docker-php-ext-install calendar bz2 pdo pgsql pdo_pgsql

RUN rm -rf /var/www/html/*

COPY --from=build /var/www/html /var/www/html/w

# Temporarily patch EventBus
RUN php -r " \
    \$f = '/var/www/html/w/extensions/EventBus/includes/Rest/EventBodyValidator.php'; \
    \$code = file_get_contents(\$f); \
    \$code = str_replace( \
        \"unset( \\\$event['mediawiki_signature'] );\", \
        \"unset( \\\$event['mediawiki_signature'] );\\n\\t\\tunset( \\\$event['meta']['dt'] );\", \
        \$code \
    ); \
    file_put_contents(\$f, \$code); \
    "

COPY wait-for-it.sh entrypoint.sh extra-install.sh /
COPY LocalSettings.php.template /
COPY oauth.ini /templates/oauth.ini
COPY images /var/www/html/w/images_repo/
COPY ./LocalSettings.d /var/www/html/w/LocalSettings.d
COPY regular_maintenance.sh /var/www/html/regular_maintenance.sh
COPY mardi_php.ini /usr/local/etc/php/conf.d/mardi_php.ini
COPY ./php-fpm/logging.conf /usr/local/etc/php-fpm.d/zz-logging.conf
COPY ./php-fpm/performance.conf.template ./php-fpm/opcache.conf.template /templates/

RUN chmod +x /wait-for-it.sh && \
    chmod ugo+rwx /var/www/html/regular_maintenance.sh && \
    echo "* */1 * * * root /var/www/html/regular_maintenance.sh > /var/www/html/regular_maintenance.log" >> /etc/cron.d/Regular_maintenance && \
    mkdir /shared && \
    chown www-data:www-data /var/www/html/w/images && \
    chmod 777 /var/www/html/w/cache

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo "$TZ" > /etc/timezone && \
    printf '[PHP]\ndate.timezone = "%s"\n' "$TZ" > /usr/local/etc/php/conf.d/tzone.ini


# HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 CMD php /var/www/html/w/maintenance/run.php getConfiguration --format json  --settings wgServer
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 CMD php /var/www/html/w/maintenance/run.php view Main_Page


ENTRYPOINT ["/bin/bash"]
CMD ["/entrypoint.sh"]