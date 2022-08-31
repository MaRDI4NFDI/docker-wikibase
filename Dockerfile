######################
#   global settings  #
######################
ARG MEDIAWIKI_VERSION=1.38.1
ARG WMF_BRANCH=wmf/1.39.0-wmf.21
ARG REL_BRANCH=REL1_38
ARG WMDE_BRANCH=wmde.6

################
#   fetcher    #
################
FROM ubuntu:xenial as fetcher

RUN apt-get update && \
    apt-get install --yes --no-install-recommends git=1:2.* ssh unzip=6.* jq=1.* curl=7.* ca-certificates=201* && \
    apt-get install --reinstall ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# make global settings known in this build stage
ARG WMF_BRANCH
ARG REL_BRANCH
ARG WMDE_BRANCH

# clone extensions from github, using specific branch

COPY clone-extension.sh .

RUN \
bash clone-extension.sh Babel ${WMF_BRANCH};\
bash clone-extension.sh CirrusSearch ${WMF_BRANCH};\
bash clone-extension.sh cldr ${WMF_BRANCH};\
bash clone-extension.sh ConfirmEdit ${WMF_BRANCH};\
bash clone-extension.sh DataTransfer master;\
bash clone-extension.sh Elastica ${WMF_BRANCH};\
bash clone-extension.sh EntitySchema ${WMF_BRANCH};\
bash clone-extension.sh Flow ${WMF_BRANCH};\
bash clone-extension.sh JsonConfig ${WMF_BRANCH};\
bash clone-extension.sh Lockdown ${REL_BRANCH};\
bash clone-extension.sh Math ${WMF_BRANCH};\
bash clone-extension.sh MathSearch master;\
bash clone-extension.sh Nuke ${WMF_BRANCH};\
bash clone-extension.sh OAuth ${WMF_BRANCH};\
bash clone-extension.sh Popups ${WMF_BRANCH};\
bash clone-extension.sh SemanticDrilldown master;\
bash clone-extension.sh Scribunto ${WMF_BRANCH};\
bash clone-extension.sh TemplateStyles ${WMF_BRANCH};\
bash clone-extension.sh UniversalLanguageSelector ${WMF_BRANCH};\
bash clone-extension.sh VisualEditor ${WMF_BRANCH};\
bash clone-extension.sh Wikibase ${WMF_BRANCH};\
bash clone-extension.sh WikibaseCirrusSearch ${WMF_BRANCH};\
bash clone-extension.sh WikibaseManifest ${WMDE_BRANCH};\
bash clone-extension.sh YouTube ${REL_BRANCH};\
bash clone-extension.sh PluggableAuth ${REL_BRANCH}; \
bash clone-extension.sh OpenIDConnect ${REL_BRANCH}; \
bash clone-extension.sh Shibboleth ${REL_BRANCH};



# clone extensions not officially distributed by mediawiki
RUN git clone https://github.com/ProfessionalWiki/WikibaseLocalMedia.git WikibaseLocalMedia &&\
rm -rf WikibaseLocalMedia/.git

RUN git clone https://github.com/ciencia/mediawiki-extensions-TwitterWidget.git TwitterWidget &&\
rm -rf TwitterWidget/.git

RUN git clone https://github.com/PascalNoisette/mediawiki-extensions-Slides.git Slides &&\
rm -rf Slides/.git

# clone extensions from MaRDI4NFDI Project (no branch needed here, as extensions are custom made for the portal)
RUN git clone https://github.com/MaRDI4NFDI/WikibaseImport.git WikibaseImport &&\
rm -rf WikibaseImport/.git

RUN git clone https://github.com/MaRDI4NFDI/MatomoAnalytics.git MatomoAnalytics &&\
rm -rf MatomoAnalytics/.git

RUN git clone https://github.com/ProfessionalWiki/ExternalContent.git ExternalContent &&\
rm -rf ExternalContent/.git

RUN git clone https://github.com/octfx/mediawiki-extension-Plausible.git Plausible &&\
rm -rf Plausible/.git

