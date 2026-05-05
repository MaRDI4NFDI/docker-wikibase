<?php
// Only applies to web requests (not CLI maintenance scripts like update.php or runJobs.php).
// For anonymous web users, limit PHP execution to 10 seconds to match the Varnish
// anonBackendFirstByteTimeout, ensuring the backend work is actually terminated
// when Varnish cuts the connection rather than continuing to consume resources.
if ( PHP_SAPI !== 'cli' && PHP_SAPI !== 'phpdbg' ) {
    $wgHooks['BeforeInitialize'][] = function() {
        if ( !RequestContext::getMain()->getUser()->isRegistered() ) {
            set_time_limit( 10 );
        }
    };
}
