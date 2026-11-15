<?php
/**
 * Every log record goes as one Logstash JSON line to stderr (kubectl
 * logs) and, if MW_LOGSTASH_HOST is set, by UDP to Logstash (portal-k8s
 * charts/logstash). Channels in $wmgDebugChannels log from debug on,
 * all others from warning on.
 * https://www.mediawiki.org/wiki/Manual:Structured_logging
 *
 * This file must sort first: MediaWiki fixes its logger on the first
 * log call.
 */

use MediaWiki\Logger\Monolog\LogstashFormatter;
use MediaWiki\Logger\Monolog\WikiProcessor;
use MediaWiki\Logger\MonologSpi;
use Monolog\Handler\SocketHandler;
use Monolog\Handler\StreamHandler;
use Monolog\Handler\WhatFailureGroupHandler;
use Monolog\Processor\PsrLogMessageProcessor;
use Monolog\Processor\WebProcessor;

// OpenIDConnect and PluggableAuth only temporarily, to debug the
// NFDI-AAI login: their debug records contain emails and OIDC subjects.
$wmgDebugChannels = [ 'OpenIDConnect', 'PluggableAuth' ];
if ( getenv( 'DEPLOYMENT_ENV' ) === 'staging' ) {
	$wmgDebugChannels[] = 'MardiImport';
}

$wmgHandlers = [];
foreach ( [ 'debug', 'warning' ] as $wmgLevel ) {
	$wmgFormatter = new LogstashFormatter( 'mediawiki', php_uname( 'n' ), '', '', LogstashFormatter::V1 );
	$wmgTargets = [ ( new StreamHandler( 'php://stderr', $wmgLevel ) )->setFormatter( $wmgFormatter ) ];
	if ( getenv( 'MW_LOGSTASH_HOST' ) ) {
		$wmgTargets[] = ( new SocketHandler(
			'udp://' . getenv( 'MW_LOGSTASH_HOST' ), $wmgLevel, writingTimeout: 1.0, connectionTimeout: 1.0
		) )->setFormatter( $wmgFormatter );
	}
	// Keeps a failing log target from failing the request.
	$wmgHandlers[$wmgLevel] = [ 'class' => WhatFailureGroupHandler::class, 'args' => [ $wmgTargets ] ];
}

$wmgLoggers = [ '@default' => [ 'handlers' => [ 'warning' ], 'processors' => [ 'wiki', 'psr', 'web' ] ] ];
foreach ( $wmgDebugChannels as $wmgChannel ) {
	$wmgLoggers[$wmgChannel] = [ 'handlers' => [ 'debug' ], 'processors' => [ 'wiki', 'psr', 'web' ] ];
}

$wgMWLoggerDefaultSpi = [
	'class' => MonologSpi::class,
	'args' => [ [
		'loggers' => $wmgLoggers,
		'handlers' => $wmgHandlers,
		'processors' => [
			'wiki' => [ 'class' => WikiProcessor::class ],
			'psr' => [ 'class' => PsrLogMessageProcessor::class ],
			'web' => [ 'class' => WebProcessor::class ],
		],
	] ],
];

unset( $wmgDebugChannels, $wmgHandlers, $wmgLevel, $wmgFormatter, $wmgTargets, $wmgLoggers, $wmgChannel );
