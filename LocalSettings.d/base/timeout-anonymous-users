<?php
// Terminate expensive page generation for anonymous users after 10 seconds.
// Varnish already cuts the connection at 10s via anonBackendFirstByteTimeout;
// this ensures PHP-FPM also stops the work, freeing the Apache worker and DB connection.
if ( !RequestContext::getMain()->getUser()->isRegistered() ) {
    set_time_limit( 10 );
}
