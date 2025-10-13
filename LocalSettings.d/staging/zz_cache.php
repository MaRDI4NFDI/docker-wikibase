<?php

$wgMainCacheType = CACHE_MEMCACHED;
$wgMemCachedServers = [ 
    (getenv('MW_MEMCACHED_HOST') ?: 'memcached') . ':' . (getenv('MW_MEMCACHED_PORT') ?: '11211')
];