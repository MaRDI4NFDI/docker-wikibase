<?php
  wfLoadExtension( 'MardiImport' );
  $wgMardiImportBaseUrl = 'http://' . getenv( 'IMPORTER_ENDPOINT' );