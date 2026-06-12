<?php
$wgExternalDataSources['AbstractDB'] = [
    'server' => getenv('DB_SERVER'),
    'type' => 'mysql',
    'name' => 'paper-abstracts-db',
    'user' => 'abstract-user',
    'password' => getenv('ABSTRACT_PASS'),
    'prepared' => <<<'SQL'
SELECT abstract, abstract_source, summary, summary_source
FROM paper_abstracts
WHERE paper_qid = ?
SQL,
    'types' => 's'
];