<?php

$wgSPARQLEndpoint = getenv( 'SPARQL_ENDPOINT' ) ?: 'http://staging-qlever:7001';
wfLoadExtension( 'SPARQL' );
