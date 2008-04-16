################################################################
# AutoDIA - Automatic Dia XML.   (C)Copyright 2001 A Trevena   #
#                                                              #
# AutoDIA comes with ABSOLUTELY NO WARRANTY; see COPYING file  #
# This is free software, and you are welcome to redistribute   #
# it under certain conditions; see COPYING file for details    #
################################################################
package Autodia::Handler::Java;

require Exporter;

use strict;

use vars qw($VERSION @ISA @EXPORT);
use Autodia::Handler;

@ISA = qw(Autodia::Handler Exporter);

use Autodia::Diagram;
use Inline (
            Java => 'STUDY',
            STUDY => ['java.lang.Class',
                      'java.lang.reflect.Field',
                      'java.lang.reflect.Method'],
            ) ;

use Inline::Java qw(caught);


#---------------------------------------------------------------

#####################
# Constructor Methods

# new inherited from Autodia::Handler

#------------------------------------------------------------------------
# Access Methods

# parse_file inherited from Autodia::Handler

# True if the package names should be removed (i.e. java.lang.String => String)
my $remove_package_names = 1;

#-----------------------------------------------------------------------------
# Internal Methods

sub classname() {
    my $name = shift;
    $name =~ s/.*\.([a-sA-Z0-9_]*)$/$1/;
    return $name;
}

# Transforms a java array type (otherwise printed as [int) into a
# reasonable form (e.g. int[]).
sub javaTypeToString()
{
    my $type = shift;
    my $typesuffix = "";
    while ($type->isArray()) {
	$typesuffix .= "[]";
	$type = $type->getComponentType();
    }
    my $typename = $type->getName();
    if ($remove_package_names) {
	$typename =~ s/.*\.(\w*)$/$1/;
    }
    return $typename.$typesuffix;
}

# These from JVM Specs Chapter 4.
my $IS_PUBLIC     = 0x0001;
my $IS_PRIVATE    = 0x0002;
my $IS_PROTECTED  = 0x0004;
my $IS_STATIC     = 0x0008;
my $IS_FINAL      = 0x0010;
my $IS_INTERFACE  = 0x0200;
my $IS_ABSTRACT   = 0x0400;

# _initialise inherited from Handler

sub _parse
  {
    my $self     = shift;
    my $fh       = shift;
    my $filename = shift;
    my $Diagram  = $self->{Diagram};

    my $Class;

    $self->{pod} = 0;

    close($fh); # We don't use the filehandle:)

    my $classname = $filename;
    $classname =~ s/(.*)\.(java|class)/$1/;
    $classname =~ s/\//./g;

    my $javaclass;
    eval {
	$javaclass = java::lang::Class->forName($classname);
    };

    if ($@) {
	print STDERR  "Something went wrong finding $classname.\n" unless $self->{Config}->{silent};
	if (caught("java.lang.Exception")) {
	    print STDERR  "Class $classname not found. Make sure it is compiled and in the CLASSPATH (which is '".$ENV{'CLASSPATH'}."'\n" unless $self->{Config}->{silent};
	} else {
	}
	return;
    }


    # create new class with name
    $Class = Autodia::Diagram::Class->new(&classname($javaclass->getName()));

    # add class to diagram
    $Diagram->add_class($Class);
    if ($javaclass->isInterface()) {
	# How do we deal with interfaces?
	# Set it abstract?
    }


    if ($javaclass->getPackage()) {
	# create component
	my $Component = Autodia::Diagram::Component->new($javaclass->getPackage());
	# add component to diagram
	my $exists = $Diagram->add_component($Component);

	# replace component if redundant
	if (ref $exists)
	{
	    $Component = $exists;
	}
	# create new dependancy
	my $Dependancy = Autodia::Diagram::Dependancy->new($Class, $Component);
	# add dependancy to diagram
	$Diagram->add_dependancy($Dependancy);
	# add dependancy to class
	$Class->add_dependancy($Dependancy);
	# add dependancy to component
	$Component->add_dependancy($Dependancy);
    }

    my $superclass = $javaclass->getSuperclass();

    if ($superclass) {
	# create superclass
	my $Superclass = Autodia::Diagram::Superclass->new(&classname($superclass->getName()));

	# add superclass to diagram
	my $exists_already = $Diagram->add_superclass($Superclass);
	if (ref $exists_already)
	{
	    $Superclass = $exists_already;
	}
	# create new inheritance
	my $Inheritance = Autodia::Diagram::Inheritance->new($Class, $Superclass);
	# add inheritance to superclass
	$Superclass->add_inheritance($Inheritance);
	# add inheritance to class
	$Class->add_inheritance($Inheritance);
	# add inheritance to diagram
	$Diagram->add_inheritance($Inheritance);
    }

    # Not sure how to add interfaces -- we need DiagramImplements?
    my $interfaces = $javaclass->getInterfaces();

    foreach my $I ( @$interfaces ) {
#	print "Implements: ".$I->getName()."\n";
    }

    my $fields = $javaclass->getDeclaredFields();

    foreach my $F ( @$fields ) {
	my $mods = $F->getModifiers();
	# Note that it can be public && protected, that's the default!
	my $is_public = $mods & $IS_PUBLIC;
	my $is_private = $mods & $IS_PRIVATE;
	my $is_protected = $mods & $IS_PROTECTED;
	my $is_static = $mods & $IS_STATIC;
	my $name = $F->getName();
	my $type = $F->getType();
	my $typename = &javaTypeToString($type);

	$Class->add_attribute({
	    name => $name,
	    type => $typename,
	    visibility => $is_public?1:0,
	});
    }

    my $methods = $javaclass->getDeclaredMethods();

    foreach my $M ( @$methods ) {
	my $mods = $M->getModifiers();
	# Note that it can be public && protected, that's the default!
	my $is_public = $mods & $IS_PUBLIC;
	my $is_private = $mods & $IS_PRIVATE;
	my $is_protected = $mods & $IS_PROTECTED;
	my $is_static = $mods & $IS_STATIC;
	my $is_abstract = $mods & $IS_ABSTRACT;
	my $is_final = $mods & $IS_FINAL;
	my $name = $M->getName();
	my $type = $M->getReturnType();
	my $typename = &javaTypeToString($type);
	my $args = $M->getParameterTypes();
	my $first = 1;

	my %subroutine = ( "name" => $name, );
	$subroutine{"visibility"} = $is_public?1:0;

	my @params = ();
	foreach my $A (@$args ) {
	    push(@params, &javaTypeToString($A));
	}

	$subroutine{"param"} = \@params;
	$Class->add_operation(\%subroutine);
    }
    $self->{Diagram} = $Diagram;
    return;
}
