<?php
wfLoadExtension( 'LinkedWiki' );

# Linked-Wiki Configuration
$wgLinkedWikiConfigSPARQLServices["mardi"] = array(
    "debug" => false,
    "isReadOnly" => true,
    "endpointRead" => "https://query." . $_ENV['WIKIBASE_HOST'] . "/sparql",
    "typeRDFDatabase" => "blazegraph",
    "HTTPMethodForRead" => "GET",
    "lang" => "en"
);

$wgLinkedWikiSPARQLServiceByDefault= "mardi";
