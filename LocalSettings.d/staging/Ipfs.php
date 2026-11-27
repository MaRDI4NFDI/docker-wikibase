<?php
# The staging IPFS node from portal-k8s; its API only accepts this token.
$wgMathSearchIpfsApi = 'http://ipfs:5001';
$wgMathSearchIpfsApiToken = getenv( 'MATHSEARCH_IPFS_TOKEN' ) ?: null;
