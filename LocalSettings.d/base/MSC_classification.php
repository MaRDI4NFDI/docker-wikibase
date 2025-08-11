<?php
$wgExternalDataSources['MSC'] = [
    'server' => getenv('DB_SERVER'),
    'type' => 'mysql',
    'name' => 'msc-classification',
    'user' => 'msc-user',
    'password' => getenv('MSC_PASS'),
    'prepared' => <<<'SQL'
SELECT msc_string
FROM msc_id_mapping
WHERE msc_id = ?
SQL,
    'types' => 's'
];