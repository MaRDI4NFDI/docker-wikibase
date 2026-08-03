<?php
# Load the deployment-tier settings from LocalSettings.d/$DEPLOYMENT_ENV/ (staging/, prod/).
#
# LocalSettings.php includes LocalSettings.d/*.php in glob() order, which is
# alphabetical. This file is named so that it sorts after every other file in
# that directory, which makes the environment-specific settings true overrides
# of the global baseline (Wikibase.php, swmath.php, ...) rather than being
# silently overwritten by it.

$deployment_env = getenv( 'DEPLOYMENT_ENV' );
if ( $deployment_env && is_dir( "/var/www/html/w/LocalSettings.d/$deployment_env" ) ) {
	foreach ( glob( "/var/www/html/w/LocalSettings.d/$deployment_env/*.php" ) as $deployment_env_file ) {
		include $deployment_env_file;
	}
} else {
	wfDebug( "DEPLOYMENT_ENV not specified or directory does not exist, skipping environment-specific settings." );
}
