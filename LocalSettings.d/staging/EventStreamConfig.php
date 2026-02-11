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
        'stream' => 'rdf-streaming-updater.mutation',
        'schema_title' => 'mediawiki/wikibase/entity/rdf_change',
        'topics' => [ 'rdf-streaming-updater.mutation.v2' ],
  ],
];