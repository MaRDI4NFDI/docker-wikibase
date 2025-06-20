<?php
if ( $wgDBname === 'wiki_swmath' ) {
  $wgSitename = 'swMATH staging';
  # Set swMATH logo
  $wgLogos = [
  'wordmark' => [
    'src' => $wgScriptPath . '/images_repo/swMATH.svg',  // path to wordmark version
    'width' => 155,
    'height' => 35
    ]
  ];
  $wgWBClientSettings['siteGlobalID'] = 'swmath';

  $wgLogo = $wgScriptPath . '/images/7/76/SwMATH.png';        
  $wgLogos = false;
  $wgFileExtensions[] = 'json';
  $wgExternalDataSources['postgresql'] = [
      'server'    => 'swmath_postgres',
      'type'      => 'postgres',
      'name'      => 'sm2',
      'user'      => getenv( 'POSTGRESQL_USER' ),
      'password'  => getenv( 'POSTGRESQL_PW' ),
      'prepared'  => [
          'softwareList' => <<<'POSTGRE'
  SELECT id, sw, tx, hp
  FROM soft_software
  LIMIT 25;
  POSTGRE,
          'software' => <<<'POSTGRE'
  SELECT id, sw, tx, keyw, au
  FROM soft_software
  WHERE id= $1
  POSTGRE,
          'references' => <<<'POSTGRE'
  SELECT author, title, year from soft_artikel
  JOIN math_documents on soft_artikel.did = math_documents.id
  where sid=$1
  POSTGRE,

          'github' => <<<'POSTGRE'
  SELECT id, github from swmath_software
  where github <> ''
  POSTGRE
          ]
  ];
}

$wgMathSearchSwhToken = getenv( 'SWH_TOKEN' );
