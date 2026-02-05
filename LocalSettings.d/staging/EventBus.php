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

$wgRCFeeds['eventbus'] = [
    'class'            => EventBusRCFeedEngine::class,
    'formatter'        => EventBusRCFeedFormatter::class,
    'eventServiceName' => 'eventbus',
];