<?php
// Terminate expensive page generation for anonymous users after 10 seconds.
// Varnish already cuts the connection at 10s via anonBackendFirstByteTimeout;
// Only applies to web requests (not CLI maintenance scripts like update.php or runJobs.php).
// For anonymous web users, limit PHP execution to 10 seconds to match the Varnish
// anonBackendFirstByteTimeout, ensuring the backend work is actually terminated
// when Varnish cuts the connection rather than continuing to consume resources.
if ( PHP_SAPI !== 'cli' && PHP_SAPI !== 'phpdbg' &&
     !RequestContext::getMain()->getUser()->isRegistered() ) {
    set_time_limit( 10 );
}
