ARG BASE_IMAGE=ghcr.io/mardi4nfdi/wikibase-staging:latest
FROM ${BASE_IMAGE}
# cf https://github.com/mlocati/docker-php-extension-installer
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions pcntl sockets gd zip redis
COPY --from=composer /usr/bin/composer /usr/local/bin/composer
RUN apt-get update && apt-get install -y unzip git && rm -rf /var/lib/apt/lists/*
RUN git clone --depth=1 https://github.com/wikimedia/mediawiki-services-jobrunner.git /jobrunner
WORKDIR /jobrunner
RUN composer remove wikimedia/ip-set --no-update && \
    composer require wikimedia/ip-utils:^5.0 --no-update && \
    composer update --no-dev --prefer-dist
COPY ./config.json /jobrunner/config.json
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
HEALTHCHECK NONE
ENTRYPOINT ["/entrypoint.sh"]
CMD []