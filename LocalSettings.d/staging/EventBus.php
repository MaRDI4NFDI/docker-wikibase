<?php 

wfLoadExtension( 'EventBus' );

use MediaWiki\Extension\EventBus\Adapters\RCFeed\EventBusRCFeedEngine;
use MediaWiki\Extension\EventBus\Adapters\RCFeed\EventBusRCFeedFormatter;

$wgEventServices = [
    'eventbus' => [
        'url' => 'http://eventgate/v1/events',
        'timeout' => 5,
    ],
];

$wgEnableEventBus = "TYPE_ALL";
$wgEventServiceDefault = 'eventbus';

$wgRCFeeds['eventbus'] = [
    'class'            => EventBusRCFeedEngine::class,
    'formatter'        => EventBusRCFeedFormatter::class,
    'eventServiceName' => 'eventbus',
];

$wgEventBusStreamNamesMap = [
    'page-change' => 'mediawiki.page_change.v1',
];

$wgConf->suffixes = [ '' ];
$wgConf->wikis = $wgLocalDatabases;
$wgConf->settings = [
    'wgCanonicalServer' => [
        'my_wiki' => 'https://staging.mardi4nfdi.org',
    ],
    'wgArticlePath' => [
        'my_wiki' => $wgArticlePath,
    ],
];
