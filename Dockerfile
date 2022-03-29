################
#   fetcher    #
################
FROM ubuntu:xenial as fetcher

RUN apt-get update && \
    apt-get install --yes --no-install-recommends git=1:2.* ssh unzip=6.* jq=1.* curl=7.* ca-certificates=201* && \
    apt-get install --reinstall ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# clone extensions from github, using specific branch

ENV BRANCH=REL1_35

COPY clone-extension.sh .

RUN bash clone-extension.sh OAuth ${BRANCH};\
bash clone-extension.sh Elastica ${BRANCH};\
bash clone-extension.sh CirrusSearch ${BRANCH};\
bash clone-extension.sh WikibaseCirrusSearch ${BRANCH};\
bash clone-extension.sh UniversalLanguageSelector ${BRANCH};\
bash clone-extension.sh cldr ${BRANCH};\
bash clone-extension.sh EntitySchema ${BRANCH};\
bash clone-extension.sh Babel ${BRANCH};\
bash clone-extension.sh ConfirmEdit ${BRANCH};\
bash clone-extension.sh Scribunto ${BRANCH};\
bash clone-extension.sh VisualEditor ${BRANCH};\
bash clone-extension.sh WikibaseManifest ${BRANCH};\
bash clone-extension.sh Wikibase ${BRANCH};\
bash clone-extension.sh TemplateStyles ${BRANCH};\
bash clone-extension.sh JsonConfig ${BRANCH};\
bash clone-extension.sh Lockdown ${BRANCH};\
bash clone-extension.sh Nuke ${BRANCH};\
bash clone-extension.sh Math ${BRANCH};\
bash clone-extension.sh MathSearch ${BRANCH};

# clone extensions not officially distributed by mediawiki
RUN git clone https://github.com/ProfessionalWiki/WikibaseLocalMedia.git -b ${BRANCH} WikibaseLocalMedia &&\
rm -rf WikibaseLocalMedia/.git

RUN git clone https://github.com/ciencia/mediawiki-extensions-TwitterWidget.git TwitterWidget &&\
rm -rf TwitterWidget/.git

RUN git clone https://gitlab.com/hydrawiki/extensions/EmbedVideo.git EmbedVideo &&\
rm -rf EmbedVideo/.git

# clone WikibaseImport from the mardi fork (no branch needed here, as extension is custom made for the portal)
RUN git clone https://github.com/MaRDI4NFDI/WikibaseImport.git WikibaseImport &&\
rm -rf WikibaseImport/.git

# Download Medik skin and unpack
RUN curl https://bitbucket.org/wikiskripta/medik/get/master.tar.gz --output Medik.tar.gz &&\
tar -xf Medik.tar.gz &&\
rm Medik.tar.gz



################
#  collector   #
################
FROM mediawiki:1.35  as collector

# collect bundle extensions
COPY --from=fetcher /WikibaseImport /var/www/html/extensions/WikibaseImport
COPY --from=fetcher /Elastica /var/www/html/extensions/Elastica
COPY --from=fetcher /OAuth /var/www/html/extensions/OAuth
COPY --from=fetcher /CirrusSearch /var/www/html/extensions/CirrusSearch
COPY --from=fetcher /WikibaseCirrusSearch /var/www/html/extensions/WikibaseCirrusSearch
COPY --from=fetcher /UniversalLanguageSelector /var/www/html/extensions/UniversalLanguageSelector
COPY --from=fetcher /cldr /var/www/html/extensions/cldr
COPY --from=fetcher /EntitySchema /var/www/html/extensions/EntitySchema
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
COPY --from=fetcher /EmbedVideo /var/www/html/extensions/EmbedVideo

# collect skins
COPY --from=fetcher /wikiskripta-medik-* /var/www/html/skins/Medik


################
#  composer    #
################
#FROM composer@sha256:d374b2e1f715621e9d9929575d6b35b11cf4a6dc237d4a08f2e6d1611f534675 as composer
FROM composer:1 as composer
COPY --from=collector /var/www/html /var/www/html
WORKDIR /var/www/html/
COPY composer.local.json /var/www/html/composer.local.json
RUN rm -f /var/www/html/composer.lock
RUN composer install --no-dev


#######################################
#            MaRDI wikibase           #
# build from official mediawiki image #
#######################################
FROM mediawiki:1.35

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive\
    apt-get install --yes --no-install-recommends nano jq=1.* libbz2-dev=1.* gettext-base && \
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

ENTRYPOINT ["/bin/bash"]
CMD ["/entrypoint.sh"]