RUN git clone https://github.com/wikimedia/mediawiki -b ${WMF_BRANCH} &&\
rm -rf mediawiki/.git


################
#  collector   #
################
FROM mediawiki:${MEDIAWIKI_VERSION} as collector

COPY --from=fetcher /mediawiki /var/www/html
# collect bundle extensions
COPY --from=fetcher /WikibaseImport /var/www/html/extensions/WikibaseImport
COPY --from=fetcher /Elastica /var/www/html/extensions/Elastica
COPY --from=fetcher /OAuth /var/www/html/extensions/OAuth
COPY --from=fetcher /CirrusSearch /var/www/html/extensions/CirrusSearch
COPY --from=fetcher /WikibaseCirrusSearch /var/www/html/extensions/WikibaseCirrusSearch
COPY --from=fetcher /UniversalLanguageSelector /var/www/html/extensions/UniversalLanguageSelector
COPY --from=fetcher /cldr /var/www/html/extensions/cldr
COPY --from=fetcher /EntitySchema /var/www/html/extensions/EntitySchema
COPY --from=fetcher /Flow /var/www/html/extensions/Flow
COPY --from=fetcher /Babel /var/www/html/extensions/Babel
COPY --from=fetcher /ConfirmEdit /var/www/html/extensions/ConfirmEdit
COPY --from=fetcher /Scribunto /var/www/html/extensions/Scribunto
COPY --from=fetcher /VisualEditor /var/www/html/extensions/VisualEditor
COPY --from=fetcher /WikibaseManifest /var/www/html/extensions/WikibaseManifest
COPY --from=fetcher /WikibaseLocalMedia /var/www/html/extensions/WikibaseLocalMedia
COPY --from=fetcher /Wikibase /var/www/html/extensions/Wikibase

# collect MaRDI extensions
COPY --from=fetcher /Math /var/www/html/extensions/Math
COPY --from=fetcher /MathSearch /var/www/html/extensions/MathSearch
COPY --from=fetcher /TemplateStyles /var/www/html/extensions/TemplateStyles
COPY --from=fetcher /JsonConfig /var/www/html/extensions/JsonConfig
COPY --from=fetcher /Lockdown /var/www/html/extensions/Lockdown
COPY --from=fetcher /Nuke /var/www/html/extensions/Nuke
COPY --from=fetcher /TwitterWidget /var/www/html/extensions/TwitterWidget
COPY --from=fetcher /YouTube /var/www/html/extensions/YouTube
COPY --from=fetcher /Slides /var/www/html/extensions/Slides
COPY --from=fetcher /ExternalContent /var/www/html/extensions/ExternalContent
COPY --from=fetcher /Plausible /var/www/html/extensions/Plausible
COPY --from=fetcher /Shibboleth /var/www/html/extensions/Shibboleth
COPY --from=fetcher /PluggableAuth /var/www/html/extensions/PluggableAuth
COPY --from=fetcher /OpenIDConnect /var/www/html/extensions/OpenIDConnect
COPY --from=fetcher /MatomoAnalytics /var/www/html/extensions/MatomoAnalytics

# extensions usd in wmflabs
# lct.wmflabs.org
COPY --from=fetcher /Popups /var/www/html/extensions/Popups
#drmf-beta.wmflabs.org
COPY --from=fetcher /DataTransfer /var/www/html/extensions/DataTransfer
#wiki.physikerwelt.de
COPY --from=fetcher /SemanticDrilldown /var/www/html/extensions/SemanticDrilldown


################
#  composer    #
################
#FROM composer@sha256:d374b2e1f715621e9d9929575d6b35b11cf4a6dc237d4a08f2e6d1611f534675 as composer
FROM composer:1 as composer
COPY --from=collector /var/www/html /var/www/html
WORKDIR /var/www/html/
COPY composer.local.json /var/www/html/composer.local.json
# remove ext-calendar requirement, causing composer install to fail
# composer only checks if requirements are met, but does not install or
# actually depend on ext-calendar.
# ext-calendar is installed in the final stage via docker-php-ext-install
RUN sed -i '/ext-calendar/d' composer.json
RUN rm -f /var/www/html/composer.lock

