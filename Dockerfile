######################
#   Global settings  #
######################
ARG MEDIAWIKI_VERSION=lts
ARG WMF_BRANCH=wmf/1.44.0-wmf.18
ARG REL_BRANCH=REL1_43

################
#   Fetcher    #
################
FROM ubuntu:xenial AS fetcher

RUN apt-get update && \
    apt-get install --yes --no-install-recommends git=1:2.* ssh unzip=6.* jq=1.* curl=7.* ca-certificates=201* patch && \
    apt-get install --reinstall ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# make global settings known in this build stage
ARG WMF_BRANCH
ARG REL_BRANCH

# clone extensions from github, using specific branch
COPY clone-extension.sh .

RUN \
bash clone-extension.sh AdvancedSearch ${WMF_BRANCH};\
bash clone-extension.sh ArticlePlaceholder ${WMF_BRANCH};\
bash clone-extension.sh Babel ${WMF_BRANCH};\
bash clone-extension.sh cldr ${WMF_BRANCH};\
bash clone-extension.sh CirrusSearch ${WMF_BRANCH};\
bash clone-extension.sh Cite ${WMF_BRANCH};\
bash clone-extension.sh CiteThisPage ${WMF_BRANCH};\
bash clone-extension.sh CodeEditor ${WMF_BRANCH};\
bash clone-extension.sh CodeMirror ${WMF_BRANCH};\
bash clone-extension.sh ConfirmEdit ${WMF_BRANCH};\
bash clone-extension.sh DataTransfer ${REL_BRANCH};\
bash clone-extension.sh DisplayTitle ${REL_BRANCH};\
bash clone-extension.sh Echo ${WMF_BRANCH};\
bash clone-extension.sh Elastica ${WMF_BRANCH};\
bash clone-extension.sh EntitySchema ${WMF_BRANCH};\
bash clone-extension.sh ExternalData ${REL_BRANCH};\
bash clone-extension.sh Gadgets ${WMF_BRANCH};\
bash clone-extension.sh Graph ${WMF_BRANCH};\
bash clone-extension.sh InputBox ${WMF_BRANCH};\
bash clone-extension.sh JsonConfig ${WMF_BRANCH};\
bash clone-extension.sh LinkedWiki master;\
bash clone-extension.sh Lockdown ${REL_BRANCH};\
bash clone-extension.sh Math master;\
bash clone-extension.sh MathSearch master;\
bash clone-extension.sh MultimediaViewer ${WMF_BRANCH};\
bash clone-extension.sh Nuke ${WMF_BRANCH};\
bash clone-extension.sh OAuth ${WMF_BRANCH};\
bash clone-extension.sh OpenIDConnect ${REL_BRANCH};\
bash clone-extension.sh PageForms ${REL_BRANCH};\
bash clone-extension.sh PageImages ${WMF_BRANCH};\
bash clone-extension.sh ParserFunctions ${WMF_BRANCH};\
bash clone-extension.sh PdfHandler ${WMF_BRANCH};\
bash clone-extension.sh PluggableAuth ${REL_BRANCH};\
bash clone-extension.sh Popups ${WMF_BRANCH};\
bash clone-extension.sh ReplaceText ${REL_BRANCH};\
bash clone-extension.sh Scribunto ${WMF_BRANCH};\
bash clone-extension.sh SyntaxHighlight_GeSHi ${WMF_BRANCH};\
bash clone-extension.sh TemplateStyles ${WMF_BRANCH};\
bash clone-extension.sh TextExtracts ${WMF_BRANCH};\
bash clone-extension.sh TimedMediaHandler ${WMF_BRANCH};\
bash clone-extension.sh Thanks ${WMF_BRANCH};\
bash clone-extension.sh UniversalLanguageSelector ${WMF_BRANCH};\
bash clone-extension.sh UserMerge ${REL_BRANCH};\
bash clone-extension.sh UrlGetParameters ${REL_BRANCH};\
bash clone-extension.sh VisualEditor ${WMF_BRANCH};\
bash clone-extension.sh Widgets ${REL_BRANCH};\
# bash clone-extension.sh Wikibase ${WMF_BRANCH};\
bash clone-extension.sh WikibaseCirrusSearch ${WMF_BRANCH};\
bash clone-extension.sh WikibaseLexeme ${WMF_BRANCH};\
bash clone-extension.sh WikibaseManifest ${REL_BRANCH};\
bash clone-extension.sh WikibaseQualityConstraints ${WMF_BRANCH};\
bash clone-extension.sh WikiEditor ${WMF_BRANCH};\
bash clone-extension.sh YouTube ${REL_BRANCH};\
echo 'finished cloning'

