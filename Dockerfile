FROM php:7.4-cli

# some defaults
ENV BACKUP_DEFAULT_GID="9000" \
	BACKUP_DEFAULT_UID="9000" \
	TIMEZONE="CET" \
	DEFAULT_SCHEDULE="0 1 * * *" \
	CRONTAB="/var/spool/cron/crontabs/backup"

VOLUME /data

# install php-mysql driver and mysqldump and intl deps.
RUN docker-php-ext-install mysqli \
&& apt-get update && apt-get install --yes --no-install-recommends default-mysql-client libicu-dev
RUN docker-php-ext-install intl

# install cron and utilities
RUN apt-get update && apt-get install --yes --no-install-recommends \
		cron \
		bash \
		gzip \
		tzdata \
		nano \
        vim \
	&& rm -rf /var/cache/apk/*
    

# Set up non-root user.
# RUN addgroup -g "$BACKUP_DEFAULT_GID" backup \BACKUP_DEFAULT_GID
RUN adduser \
		-h "/home/backup" \
		-D `# Don't assign a password` \
		-u "$BACKUP_DEFAULT_UID" \
		-s "/bin/bash" \
		-G "backup" \
		backup

# Copy files.
RUN mkdir /app
COPY backup.sh /app/
COPY restore.sh /app/
COPY start.sh /app/

# Make sure scripts are executable
RUN chown backup:backup /app/*.sh && chmod 774 /app/*.sh
COPY --from=ghcr.io/mardi4nfdi/docker-wikibase:main /var/www/html/ /var/www/html/

# Set up entry point.
WORKDIR /app
