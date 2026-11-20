<?php
if (getenv('NFDI_CLIENT_ID') && getenv('NFDI_AAI_SECRET')) {
    wfLoadExtension( 'OpenIDConnect' );
    $wgPluggableAuth_Config['Login with your NFDI AAI Account'] = [
        'plugin' => 'OpenIDConnect',
        'data' => [
            'providerURL' => 'https://auth.didmos.nfdi-aai.de',
            'clientID' => $_ENV['NFDI_CLIENT_ID'],
            'clientsecret' => $_ENV['NFDI_AAI_SECRET'],
            'scope' => [ 'voperson_external_affiliation' ],
            // Asks for the claim in the ID token, the only token the group sync reads.
            'authparam' => [
                'claims' => json_encode( [ 'id_token' => [ 'voperson_external_affiliation' => null ] ] ),
            ],
        ],
        'groupsyncs' => [
            'affiliation' => [
                'type' => 'mapped',
                'map' => [
                    'institution-member' => [
                        'voperson_external_affiliation' => static fn ( array $v ): bool =>
                            (bool)preg_grep( '/^(member|faculty|staff|student)@/', $v ),
                    ],
                ],
            ],
        ],
    ];
    $wgGroupPermissions['institution-member'] ??= [];
    $wgHooks['MessagesPreLoad'][] = static function ( $title, &$message, $code ) {
        $messages = [
            'en' => [
                'Group-institution-member' => 'Members of DFN-AAI institutions',
                'Group-institution-member-member' => 'member of a DFN-AAI institution',
            ],
            'de' => [
                'Group-institution-member' => 'Angehörige von DFN-AAI-Einrichtungen',
                'Group-institution-member-member' => 'Angehörige einer DFN-AAI-Einrichtung',
            ],
        ];
        // Titles outside the content language end in "/$code".
        $message = $messages[$code][explode( '/', $title )[0]] ?? $message;
    };
    $wgOpenIDConnect_MigrateUsersByEmail=true;
}