##Patch Wikibase
# cf. https://github.com/wmde/wikibase-release-pipeline/pull/753/files
# WORKAROUND for https://phabricator.wikimedia.org/T372458
# Take wikibase submodules from github as phabricator rate limits us
COPY --chown=nobody:nogroup --chmod=755 \
  wikibase-submodules-from-github-instead-of-phabricator.patch \
  /tmp/wikibase-submodules-from-github-instead-of-phabricator.patch
RUN git clone --depth=1 https://github.com/wikimedia/mediawiki-extensions-Wikibase.git --single-branch -b ${WMF_BRANCH} Wikibase && \
    patch -d Wikibase -Np1 </tmp/wikibase-submodules-from-github-instead-of-phabricator.patch && \
    rm /tmp/wikibase-submodules-from-github-instead-of-phabricator.patch && \
    git -C Wikibase submodule update --init --recursive    

# clone extensions not officially distributed by mediawiki
RUN git clone --depth=1 https://github.com/ProfessionalWiki/WikibaseLocalMedia.git WikibaseLocalMedia &&\
rm -rf WikibaseLocalMedia/.git

RUN git clone --depth=1 https://github.com/ProfessionalWiki/WikibaseExport.git WikibaseExport &&\
rm -rf WikibaseExport/.git

RUN git clone --depth=1 https://github.com/ProfessionalWiki/ExternalContent.git ExternalContent &&\
rm -rf ExternalContent/.git

RUN git clone --depth=1 https://github.com/ProfessionalWiki/SPARQL.git SPARQL &&\
rm -rf SPARQL/.git

RUN git clone --depth=1 https://github.com/ProfessionalWiki/WikibaseFacetedSearch.git WikibaseFacetedSearch

RUN git clone --depth=1 https://github.com/MaRDI4NFDI/MatomoAnalytics.git MatomoAnalytics &&\
rm -rf MatomoAnalytics/.git

RUN git clone --depth=1 https://github.com/SemanticMediaWiki/SemanticMediaWiki.git SemanticMediaWiki &&\
rm -rf SemanticMediaWiki.git

RUN git clone --depth=1 https://github.com/MaRDI4NFDI/SemanticDrilldown.git SemanticDrilldown &&\
rm -rf SemanticDrilldown/.git

# clone core
RUN git clone --depth=1 https://github.com/wikimedia/mediawiki -b ${WMF_BRANCH} &&\
rm -rf mediawiki/.git

# Clone Vector Skin (not included in the mediawiki repository)
RUN git clone --depth=1 https://github.com/wikimedia/mediawiki-skins-Vector -b ${WMF_BRANCH} Vector &&\
rm -rf Vector/.git

# other skins
RUN git clone --depth=1 https://github.com/ProfessionalWiki/chameleon chameleon &&\
rm -rf chameleon/.git

RUN git clone --depth=1 https://github.com/ProfessionalWiki/MardiSkin MardiSkin &&\
rm -rf MardiSkin/.git






################
#  Collector   #
################
FROM mediawiki:${MEDIAWIKI_VERSION} AS collector

