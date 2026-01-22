ARG WB_IMAGE=ghcr.io/mardi4nfdi/wikibase-production:latest
ARG APACHE_IMAGE=ghcr.io/mardi4nfdi/apache:latest

FROM ${WB_IMAGE} AS wb_stage
FROM ${APACHE_IMAGE}
COPY --from=wb_stage /var/www/html/w /var/www/html/w