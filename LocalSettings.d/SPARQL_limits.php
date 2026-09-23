<?php
/**
 * Limits for SPARQL queries run while rendering pages (SPARQL extension,
 * patched by patches/SPARQL-limit-query-time.patch).
 *
 * Renders call the query service synchronously, and Varnish gives anonymous
 * requests 10 seconds for the first byte. During bot storms QLever saturated
 * and PHP workers waited on it until Varnish served 503s. A query now gets
 * a few seconds; if it fails, that part of the page stays empty and the
 * render is cached only briefly, so it is redone once the service recovers.
 */

// Sent to QLever as the "timeout" parameter: QLever cancels the query itself
// and frees the CPU. Must not exceed the server's own timeout, or QLever
// rejects the query.
$wgSPARQLQueryTimeout = '5s';

// How long the HTTP client waits, in seconds. Slightly above the query
// timeout so QLever's own cancellation normally wins.
$wgSPARQLHttpTimeout = 7;

// Parser cache and CDN lifetime, in seconds, of a render in which a query
// failed.
$wgSPARQLFailedQueryCacheExpiry = 60;

// The parser cache honours the shortened expiry on its own, but the CDN TTL
// is not derived from it. Lower s-maxage explicitly for degraded renders so
// Varnish does not keep them for hours.
$wgHooks['OutputPageParserOutput'][] = static function ( $outputPage, $parserOutput ) {
	if ( $parserOutput->getExtensionData( 'sparql-query-failed' ) ) {
		$outputPage->lowerCdnMaxage( $GLOBALS['wgSPARQLFailedQueryCacheExpiry'] );
	}
};
