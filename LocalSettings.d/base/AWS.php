<?php

wfLoadExtension( 'AWS' );

$wgAWSCredentials = [
	'key' => getenv('S3_IMAGES_KEY'),
	'secret' => getenv('S3_IMAGES_SECRET'),
	'token' => false
];

$s3endpoint = getenv('S3_ENDPOINT');
$wgFileBackends['s3']['endpoint'] = 'https://' . $s3endpoint;
$wgFileBackends['s3']['use_path_style_endpoint'] = true; 

// $wgAWSBucketDomain = '$1.' . $s3endpoint;
// $wgAWSBucketDomain = $s3endpoint;

$wgAWSRegion = 'default';
$wgAWSBucketName = 'mardi-portal';

//$wgAWSBucketDomain = $s3endpoint . '/$1';
$wgAWSBucketDomain = 'images.' . getenv('WIKIBASE_HOST');

$wgAWSBucketTopSubdirectory = "/" . getenv('S3_ENVIRONMENT');
$wgAWSRepoHashLevels = '2';
$wgAWSRepoDeletedHashLevels = '3';