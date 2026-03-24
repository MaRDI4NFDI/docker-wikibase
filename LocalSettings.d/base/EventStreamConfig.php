<?php

wfLoadExtension( 'EventStreamConfig' );

$wgEventStreams = [
    'recentchange' => [
        'stream' => 'recentchange',
        'schema_title' => 'mediawiki/recentchange',
        'topic_prefixes' => [ 'mardi.' ],
        'topics' => [ 'mardi.mediawiki.recentchange' ],
    ],
    'mediawiki.page_change.v1' => [
        'stream' => 'mediawiki.page_change.v1',
        'schema_title' => 'mediawiki/page/change',
        'topic_prefixes' => [ 'mardi.' ],
        'topics' => [ 'mardi.mediawiki.page_change.v1' ],
    ],
    'rdf-streaming-updater.mutation.v2' => [
        'stream' => 'rdf-streaming-updater.mutation.v2',
        'schema_title' => 'mediawiki/wikibase/entity/rdf_change',
        'topic_prefixes' => [ 'mardi.' ],
        'topics' => [ 'mardi.rdf-streaming-updater.mutation.v2' ],
    ],
    'rdf-streaming-updater.lapsed-action' => [
        'stream' => 'rdf-streaming-updater.lapsed-action',
        'schema_title' => 'rdf_streaming_updater/lapsed_action',
        'topic_prefixes' => [ 'mardi.' ],
        'topics' => [ 'mardi.rdf-streaming-updater.lapsed-action' ],
    ],
    'rdf-streaming-updater.state-inconsistency' => [
        'stream' => 'rdf-streaming-updater.state-inconsistency',
        'schema_title' => 'rdf_streaming_updater/state_inconsistency',
        'topic_prefixes' => [ 'mardi.' ],
        'topics' => [ 'mardi.rdf-streaming-updater.state-inconsistency' ],
    ],
    'rdf-streaming-updater.fetch-failure' => [
        'stream' => 'rdf-streaming-updater.fetch-failure',
        'schema_title' => 'rdf_streaming_updater/fetch_failure',
        'topic_prefixes' => [ 'mardi.' ],
        'topics' => [ 'mardi.rdf-streaming-updater.fetch-failure' ],
    ],
    'rdf-streaming-updater.reconcile' => [
        'stream' => 'rdf-streaming-updater.reconcile',
        'schema_title' => 'rdf_streaming_updater/reconcile',
        'topic_prefixes' => [ 'mardi.' ],
        'topics' => [ 'mardi.rdf-streaming-updater.reconcile' ],
    ],
    '/^mediawiki\\.job\\..+/' => [
        'schema_title' => 'mediawiki/job',
    ],
];

