# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

use Test;
BEGIN { plan tests => 3 };

warn "checking Autodia.pm\n";

use Autodia;

ok(1); # If we made it this far, we're ok.

warn "checking classes\n";

use Autodia::Diagram;
use Autodia::Diagram::Class;
use Autodia::Diagram::Object;
use Autodia::Diagram::Dependancy;
use Autodia::Diagram::Inheritance;
use Autodia::Diagram::Superclass;
use Autodia::Diagram::Component;
use Autodia::Handler;

ok(2);

warn "checking handlers..\n";

foreach ( qw/SQL Cpp Perl PHP Java DBI dia Torque python umbrello/ ) {
  eval " use Autodia::Handler::$_ ; ";
  warn "couldn't compile Autodia::Handler::$_ : ignoring..\n" if $@;
}

ok(3);
