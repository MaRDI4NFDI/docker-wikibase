#!/bin/bash

# Originally inspired by Brennen Bearnes jobrunner entrypoint
# https://gerrit.wikimedia.org/r/plugins/gitiles/releng/dev-images/+/refs/heads/master/common/jobrunner/entrypoint.sh

kill_runner() {
	kill "$PID" 2> /dev/null
}
trap kill_runner SIGTERM

while true; do
	if [ -e /shared/LocalSettings.php ]; then
		php maintenance/runJobs.php --wait --maxjobs="$MAX_JOBS" --conf /var/www/html/LocalSettings.php &
		PID=$!
		wait "$PID"
	else
		echo "LocalSettings.php not shared yet - waiting for 10 seconds."
		sleep 10
	fi
done