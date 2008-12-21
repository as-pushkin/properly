#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'XMLConstructor' );
}

diag( "Testing XMLConstructor $XMLConstructor::VERSION, Perl $], $^X" );
