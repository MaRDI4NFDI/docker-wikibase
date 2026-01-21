ARG WB_IMAGE=ghcr.io/mardi4nfdi/wikibase-production:latest
ARG APACHE_IMAGE=hcr.io/mardi4nfdi/apache:latest

FROM ${APACHE_IMAGE}
COPY --from=${WB_IMAGE} /var/www/html/w /var/www/html/w