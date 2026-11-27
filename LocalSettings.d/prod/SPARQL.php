<?php

// Page renders reach QLever through the qlever-wiki-proxy in production (it
// limits concurrency and caches results). SPARQL_ENDPOINT is set by the Helm
// chart; without it the extension talks to QLever directly.
$wgSPARQLEndpoint = getenv( 'SPARQL_ENDPOINT' ) ?: 'http://qlever:7001';
wfLoadExtension( 'SPARQL' );
