<?php

// https://www.mediawiki.org/wiki/Extension:VisualEditor
## VisualEditor Extension
wfLoadExtension( 'VisualEditor' );
wfLoadExtension( 'Parsoid', "{$IP}/vendor/wikimedia/parsoid/extension.json" );
$wgVisualEditorRebaserURL='wikimongo.' . getenv('WIKIBASE_HOST');
