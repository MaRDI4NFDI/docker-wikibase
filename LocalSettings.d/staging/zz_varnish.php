<?php

$wgUseCdn = true;
$wgCdnServers = [ '10.217.0.0/16' ];
$wgInternalServer = str_replace('https://', 'http://', $wgServer);
$wgCdnMaxAge = 18000; // 5 hours (default)
$wgCdnMaxageLagged = 18000; // MediaWiki incorrectly detects lagged database due to Galera cluster architecture.
$wgUseFileCache=false;