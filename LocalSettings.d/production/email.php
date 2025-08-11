<?php
// doku https://www.mediawiki.org/wiki/Manual:$wgSMTP/Gmail
$wgSMTP = [
    'host' => 'ssl://smtp.gmail.com',  // hostname of the email server
    'IDHost' => getenv('WIKIBASE_HOST'),
    'port' => 465,
    'auth' => true,
    'username' => getenv( 'SMTP_EMAIL' ),
    'password' => getenv( 'SMTP_PW' )
];
