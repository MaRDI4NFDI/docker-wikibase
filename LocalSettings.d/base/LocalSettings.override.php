<?php

/*******************************/
/* Enable Federated properties */
/*******************************/
#$wgWBRepoSettings['federatedPropertiesEnabled'] = true;

/*******************************/
/* Enables ConfirmEdit Captcha */
/*******************************/
#wfLoadExtension( 'ConfirmEdit/QuestyCaptcha' );
#$wgCaptchaQuestions = [
#  'What animal' => 'dog',
#];

#$wgCaptchaTriggers['edit']          = true;
#$wgCaptchaTriggers['create']        = true;
#$wgCaptchaTriggers['createtalk']    = true;
#$wgCaptchaTriggers['addurl']        = true;
#$wgCaptchaTriggers['createaccount'] = true;
#$wgCaptchaTriggers['badlogin']      = true;

/*******************************/
/* Disable UI error-reporting  */
/*******************************/
#ini_set( 'display_errors', 0 );

# Prevent new user registrations except by sysops
$wgGroupPermissions['*']['createaccount'] = false;
$wgGroupPermissions['user']['createaccount'] = true;
# Allow account creation for people that have NFDI Accounts
$wgGroupPermissions['*']['autocreateaccount'] = true;
# Allow users to rename themselves https://www.mediawiki.org/wiki/Manual:Renameuser
$wgGroupPermissions['user']['renameuser'] = true;

# Restrict anonymous editing
$wgGroupPermissions['*']['edit'] = false;

# Remove purge right from anonymous users
$wgGroupPermissions['*']['purge'] = false;

# Remove rate limits for bots
$wgGroupPermissions['bot']['noratelimit'] = true;

# Deactivate captchas for URLs
$wgCaptchaTriggers['addurl'] = false;

# Enabling uploads for images.
$wgEnableUploads = true;
$wgFileExtensions[] = 'svg';
# Explicitly mentioning the upload-path for image-upload.
$wgUploadPath = $wgScriptPath . '/images/';
# Enable SVG converter
$wgSVGConverter = 'rsvg';

# Enable PDF upload
$wgFileExtensions[] = 'pdf';

# Enable Markdown upload
$wgFileExtensions[] = 'md';
$wgHooks['MimeMagicInit'][] = static function ( $mime ) {
        $mime->addExtraTypes( 'text/plain md' );
};

# Extensions required by templates
wfLoadExtension( 'TemplateStyles' );
wfLoadExtension( 'JsonConfig' );
wfLoadExtension( 'InputBox' );
wfLoadExtension( 'ParserFunctions' );
wfLoadExtension( 'Math' );
wfLoadExtension( 'MathSearch' );
$wikibase_host = getenv( 'WIKIBASE_HOST' );
$wgWBRepoSettings['sparqlEndpoint']='https://query.' . $wikibase_host . '/sparql';

wfLoadExtension( 'Lockdown' );
wfLoadExtension( 'SyntaxHighlight_GeSHi' );
wfLoadExtension( 'ExternalContent' );

$wgMathDisableTexFilter = 'always';

$latexml_host = getenv('MW_LATEXML_HOST') ?: 'latexml';
$latexml_port = getenv('MW_LATEXML_PORT') ?: '8080';
$wgMathLaTeXMLUrl = "http://{$latexml_host}:{$latexml_port}/convert/";

#overwrite settings
$wgMathDefaultLaTeXMLSetting = array(
        'format' => 'xhtml',
        'whatsin' => 'math',
        'whatsout' => 'math',
        'pmml',
        'cmml',
        'mathtex',
        'nodefaultresources',
        'preload' => array(
                'LaTeX.pool',
                'article.cls',
                'amsmath.sty',
                'amsthm.sty',
                'amstext.sty',
                'amssymb.sty',
                'eucal.sty',
                // '[dvipsnames]xcolor.sty',
                'url.sty',
                'hyperref.sty',
                '[ids]latexml.sty',
                'DLMFmath.sty',
                'DRMFfcns.sty',
                'DLMFsupport.sty.ltxml',
        ),
        'linelength' => 90,
);

$wgWBRepoSettings['allowEntityImport'] = true;
$wgShowExceptionDetails = true;
$wgVisualEditorAvailableNamespaces = [
    'Project' => true,
    'Private' => true,
];


# Settings for lockdown extension (private documentation)

## Defining constants for additional namespaces.
define("NS_PRIVATE", 3000); // This MUST be even.

## Adding additional namespaces.
$wgExtraNamespaces[NS_PRIVATE] = "Private";

## Adding new user group private which is blocking reading and editing pages in private namespace.
$wgGroupPermissions['private'] = [];
$wgNamespacePermissionLockdown[NS_PRIVATE]['edit'] = [ 'private' ];
$wgNamespacePermissionLockdown[NS_PRIVATE]['read'] = [ 'private' ];

# Settings for MathSearch extension.
$fs_host = getenv('MW_FORMULASEARCH_HOST') ?: 'formulasearch';
$fs_port = getenv('MW_FORMULASEARCH_PORT') ?: '1985';
$wgMathSearchBaseXBackendUrl = "http://{$fs_host}:{$fs_port}/basex/";

