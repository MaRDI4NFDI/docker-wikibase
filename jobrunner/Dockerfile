FROM ghcr.io/mardi4nfdi/docker-wikibase:main
# cf https://github.com/mlocati/docker-php-extension-installer
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions pcntl sockets gd zip
COPY --from=composer /usr/bin/composer /usr/local/bin/composer
RUN git clone --depth=1 https://github.com/wikimedia/mediawiki-services-jobrunner.git /jobrunner
RUN composer install --no-dev
COPY ./config.json /jobrunner/config.json
ENTRYPOINT php /jobrunner/redisJobChronService --config-file=/jobrunner/config.json
