<?php

use MediaWiki\Logger\LoggerFactory;

$wgDBname = 'my_wiki';
$host = $_SERVER['HTTP_HOST'] ?? false;
if ( defined( 'MW_DB' ) ) {
	// Set $wikiId from the defined constant 'MW_DB' that is set by maintenance scripts.
	$wgDBname = MW_DB;
} elseif ( $host === false ) {
	$logger = LoggerFactory::getInstance( 'MaRDIconf' );
	$logger->warning( 'Server name not set. Falling back to my_wiki.' );
} elseif ( str_contains( $host, 'swmath' ) ) {
	$wgDBname = 'wiki_swmath';
} elseif ( str_contains( $host, '.wik' ) ) {
	$wikibase_host = getenv( 'WIKIBASE_HOST' );
	if ( preg_match( '/^([0-9a-z-]+)\.(wik.*?)' . $wikibase_host . '$/', $host, $match ) !== 1 ) {
		die( "Server name $host does not match the patterns for wikis." );
	}
	$lang = str_replace( '-', '_', $match[1] );
	$suffix = str_replace( '.', '', $match[2] );
	$wgDBname = $lang . $suffix;
}

/** Set language code */
if ( preg_match( '/^([a-z_]+)(wik.*?)$/', $wgDBname, $match ) === 1 ) {
	$lang = str_replace( '_', '-', $match[1] );
	if ( LanguageCode::isWellFormedLanguageTag( $lang ) ) {
		$wgLanguageCode = $lang;
	}
	// fall back to English otherwise
}

// Basic db configuration in Localsettings.php https://github.com/MaRDI4NFDI/docker-wikibase/blob/7146f8b2fdbba680d11ffffb32b51d3961f50a9c/LocalSettings.php.template#L12-L16
