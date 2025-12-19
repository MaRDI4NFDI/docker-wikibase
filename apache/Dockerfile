FROM httpd:2.4

RUN apt-get update && \
    apt-get install --yes --no-install-recommends curl gettext-base && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html/w

# Enable required modules
RUN sed -i \
    -e 's/^#LoadModule proxy_module/LoadModule proxy_module/' \
    -e 's/^#LoadModule proxy_fcgi_module/LoadModule proxy_fcgi_module/' \
    -e 's/^#LoadModule rewrite_module/LoadModule rewrite_module/' \
    -e 's/^#LoadModule remoteip_module/LoadModule remoteip_module/' \
    /usr/local/apache2/conf/httpd.conf

# Use real client IP in logs (from X-Forwarded-For)
RUN sed -i 's/%h/%a/g' /usr/local/apache2/conf/httpd.conf

RUN echo "Include conf/extra/remoteip.conf" >> /usr/local/apache2/conf/httpd.conf
RUN echo "Include conf/extra/mediawiki.conf" >> /usr/local/apache2/conf/httpd.conf

COPY remoteip.conf /usr/local/apache2/conf/extra/remoteip.conf
COPY mediawiki.conf.template /usr/local/apache2/conf/extra/mediawiki.conf.template

ENV WIKIBASE_HOST=wikibase

CMD ["sh", "-c", "envsubst '${WIKIBASE_HOST}' < /usr/local/apache2/conf/extra/mediawiki.conf.template > /usr/local/apache2/conf/extra/mediawiki.conf && httpd-foreground"]

HEALTHCHECK CMD curl -f http://localhost/ || exit 1