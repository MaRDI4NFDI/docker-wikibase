FROM alpine:latest

ENV BACKUP_DEFAULT_GID="9000" \
	BACKUP_DEFAULT_UID="9000" \
	TIMEZONE="CET" \
	DEFAULT_SCHEDULE="0 1 * * *" \
	CRONTAB="/var/spool/cron/crontabs/backup"

VOLUME /data

RUN apk add --update \
		bash \
		gzip \
		# mailx \
		mysql-client \
		# openssh \
		# shadow \
		# ssmtp \
		# su-exec \
		tzdata \
		nano \
	&& rm -rf /var/cache/apk/*

# Set up non-root user.
RUN addgroup -g "$DEFAULT_GID" backup \
	&& adduser \
		-h "/home/backup" \
		-D `# Don't assign a password` \
		-u "$DEFAULT_UID" \
		-s "/bin/bash" \
		-G "backup" \
		backup

# Copy files.
RUN mkdir /app
COPY mysql_backup.sh /app/
COPY wrapper.sh /app/
COPY start.sh /app/

# Set up entry point.
WORKDIR /app
ENTRYPOINT ["/app/start.sh"]
