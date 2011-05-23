# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

use Test::More;# qw(no_plan);

warn "checking Autodia.pm\n";

use_ok('Autodia');

warn "checking classes\n";

use Autodia::Diagram;
use Autodia::Diagram::Class;
use Autodia::Diagram::Object;
use Autodia::Diagram::Dependancy;
use Autodia::Diagram::Inheritance;
use Autodia::Diagram::Superclass;
use Autodia::Diagram::Component;
use Autodia::Handler;

warn "checking handlers..\n";

foreach ( qw/SQL Cpp Perl PHP DBI dia Torque python umbrello Mason/ ) {
  eval " require_ok('Autodia::Handler::$_') ; ";
  warn "couldn't compile Autodia::Handler::$_ : $@ : ignoring..\n" if $@;
}

done_testing();
