<?php
wfLoadExtension( 'OpenIDConnect' );
$wgPluggableAuth_Config['Login with your NFDI AAI Account'] = [
    'plugin' => 'OpenIDConnect',
    'data' => [
        'providerURL' => 'https://auth.didmos.nfdi-aai.de',
        'clientID' => $_ENV['NFDI_CLIENT_ID'],
        'clientsecret' => $_ENV['NFDI_AAI_SECRET'],
        'scope' => [],
    ]
];
$wgOpenIDConnect_MigrateUsersByEmail=true;
