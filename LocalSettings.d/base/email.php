<?php
# See https://www.mediawiki.org/wiki/Manual:$wgSMTP/Gmail
if ( getenv( 'SMTP_username' ) && getenv( 'SMTP_password' ) ) { 
  $wgSMTP = [
    'host' => 'ssl://smtp.gmail.com',
    // IDHost is a MediaWiki-specific setting used to build the Message-ID email header 
    // (see RFC 2822, sec 3.6.4 for more information on a properly formatted Message-ID). 
    // If not provided, will default to $wgServer. 
    'IDHost' => getenv( 'WIKIBASE_HOST' ), 
    'port' => 465,
    'username' => getenv( 'SMTP_username' ) ,
    'password' => getenv( 'SMTP_password' ),
    'auth' => true
  ];
  $wgEmergencyContact='contact@mardi4nfdi.de';
  $wgPasswordSender='contact@mardi4nfdi.de';
} else {
  $wgEnableEmail=false;
}
