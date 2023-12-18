######################
#   Global settings  #
######################
ARG MEDIAWIKI_VERSION=lts
ARG WMF_BRANCH=wmf/1.41.0-wmf.28
ARG WMF_BRANCH_OLD=wmf/1.41.0-wmf.28
ARG REL_BRANCH=REL1_41

################
#   Fetcher    #
################
FROM ubuntu:xenial as fetcher

RUN apt-get update && \
    apt-get install --yes --no-install-recommends git=1:2.* ssh unzip=6.* jq=1.* curl=7.* ca-certificates=201* && \
    apt-get install --reinstall ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# make global settings known in this build stage
ARG WMF_BRANCH
ARG WMF_BRANCH_OLD
ARG REL_BRANCH

# clone extensions from github, using specific branch

COPY clone-extension.sh .

RUN \
bash clone-extension.sh Wikibase ${WMF_BRANCH_OLD};\
echo 'finished cloning'

# clone core
RUN git clone --depth=1 https://github.com/wikimedia/mediawiki -b ${WMF_BRANCH} &&\
rm -rf mediawiki/.git

# Clone Vector Skin (not included in the mediawiki repository)
RUN git clone --depth=1 https://github.com/wikimedia/mediawiki-skins-Vector -b ${WMF_BRANCH_OLD} Vector &&\
rm -rf Vector/.git

################
#  Collector   #
################
FROM mediawiki:${MEDIAWIKI_VERSION} as collector

RUN rm -rf /var/www/html/*

COPY --from=fetcher /mediawiki /var/www/html

COPY --from=fetcher /Wikibase /var/www/html/extensions/Wikibase

# collect Vector Skin
COPY --from=fetcher /Vector /var/www/html/skins/Vector

################
#   Composer   #
################
FROM mediawiki:${MEDIAWIKI_VERSION} as build
COPY --from=collector /var/www/html /var/www/html
WORKDIR /var/www/html/
COPY composer.local.json /var/www/html/composer.local.json

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

COPY --from=composer /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev


#######################################
#            MaRDI wikibase           #
# Build from official mediawiki image #
#######################################
FROM mediawiki:${MEDIAWIKI_VERSION}

# PRETTY_NAME="Debian GNU/Linux 11 (bullseye)"
# NAME="Debian GNU/Linux"
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive\
    apt-get install --yes --no-install-recommends \
    nano jq=1.* libbz2-dev=1.* gettext-base npm grunt cron vim librsvg2-bin libpq-dev  && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite

RUN install -d /var/log/mediawiki -o www-data
RUN docker-php-ext-install calendar bz2 pdo pgsql pdo_pgsql

RUN rm -rf /var/www/html/*
COPY --from=build /var/www/html /var/www/html
COPY wait-for-it.sh /wait-for-it.sh
RUN chmod +x /wait-for-it.sh
COPY entrypoint.sh /entrypoint.sh
COPY LocalSettings.php.template /LocalSettings.php.template
COPY htaccess /var/www/html/.htaccess
COPY images /var/www/html/images_repo/
RUN ln -s /var/www/html/ /var/www/html/w
ENV MW_SITE_NAME=wikibase-docker\
    MW_SITE_LANG=en

COPY LocalSettings.php.mardi.template /LocalSettings.php.mardi.template
COPY extra-install.sh /
RUN cat /LocalSettings.php.mardi.template >> /LocalSettings.php.template && rm /LocalSettings.php.mardi.template
COPY oauth.ini /templates/oauth.ini
RUN mkdir /shared

# Setup regular maintenance cron in MediaWiki container.
COPY regular_maintenance.sh /var/www/html/regular_maintenance.sh
RUN chmod ugo+rwx /var/www/html/regular_maintenance.sh
RUN echo "* */1 * * *      root   /var/www/html/regular_maintenance.sh > /var/www/html/regular_maintenance.log"  \
    >> /etc/cron.d/Regular_maintenance

# Set ownership of the uploaded images directory
RUN chown www-data:www-data /var/www/html/images

##
ENTRYPOINT ["/bin/bash"]
CMD ["/entrypoint.sh"]
