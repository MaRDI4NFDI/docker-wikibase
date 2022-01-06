Docker image for backups
========================
A Docker image that runs backups on a regular basis.

* Creates a "backup" user
* Calls the backup script (./wrapper.sh) on a regular basis (BACKUP_SCHEDULE) using cron
* Saves backups of database and pages (in XML format) as compressed files on the host (BACKUP_DIR)
* Deletes old backups (older than KEEP_DAYS)

To run a backup manually, do `docker exec -ti name-of-backup-container ./wrapper.sh`

Build
------
Build on local machine: `docker build -t ghcr.io/mardi4nfdi/docker-backup:main .`

Build on CI: image is tested and built automatically on push to main.

Configuration
-------------

Example docker-compose configuration:

```
  backup:
    image: ghcr.io/mardi4nfdi/docker-backup:main
    links:
      - mysql
    depends_on:
      - mysql
    restart: always
    volumes:
      - ${BACKUP_DIR}:/data
    environment:
      DB_HOST: mysql.svc # internal docker hostname (alias) of the database service
      DB_NAME: ${DB_NAME}
      DB_USER: ${DB_USER}
      DB_PASS: ${DB_PASS}
      BACKUP_SCHEDULE: ${BACKUP_SCHEDULE}
      KEEP_DAYS: 100
```

These must be set in .env:

BACKUP_DIR: Folder on the host where to put the backups. Folder ownership will be set to "backup:backup".

DB_NAME: name of the database to backup

DB_USER: username of the database username

DB_PASS: password of the database user

BACKUP_SCHEDULE: a cron string, e.g. '15 5 * * *' # every day at 05:15

KEEPD_DAYS: how many days shall the backups be kept, e.g. 100


Restoring a backup
-------------------
Open a shell to the backup container. In the /app dir, do:
* `bash ./restore.sh` to restore the database from the latest sql dump 
* `bash ./restore.sh -f portal_db_backup_xxxx.xx.xx_xx.xx.xx.gz` to restore a specific sql dump. Pass the name of the file, not the full path.
* `bash ./restore.sh -t sql -f portal_db_backup_xxxx.xx.xx_xx.xx.xx.gz` same as above


To do
------
* Email out reports through ssmtp
