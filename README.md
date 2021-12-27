Docker image for backups
========================
A Docker image that runs backups on a regular basis.

* Creates a "backup" user and group
* Calls the backup script (./wrapper.sh) on a regular basis (BACKUP_SCHEDULE) using cron
* Puts backups as compressed files on the host (BACKUP_DIR)

To run a backup manually, do `docker exec -ti name-of-backup-container ./wrapper.sh`

Configuration
-------------

Example docker-compose configuration:

```
  backup:
    image: ghcr.io/mardi4nfdi/docker-backup:master
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
```

These must be set in .env:

BACKUP_DIR: Folder on the host where to put the backups. Folder ownership will be set to "backup:backup".

DB_NAME: name of the database to backup

DB_USER: username of the database username

DB_PASS: password of the database user

BACKUP_SCHEDULE: a cron string, e.g. '15 5 * * *' # every day at 05:15

To do
------
* Erase old backups
* Provide a function to restore backups
* Email out reports through ssmtp

License
-------
More or less based upon [AutoMySQLBackup](https://github.com/guillaumeaubert/automysqlbackup-docker) by Gillaume Aubert.

* The original version of AutoMySQLBackup (v3.0_rc6) is under the GPLv2
license. The modifications to `automysqlbackup` in this repository and
corresponding Docker image are accordingly released under the GPLv2 license.

* This software is released under the GPLv2 license. See the LICENSE file for
details.
