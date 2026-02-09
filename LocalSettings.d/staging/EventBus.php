<?php 

wfLoadExtension( 'EventBus' );

use MediaWiki\Extension\EventBus\EventBus;
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

$wgEventBusStreamNamesMap = [
    'mediawiki.page_change' => 'mediawiki.page_change.v1',
    'mediawiki.revision_create' => 'mediawiki.revision-create.v1'
];

$wgRCFeeds['eventbus'] = [
    'class'            => EventBusRCFeedEngine::class,
    'formatter'        => EventBusRCFeedFormatter::class,
    'eventServiceName' => 'eventbus',
];