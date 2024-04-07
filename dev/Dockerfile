FROM ghcr.io/mardi4nfdi/docker-wikibase:main
RUN apt-get update && \
    apt-get install -y --no-install-recommends git zip libzip-dev zlib1g-dev libpng-dev
RUN docker-php-ext-install zip
RUN docker-php-ext-install gd
COPY --from=composer /usr/bin/composer /usr/local/bin/composer
RUN pecl install xdebug-3.1.3
RUN docker-php-ext-enable xdebug
# Obsolete lines can be removed if all testing successful.
# RUN pecl install xhprof-2.2.0 && docker-php-ext-enable xhprof
# RUN pecl install ast-1.0.6 && docker-php-ext-enable ast
# RUN echo "xdebug.remote_enable=1" >> /usr/local/etc/php/php.ini
# RUN echo "xdebug.profiler_enable=1" >> /usr/local/etc/php/php.ini
RUN touch /tmp/xdebug.log
RUN chmod ugo+rw  /tmp/xdebug.log
# ENTRYPOINT ["docker-php-entrypoint", "apache2-foreground"]
ENTRYPOINT ["/bin/bash"]
CMD ["/entrypoint.sh"]
