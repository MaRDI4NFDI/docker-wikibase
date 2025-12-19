######################
#   Global settings  #
######################
ARG MEDIAWIKI_VERSION=stable-fpm

################
#   Fetcher    #
################
FROM ubuntu:xenial AS fetcher

RUN apt-get update && \
    apt-get install --yes --no-install-recommends git=1:2.* ssh unzip=6.* jq=1.* curl=7.* ca-certificates=201* patch && \
    apt-get install --reinstall ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# make global settings known in this build stage
WORKDIR /

# clone extensions from github, using specific branch
COPY wikibase-submodules-from-github-instead-of-phabricator.patch clone_all.sh ./

RUN bash clone_all.sh

################
#   Composer   #
################
FROM mediawiki:${MEDIAWIKI_VERSION} AS build

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install --yes --no-install-recommends \
    zlib1g-dev libjpeg-dev libpng-dev libfreetype6-dev libzip-dev zip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN set -xe \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd \
    && docker-php-ext-enable gd \
    && docker-php-ext-install zip

RUN rm -rf /var/www/html/*
COPY --from=fetcher /mediawiki /var/www/html
WORKDIR /var/www/html/
COPY composer.local.json /var/www/html/composer.local.json
  
COPY --from=composer /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN git config --global --add safe.directory /var/www/html
RUN composer install --no-dev


#######################################
#            MaRDI wikibase           #
# Build from official mediawiki image #
#######################################
FROM mediawiki:${MEDIAWIKI_VERSION}

WORKDIR /var/www/html/w/

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive\
    apt-get install --yes --no-install-recommends \
    nano jq=1.* libbz2-dev=1.* gettext-base npm grunt cron vim librsvg2-bin libpq-dev libyaml-dev \
    lua5.1 liblua5.1-0-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN install -d /var/log/mediawiki -o www-data
RUN pecl install redis && docker-php-ext-enable redis
RUN pecl install yaml && docker-php-ext-enable yaml
RUN docker-php-ext-install calendar bz2 pdo pgsql pdo_pgsql

RUN rm -rf /var/www/html/*
COPY --from=build /var/www/html /var/www/html/w
COPY wait-for-it.sh /wait-for-it.sh
RUN chmod +x /wait-for-it.sh
COPY entrypoint.sh /entrypoint.sh
COPY LocalSettings.php.template /LocalSettings.php.template
COPY images /var/www/html/w/images_repo/
ENV MW_SITE_NAME=wikibase-docker\
    MW_SITE_LANG=en
    
ARG ENVIRONMENT=staging
COPY ./LocalSettings.d/base /var/www/html/w/LocalSettings.d    
COPY ./LocalSettings.d/${ENVIRONMENT} /var/www/html/w/LocalSettings.d

COPY extra-install.sh /
COPY oauth.ini /templates/oauth.ini
RUN mkdir /shared

# Setup regular maintenance cron in MediaWiki container.
COPY regular_maintenance.sh /var/www/html/regular_maintenance.sh
RUN chmod ugo+rwx /var/www/html/regular_maintenance.sh
RUN echo "* */1 * * *      root   /var/www/html/regular_maintenance.sh > /var/www/html/regular_maintenance.log"  \
    >> /etc/cron.d/Regular_maintenance

# Set ownership of the uploaded images directory
RUN chown www-data:www-data /var/www/html/w/images

# Fix permissions for cache https://github.com/MaRDI4NFDI/portal-compose/pull/563
RUN chmod 777 /var/www/html/w/cache
COPY mardi_php.ini /usr/local/etc/php/conf.d/mardi_php.ini

# Disable access logs in mediawiki container
COPY php-fpm-logging.conf /usr/local/etc/php-fpm.d/zz-logging.conf

ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN printf '[PHP]\ndate.timezone = "Europe/Berlin"\n' > /usr/local/etc/php/conf.d/tzone.ini

ENTRYPOINT ["/bin/bash"]
CMD ["/entrypoint.sh"]