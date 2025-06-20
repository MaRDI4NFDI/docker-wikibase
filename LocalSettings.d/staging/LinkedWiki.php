<?php
wfLoadExtension( 'LinkedWiki' );

# Linked-Wiki Configuration
$wgLinkedWikiConfigSPARQLServices["mardi"] = array(
    "debug" => false,
    "isReadOnly" => true,
    "endpointRead" => "https://query.staging.mardi4nfdi.org/proxy/wdqs/bigdata/namespace/wdq/sparql",
    "typeRDFDatabase" => "blazegraph",
    "HTTPMethodForRead" => "GET",
    "lang" => "en"
);

$wgLinkedWikiSPARQLServiceByDefault= "mardi";