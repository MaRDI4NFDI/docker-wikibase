FROM wikibase-local
RUN apt-get update && \
    apt-get install -y --no-install-recommends git zip libzip-dev
RUN docker-php-ext-install zip
COPY --from=composer:1.9.3 /usr/bin/composer /usr/local/bin/composer
RUN pecl install xdebug
RUN docker-php-ext-enable xdebug
RUN touch /tmp/xdebug.log
RUN chmod ugo+rw  /tmp/xdebug.log
ENTRYPOINT ["/bin/bash"]
CMD ["/entrypoint.sh"]
