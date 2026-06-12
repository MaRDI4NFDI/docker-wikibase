<?php

$wgUseCdn = getenv('USE_CDN') === 'true' ? true : false;

if ($wgUseCdn) {
    $cdnServer = getenv('CDN_SERVER') ?: 'varnish'; 
    $wgCdnServers = ['http://' . $cdnServer . ':80'];
    $cdnBackendHost = getenv('CDN_BACKEND_HOST') ?: 'wikibase';
    $wgInternalServer = 'http://' . $cdnBackendHost;
    $wgUsePrivateIPs = true; // Trust proxy headers from Varnish
}
