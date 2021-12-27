#!/bin/bash

# export AMB_REMOTE_EXEC="ssh -C $AMB_TARGET"

bash /app/mysql_backup.sh 2>&1 \
	| tee /data/mysqlbackup_docker.log # \
	# | mail -s "AutoMySQLBackup | $AMB_TARGET | `date +'%Y-%m-%d %r %Z'`" root
