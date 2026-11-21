<?php

## OAuth Extension
wfLoadExtension( 'OAuth' );
$wgGroupPermissions['sysop']['mwoauthproposeconsumer'] = true;
$wgGroupPermissions['sysop']['mwoauthmanageconsumer'] = true;
$wgGroupPermissions['sysop']['mwoauthviewprivate'] = true;
$wgGroupPermissions['sysop']['mwoauthupdateownconsumer'] = true;
# Lets members register owner-only consumers, e.g. for scripts.
$wgGroupPermissions['institution-member']['mwoauthproposeconsumer'] = true;

$wgOAuth2PrivateKey = "/var/oauth/oauth.key";
$wgOAuth2PublicKey = "/var/oauth/oauth.cert";

$wgMWOAuthSharedUserIDs = true;
$wgMWOAuthSharedUserSource = 'local';
