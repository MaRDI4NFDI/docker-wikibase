<?php
# See https://www.mediawiki.org/wiki/Manual:$wgSMTP/Gmail
if ( getenv( 'SMTP_EMAIL' ) && getenv( 'SMTP_PW' ) ) { 
  $wgSMTP = [
    'host' => 'ssl://smtp.gmail.com',
    'port' => 465,
    'username' => getenv( 'SMTP_EMAIL' ) ,
    'password' => getenv( 'SMTP_PW' ),
    'auth' => true
  ];
  // If not provided, will default to $wgServer. 
  if ( getenv( 'WIKIBASE_HOST' ) ) {
    // IDHost is a MediaWiki-specific setting used to build the Message-ID email header 
    // (see RFC 2822, sec 3.6.4 for more information on a properly formatted Message-ID). 
    $wgSMTP['IDHost'] = getenv( 'WIKIBASE_HOST' );    
  }
  $wgEmergencyContact = 'contact@mardi4nfdi.de';
  if ( getenv( 'MW_ADMIN_EMAIL' ) ) {
    $wgPasswordSender = getenv( 'MW_ADMIN_EMAIL' );
  }
} else {
  $wgEnableEmail=false;
}
