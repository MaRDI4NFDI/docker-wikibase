<?php

  $wgMWLoggerDefaultSpi = [
      'class' => \MediaWiki\Logger\MonologSpi::class,
      'args' => [[
          'loggers' => [
              'MardiImport' => [
                  'handlers' => [ 'stderr' ],
              ],
          ],
          'handlers' => [
              'stderr' => [
                  'class' => \Monolog\Handler\StreamHandler::class,
                  'args' => [ 'php://stderr', \Monolog\Logger::DEBUG ],
              ],
          ],
      ]],
  ];