# Settings for Math-Extension
$wgMathFullRestbaseURL = 'https://wikimedia.org/api/rest_';
$wgMathMathMLUrl = 'https://mathoid-beta.wmflabs.org';
// enable math native rendering (experimental)
$wgMathValidModes[] =  'native'; 

# enable experimental input formats
$wgMathEnableExperimentalInputFormats = true;


#popups for math
$wgMathWikibasePropertyIdDefiningFormula = "P14";
$wgMathWikibasePropertyIdHasPart = "P4";

#
# increase memory limit
ini_set('memory_limit', '2G');

# https://github.com/MaRDI4NFDI/portal-compose/issues/322
if ( MW_ENTRY_POINT !== 'cli') {
	$wgUseInstantCommons = true; 
}
# https://github.com/MaRDI4NFDI/portal-compose/issues/419
$wgJobTypeConf['default'] = [
    'class'          => 'JobQueueRedis',
    'redisServer'    => getenv('MW_REDIS_HOST') . ':' . getenv('MW_REDIS_PORT'), // this is the host ip from the default network
    'redisConfig'    => [],
    'daemonized'     => true
];
# The wdqs-updater would trigger a lot of jobs if the jun rate was not 0
$wgJobRunRate=0;
# Allow to display how many profie pages exist https://www.mediawiki.org/wiki/Help:Magic_words#Statistics
$wgAllowSlowParserFunctions=true;
# more than 50% of the active processes in the db are updates to the site_stat table 
# see https://www.mediawiki.org/wiki/Manual:$wgMultiShardSiteStats/en
$wgMultiShardSiteStats = true;
# https://www.mediawiki.org/wiki/Manual:$wgMainCacheType maybe we need to increase the size of the APC cache at some point in time
$wgMainCacheType = CACHE_MEMCACHED;
$wgMemCachedServers = [ 
    (getenv('MW_MEMCACHED_HOST') ?: 'memcached') . ':' . (getenv('MW_MEMCACHED_PORT') ?: '11211')
];
$wgSessionCacheType = CACHE_DB;
// Speed up "On high-traffic wikis, this should be set to false, to avoid the need to check the file modification time, and to avoid the performance impact of unnecessary cache invalidations. " see https://www.mediawiki.org/wiki/Manual:$wgInvalidateCacheOnLocalSettingsChange
$wgInvalidateCacheOnLocalSettingsChange=false;
// Store language cache on disk (should be faster) https://www.mediawiki.org/wiki/Manual:$wgLocalisationCacheConf
$wgCacheDirectory = "$IP/cache/$wgDBname";

// speed up speed for anonymous users https://www.mediawiki.org/wiki/Manual:$wgUseFileCache
$wgUseFileCache=false;

// speed up article count, by reducing the number of queries to the (giant) pagelink tables
$wgArticleCountMethod='any';
// some performance for large wikis optimization (used by WMF) https://www.mediawiki.org/wiki/Manual:$wgMiserMode
$wgMiserMode=true;
$wgCaptchaTriggers['addurl'] = false;

# MaRDI profile types items
$wgMathProfileQueries['dataset']='?item wdt:P1460 wd:Q5984635';
$wgMathProfileQIdMap['dataset']='Q5984635';
$wgMathProfileQueries['community']='?item wdt:P1460 wd:Q6205095';
$wgMathProfileQIdMap['community']='Q6205095';
$wgMathProfileQueries['algorithm']='?item wdt:P1460 wd:Q6503323';
$wgMathProfileQIdMap['algorithm']='Q6503323';
$wgMathProfileQueries['service']='?item wdt:P1460 wd:Q6503324';
$wgMathProfileQIdMap['service']='Q6503324';
$wgMathProfileQueries['theorem']='?item wdt:P1460 wd:Q6534201';
$wgMathProfileQIdMap['theorem']='Q6534201';
$wgMathProfileQueries['workflow']='?item wdt:P1460 wd:Q6534216';
$wgMathProfileQIdMap['workflow']='Q6534216';
$wgMathProfileQueries['academic_discipline']='?item wdt:P1460 wd:Q6534268';
$wgMathProfileQIdMap['academic_discipline']='Q6534268';
$wgMathProfileQueries['research_problem']='?item wdt:P1460 wd:Q6534269';
$wgMathProfileQIdMap['research_problem']='Q6534269';
$wgMathProfileQueries['model']='?item wdt:P1460 wd:Q6534270';
$wgMathProfileQIdMap['model']='Q6534270';
$wgMathProfileQueries['quantity']='?item wdt:P1460 wd:Q6534271';
$wgMathProfileQIdMap['quantity']='Q6534271';
$wgMathProfileQueries['task']='?item wdt:P1460 wd:Q6534272';
$wgMathProfileQIdMap['task']='Q6534272';

$wgExportFromNamespaces = true;

$wgShellboxUrls = [
	'default' => 'http://ffmpeg/shellbox'
];

$GLOBALS['wgHooks']['MWStakeRunJobsTriggerRegisterHandlers'][] = static function ( &$handlers ) {
	$handlers['auto-create-profile-pages'] = [
		'class' => '\\MediaWiki\\Extension\\MathSearch\\Graph\\AutoCreateProfilePages',
		'services' => [ 'MainConfig', 'JobQueueGroup' ]
	];
	return true;
};