RUN rm -rf /var/www/html/*

COPY --from=fetcher /mediawiki /var/www/html


COPY --from=fetcher /AdvancedSearch /var/www/html/extensions/AdvancedSearch
COPY --from=fetcher /ArticlePlaceholder /var/www/html/extensions/ArticlePlaceholder
COPY --from=fetcher /Babel /var/www/html/extensions/Babel
COPY --from=fetcher /cldr /var/www/html/extensions/cldr
COPY --from=fetcher /CirrusSearch /var/www/html/extensions/CirrusSearch
COPY --from=fetcher /Cite /var/www/html/extensions/Cite
COPY --from=fetcher /CiteThisPage /var/www/html/extensions/CiteThisPage
COPY --from=fetcher /CodeEditor /var/www/html/extensions/CodeEditor
COPY --from=fetcher /CodeMirror /var/www/html/extensions/CodeMirror
COPY --from=fetcher /ConfirmEdit /var/www/html/extensions/ConfirmEdit
COPY --from=fetcher /DisplayTitle /var/www/html/extensions/DisplayTitle
COPY --from=fetcher /Echo /var/www/html/extensions/Echo
COPY --from=fetcher /Elastica /var/www/html/extensions/Elastica
COPY --from=fetcher /EntitySchema /var/www/html/extensions/EntitySchema
COPY --from=fetcher /ExternalContent /var/www/html/extensions/ExternalContent
COPY --from=fetcher /ExternalData /var/www/html/extensions/ExternalData
COPY --from=fetcher /Gadgets /var/www/html/extensions/Gadgets
COPY --from=fetcher /Graph /var/www/html/extensions/Graph
COPY --from=fetcher /InputBox /var/www/html/extensions/InputBox
COPY --from=fetcher /JsonConfig /var/www/html/extensions/JsonConfig
COPY --from=fetcher /LinkedWiki /var/www/html/extensions/LinkedWiki
COPY --from=fetcher /Lockdown /var/www/html/extensions/Lockdown
COPY --from=fetcher /Math /var/www/html/extensions/Math
COPY --from=fetcher /MathSearch /var/www/html/extensions/MathSearch
COPY --from=fetcher /MatomoAnalytics /var/www/html/extensions/MatomoAnalytics
COPY --from=fetcher /MultimediaViewer /var/www/html/extensions/MultimediaViewer
COPY --from=fetcher /Nuke /var/www/html/extensions/Nuke
COPY --from=fetcher /OAuth /var/www/html/extensions/OAuth
COPY --from=fetcher /OpenIDConnect /var/www/html/extensions/OpenIDConnect
COPY --from=fetcher /PageForms /var/www/html/extensions/PageForms
COPY --from=fetcher /PageImages /var/www/html/extensions/PageImages
COPY --from=fetcher /ParserFunctions /var/www/html/extensions/ParserFunctions
COPY --from=fetcher /PdfHandler /var/www/html/extensions/PdfHandler
COPY --from=fetcher /PluggableAuth /var/www/html/extensions/PluggableAuth
COPY --from=fetcher /ReplaceText /var/www/html/extensions/ReplaceText
COPY --from=fetcher /SemanticMediaWiki /var/www/html/extensions/SemanticMediaWiki
COPY --from=fetcher /Scribunto /var/www/html/extensions/Scribunto
COPY --from=fetcher /SyntaxHighlight_GeSHi /var/www/html/extensions/SyntaxHighlight_GeSHi
COPY --from=fetcher /SPARQL /var/www/html/extensions/SPARQL
COPY --from=fetcher /TemplateStyles /var/www/html/extensions/TemplateStyles
COPY --from=fetcher /TextExtracts /var/www/html/extensions/TextExtracts
COPY --from=fetcher /TimedMediaHandler /var/www/html/extensions/TimedMediaHandler
COPY --from=fetcher /Thanks /var/www/html/extensions/Thanks
COPY --from=fetcher /UniversalLanguageSelector /var/www/html/extensions/UniversalLanguageSelector
COPY --from=fetcher /UrlGetParameters /var/www/html/extensions/UrlGetParameters
COPY --from=fetcher /UserMerge /var/www/html/extensions/UserMerge
COPY --from=fetcher /VisualEditor /var/www/html/extensions/VisualEditor
COPY --from=fetcher /Widgets /var/www/html/extensions/Widgets
COPY --from=fetcher /Wikibase /var/www/html/extensions/Wikibase
COPY --from=fetcher /WikibaseCirrusSearch /var/www/html/extensions/WikibaseCirrusSearch
COPY --from=fetcher /WikibaseExport /var/www/html/extensions/WikibaseExport
COPY --from=fetcher /WikibaseFacetedSearch /var/www/html/extensions/WikibaseFacetedSearch
COPY --from=fetcher /WikibaseLexeme /var/www/html/extensions/WikibaseLexeme
COPY --from=fetcher /WikibaseLocalMedia /var/www/html/extensions/WikibaseLocalMedia
COPY --from=fetcher /WikibaseManifest /var/www/html/extensions/WikibaseManifest
COPY --from=fetcher /WikibaseQualityConstraints /var/www/html/extensions/WikibaseQualityConstraints
COPY --from=fetcher /WikiEditor /var/www/html/extensions/WikiEditor
COPY --from=fetcher /YouTube /var/www/html/extensions/YouTube


# extensions used in wmflabs
# lct.wmflabs.org
COPY --from=fetcher /Popups /var/www/html/extensions/Popups
# drmf-beta.wmflabs.org
COPY --from=fetcher /DataTransfer /var/www/html/extensions/DataTransfer
# wiki.physikerwelt.de
COPY --from=fetcher /SemanticDrilldown /var/www/html/extensions/SemanticDrilldown

# collect Vector Skin
COPY --from=fetcher /Vector /var/www/html/skins/Vector
# other Skins
COPY --from=fetcher /chameleon /var/www/html/skins/chameleon
COPY --from=fetcher /MardiSkin /var/www/html/skins/MardiSkin


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
COPY --from=collector /var/www/html /var/www/html
WORKDIR /var/www/html/
COPY composer.local.json /var/www/html/composer.local.json
  
COPY --from=composer /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-dev


#######################################
#            MaRDI wikibase           #
# Build from official mediawiki image #
#######################################
FROM mediawiki:${MEDIAWIKI_VERSION}

WORKDIR /var/www/html/w/

# PRETTY_NAME="Debian GNU/Linux 11 (bullseye)"
# NAME="Debian GNU/Linux"
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive\
    apt-get install --yes --no-install-recommends \
    nano jq=1.* libbz2-dev=1.* gettext-base npm grunt cron vim librsvg2-bin libpq-dev libyaml-dev \
    lua5.1 liblua5.1-0-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite

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
COPY htaccess /var/www/html/.htaccess
COPY images /var/www/html/w/images_repo/
ENV MW_SITE_NAME=wikibase-docker\
    MW_SITE_LANG=en

COPY LocalSettings.php.mardi.template /LocalSettings.php.mardi.template
COPY extra-install.sh /
COPY extra-entrypoint-run-first.sh /
RUN cat /LocalSettings.php.mardi.template >> /LocalSettings.php.template && rm /LocalSettings.php.mardi.template
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

# Copy shibboleth apache config
# COPY shib_mod.conf /etc/apache2/conf-available
# COPY shibboleth2.xml /etc/shibboleth/shibboleth2.xml
#Test creating default location for shibboleth socket file
# RUN mkdir /var/run/shibboleth
# Enable mod shibboleth and generate self signed keys 
# RUN shib-keygen && a2enconf shib_mod

# Set up vecollabpad
RUN cd /var/www/html/w/extensions/VisualEditor/lib/ve && npm install && grunt build
RUN cd /var/www/html/w/extensions/VisualEditor/lib/ve/rebaser && npm install && cp config.dev.yaml config.yaml && sed -i 's/localhost/mongodb/g' config.yaml

# Install node modules for LinkedWiki
RUN cd /var/www/html/w/extensions/LinkedWiki && npm install
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN printf '[PHP]\ndate.timezone = "Europe/Berlin"\n' > /usr/local/etc/php/conf.d/tzone.ini

##
ENTRYPOINT ["/bin/bash"]
CMD ["/entrypoint.sh"]
HEALTHCHECK CMD curl -f http://localhost/ || exit 1
