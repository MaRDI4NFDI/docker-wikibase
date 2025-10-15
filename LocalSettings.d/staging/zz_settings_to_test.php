<?php
$wgGroupPermissions['*']['autocreateaccount'] = true;
$wgGroupPermissions['user']['renameuser'] = true;
$wgDebugLogFile='/var/log/mediawiki/mwlog.txt';
$wgDebugLogGroups['OpenIDConnect'] = array(
	'destination' => '/var/log/mediawiki/OpenIDConnect.log',
	'level' => 'debug',
);
$wgDebugLogGroups['PluggableAuth'] = array(
	'destination' => '/var/log/mediawiki/OpenIDConnect.log',
	'level' => 'debug',
);
$wgDebugLogGroups['rdbms'] = array(
	'destination' => '/var/log/mediawiki/other.log',
	'level' => 'error',
);
$wgDebugLogGroups['objectcache'] = array(
	'destination' => '/var/log/mediawiki/other.log',
	'level' => 'error',
);
$wgDebugLogGroups['DeferredUpdates'] = array(
	'destination' => '/var/log/mediawiki/other.log',
	'level' => 'error',
);

