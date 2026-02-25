<?php

wfLoadExtension( 'EventStreamConfig' );

$wgEventStreams = [
    'recentchange' => [
        'stream' => 'recentchange',
        'schema_title' => 'mediawiki/recentchange',
        'topics' => [ 'mediawiki.recentchange' ],
    ],
    'mediawiki.page_change.v1' => [
        'stream' => 'mediawiki.page_change.v1',
        'schema_title' => 'mediawiki/page/change',
        'topics' => [ 'mediawiki.page_change.v1' ],
    ],
    'rdf-streaming-updater.mutation.v2' => [
        'stream' => 'rdf-streaming-updater.mutation.v2',
        'schema_title' => 'mediawiki/wikibase/entity/rdf_change',
        'topics' => [ 'rdf-streaming-updater.mutation.v2' ],
    ],
    'rdf-streaming-updater.lapsed-action' => [
        'stream' => 'rdf-streaming-updater.lapsed-action',
        'schema_title' => 'rdf_streaming_updater/lapsed_action',
        'topics' => [ 'rdf-streaming-updater.lapsed-action' ],
    ],
    'rdf-streaming-updater.state-inconsistency' => [
        'stream' => 'rdf-streaming-updater.state-inconsistency',
        'schema_title' => 'rdf_streaming_updater/state_inconsistency',
        'topics' => [ 'rdf-streaming-updater.state-inconsistency' ],
    ],
    'rdf-streaming-updater.fetch-failure' => [
        'stream' => 'rdf-streaming-updater.fetch-failure',
        'schema_title' => 'rdf_streaming_updater/fetch_failure',
        'topics' => [ 'rdf-streaming-updater.fetch-failure' ],
    ],
    'rdf-streaming-updater.reconcile' => [
        'stream' => 'rdf-streaming-updater.reconcile',
        'schema_title' => 'rdf_streaming_updater/reconcile',
        'topics' => [ 'rdf-streaming-updater.reconcile' ],
    ],
    '/^mediawiki\\.job\\..+/' => [
        'schema_title' => 'mediawiki/job',
    ],
];
