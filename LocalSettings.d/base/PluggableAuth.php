<?php
# https://www.mediawiki.org/wiki/Extension:PluggableAuth
// Allowing users to edit local properties might break things if the wiki relies on values from the auth provider. From the docs:
// If true, users can edit their email address and real name on the wiki. If false, the default, they cannot do so. Note that, if you rely on email address and/or real name returned from the authentication provider in any way, you should leave this setting at its default value.
$wgPluggableAuth_EnableLocalProperties=true;
$wgPluggableAuth_EnableLocalLogin=true;
wfLoadExtension( 'PluggableAuth' );
