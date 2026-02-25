<?php

use MediaWiki\Extension\EventBus\Adapters\JobQueue\JobQueueEventBus;

$wgJobTypeConf['default'] = [
    'class' => JobQueueEventBus::class,
    'readOnlyReason' => false,
];