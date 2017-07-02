const request = require( 'request' );
const URL = 'http://api.wordpress.org/core/version-check/1.7/';

request.get( URL, function( err, res ) {
	if ( err ) {
		process.stderr.write( err );
	} else {
		const VERSION = JSON.parse( res.body ).offers[0].current;
		process.stdout.write( VERSION );
	}
} );
