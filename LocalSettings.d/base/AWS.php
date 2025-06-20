<?php

wfLoadExtension( 'AWS' );

$wgAWSCredentials = [
	'key' => getenv('S3_IMAGES_KEY'),
	'secret' => getenv('S3_IMAGES_SECRET'),
	'token' => false
];

$s3endpoint = getenv('S3_ENDPOINT');
$wgFileBackends['s3']['endpoint'] = 'https://' . $s3endpoint;
$wgAWSBucketDomain = '$1.' . $s3endpoint;

$wgAWSRegion = 'default';
$wgAWSBucketName = 'mardi-portal';
$wgAWSBucketTopSubdirectory = "/" . getenv('S3_ENVIRONMENT');
$wgAWSRepoHashLevels = '2';
$wgAWSRepoDeletedHashLevels = '3';