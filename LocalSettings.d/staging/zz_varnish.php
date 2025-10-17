<?php

$wgUseCdn = true;
$wgCdnServers = [ '10.217.0.0/16' ];
$wgInternalServer = str_replace('https://', 'http://', $wgServer);
$wgUseFileCache=false;