# installing the php intl extension on linux alpine (req. for running composer install)
RUN set -xe \
    && apk add --update icu \
    && apk add --no-cache --virtual .php-deps make \
    && apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        zlib-dev \
        icu-dev \
        g++ \
        freetype-dev \
        libpng-dev \
        jpeg-dev \
        libjpeg-turbo-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && docker-php-ext-enable intl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd \
    && docker-php-ext-enable gd \
    && { find /usr/local/lib -type f -print0 | xargs -0r strip --strip-all -p 2>/dev/null || true; } \
    && apk del .build-deps \
    && rm -rf /tmp/* /usr/local/lib/php/doc/* /var/cache/apk/*
# rather than ignoring plattform devs one should use the mediawiki as a base image an copy composer via
# COPY --from=composer:1 /usr/bin/composer /usr/bin/composer
# See section PHP version & extensions on https://hub.docker.com/_/composer
RUN composer install --no-dev --ignore-platform-reqs


#######################################
#            MaRDI wikibase           #
# build from official mediawiki image #
#######################################
FROM mediawiki:${MEDIAWIKI_VERSION}

# PRETTY_NAME="Debian GNU/Linux 11 (bullseye)"
# NAME="Debian GNU/Linux"
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive\
    apt-get install --yes --no-install-recommends \
    nano jq=1.* libbz2-dev=1.* gettext-base npm grunt cron vim librsvg2-bin libapache2-mod-shib && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite

RUN install -d /var/log/mediawiki -o www-data
RUN docker-php-ext-install calendar bz2

COPY --from=composer /var/www/html /var/www/html
COPY wait-for-it.sh /wait-for-it.sh
RUN chmod +x /wait-for-it.sh
COPY entrypoint.sh /entrypoint.sh
COPY LocalSettings.php.template /LocalSettings.php.template
COPY htaccess /var/www/html/.htaccess
RUN ln -s /var/www/html/ /var/www/html/w
ENV MW_SITE_NAME=wikibase-docker\
    MW_SITE_LANG=en

COPY LocalSettings.php.wikibase-bundle.template /LocalSettings.php.wikibase-bundle.template
COPY LocalSettings.php.mardi.template /LocalSettings.php.mardi.template
COPY extra-install.sh /
COPY extra-entrypoint-run-first.sh /
RUN cat /LocalSettings.php.wikibase-bundle.template >> /LocalSettings.php.template && rm /LocalSettings.php.wikibase-bundle.template
RUN cat /LocalSettings.php.mardi.template >> /LocalSettings.php.template && rm /LocalSettings.php.mardi.template
COPY oauth.ini /templates/oauth.ini
RUN mkdir /shared

# Setup regular maintenance cron in MediaWiki container.
COPY regular_maintenance.sh /var/www/html/regular_maintenance.sh
RUN chmod ugo+rwx /var/www/html/regular_maintenance.sh
RUN echo "* */1 * * *      root   /var/www/html/regular_maintenance.sh > /var/www/html/regular_maintenance.log"  \
    >> /etc/cron.d/Regular_maintenance

# set ownership of the uploaded images directory
RUN chown www-data:www-data /var/www/html/images

# copy shibboleth apache config
COPY shib_mod.conf /etc/apache2/conf-available
RUN a2enconf shib_mod

#########################
# Set up vecollabpad    #
#########################
RUN cd /var/www/html/extensions/VisualEditor/lib/ve && npm install && grunt build
RUN cd /var/www/html/extensions/VisualEditor/lib/ve/rebaser && npm install && cp config.dev.yaml config.yaml && sed -i 's/localhost/mongodb/g' config.yaml

##
ENTRYPOINT ["/bin/bash"]
CMD ["/entrypoint.sh"]
