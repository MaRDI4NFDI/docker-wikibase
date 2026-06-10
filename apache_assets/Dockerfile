ARG WB_IMAGE=ghcr.io/mardi4nfdi/wikibase-production:latest
ARG APACHE_IMAGE=ghcr.io/mardi4nfdi/apache:latest

FROM ${WB_IMAGE} AS wb_stage
FROM ${APACHE_IMAGE}
COPY --from=wb_stage /var/www/html/w /var/www/html/w
COPY googlef56dee9892c586e7.html /var/www/html/googlef56dee9892c586e7.html
COPY robots.txt /var/www/html/robots.txt