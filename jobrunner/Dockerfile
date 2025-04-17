ARG BASE_IMAGE=ghcr.io/mardi4nfdi/docker-wikibase:main
FROM ${BASE_IMAGE}
# cf https://github.com/mlocati/docker-php-extension-installer
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions pcntl sockets gd zip redis
COPY --from=composer /usr/bin/composer /usr/local/bin/composer
RUN git clone --depth=1 https://github.com/wikimedia/mediawiki-services-jobrunner.git /jobrunner
WORKDIR /jobrunner
RUN composer install --no-dev
COPY ./config.json /jobrunner/config.json
HEALTHCHECK NONE
