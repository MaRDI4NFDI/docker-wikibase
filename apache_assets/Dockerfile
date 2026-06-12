FROM wikibase-local AS wb_stage
FROM apache-local
COPY --from=wb_stage /var/www/html/w /var/www/html/w
COPY googlef56dee9892c586e7.html /var/www/html/googlef56dee9892c586e7.html
COPY robots.txt /var/www/html/robots.txt