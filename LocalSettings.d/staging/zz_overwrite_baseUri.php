<?php

$wgWBClientSettings['entitySources'] = [
    'mardi_source' => [
        'repoDatabase' => 'my_wiki',
        'baseUri' => 'http://'. getenv( 'WIKIBASE_HOST' ) . '/entity/',
        'entityNamespaces' => [
            'item' => 120,
            'property' => 122,
        ],
        'rdfNodeNamespacePrefix' => 'wd',
        'rdfPredicateNamespacePrefix' => '',
        'interwikiPrefix' => '',
    ],
];

$wgWBRepoSettings['entitySources'] = [
      'mardi_source' => [
        'repoDatabase' => 'my_wiki',
        'baseUri' => 'http://'. getenv( 'WIKIBASE_HOST' ) . '/entity/',
        'entityNamespaces' => [
            'item' => 120,
            'property' => 122,
        ],
        'rdfNodeNamespacePrefix' => 'wd',
        'rdfPredicateNamespacePrefix' => '',
        'interwikiPrefix' => '',
      ],

  ];