<?php

## OAuth Extension
wfLoadExtension( 'OAuth' );
$wgGroupPermissions['sysop']['mwoauthproposeconsumer'] = true;
$wgGroupPermissions['sysop']['mwoauthmanageconsumer'] = true;
$wgGroupPermissions['sysop']['mwoauthviewprivate'] = true;
$wgGroupPermissions['sysop']['mwoauthupdateownconsumer'] = true;

$wgOAuth2PrivateKey = "/var/oauth/oauth.key";
$wgOAuth2PublicKey = "/var/oauth/oauth.cert";
