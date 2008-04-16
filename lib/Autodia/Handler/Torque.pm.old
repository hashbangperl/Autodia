################################################################
# AutoDIA - Automatic Dia XML.   (C)Copyright 2001 A Trevena   #
#                                                              #
# AutoDIA comes with ABSOLUTELY NO WARRANTY; see COPYING file  #
# This is free software, and you are welcome to redistribute   #
# it under certain conditions; see COPYING file for details    #
################################################################
package Autodia::Handler::Torque;

require Exporter;

use strict;
use XML::Simple;

use vars qw($VERSION @ISA @EXPORT);
use Autodia::Handler;

@ISA = qw(Autodia::Handler Exporter);

use Autodia::Diagram;

#---------------------------------------------------------------

#####################
# Constructor Methods

# new inherited from Autodia::Handler

#------------------------------------------------------------------------
# Access Methods

# parse_file inherited from Autodia::Handler

#-----------------------------------------------------------------------------
# Internal Methods

# _initialise inherited from Autodia::Handler

sub _parse {
  my $self     = shift;
  my $fh       = shift;
  my $filename = shift;

  my $Diagram  = $self->{Diagram};
  my $xml = XMLin(join('',<$fh>));

  my %tables = ();
  my @relationships = ();

  # process tables
  foreach my $tablename (keys %{$xml->{table}}) {
    my $Class = Autodia::Diagram::Class->new($tablename);
    $Diagram->add_class($Class);
    my $primary_key = { name=>'Primary Key', type=>'pk', Param=>[], visibility=>0, };
    $tables{$tablename} = $Class;

    # process columns
    foreach my $column (keys %{$xml->{table}{$tablename}{column}}) {
      $Class->add_attribute({
			     name => $column,
			     visibility => 0,
			     type => $xml->{table}{$tablename}{column}{$column}{type},
			    });

      if (defined $xml->{table}{$tablename}{column}{$column}{primaryKey}) {
	push (@{$primary_key->{Param}}, { Name=>$column, Type=>''});
      }
    }

    # find foreign keys
    foreach my $fk (@{$xml->{table}{$tablename}{'foreign-key'}}) {
      # create foreign key table or get it if already present
      my $Superclass = Autodia::Diagram::Superclass->new($fk->{foreignTable});
      my $exists_already = $self->{Diagram}->add_superclass($Superclass);
      if (ref $exists_already) {
	$Superclass = $exists_already;
      }

      # create new relationship
      my $Relationship = Autodia::Diagram::Inheritance->new($Class, $Superclass);
      # add Relationship to superclass
      $Superclass->add_inheritance($Relationship);
      # add Relationship to class
      $Class->add_inheritance($Relationship);
      # add Relationship to diagram
      $self->{Diagram}->add_inheritance($Relationship);
    }
    # add primary key
    $Class->add_operation($primary_key);
  }
}

1;

###############################################################################

=head1 NAME

Autodia::Handler::Torque.pm - AutoDia handler for Torque xml database schema

=head1 INTRODUCTION

This provides Autodia with the ability to read Torque Database Schema files, allowing you to convert them via the Diagram Export methods to images (using GraphViz and VCG) or html/xml using custom templates or to Dia.

=head1 SYNOPSIS

use Autodia::Handler::Torque;

my $handler = Autodia::Handler::dia->New(\%Config);

$handler->Parse(filename); # where filename includes full or relative path.

=head1 Description

The Torque handler will parse the xml file using XML::Simple and populating the diagram object with class, superclass, and relationships representing tables and relationships.

The Torque handler is registered in the Autodia.pm module, which contains a hash of language names and the name of their respective language.

An example Torque database schema is shown here - its actually a rather nice format apart from the Java studlyCaps..


<?xml version="1.0" encoding="ISO-8859-1" standalone="no" ?>

<!DOCTYPE database SYSTEM "http://db.apache.org/torque/dtd/database_3_0_1.dtd">

<database name="INTERPLANETARY">

  <table name="CIVILIZATION">
    <column name="CIV_ID" required="true" autoIncrement="true" primaryKey="true" type="INTEGER"/>
    <column name="NAME" required="true" type="LONGVARCHAR"/>
  </table>

  <table name="CIV_PEOPLE">
    <column name="CIV_ID" required="true" primaryKey="true" type="INTEGER"/>
    <column name="PEOPLE_ID" required="true" primaryKey="true" type="INTEGER"/>

    <foreign-key foreignTable="CIVILIZATION">
        <reference local="CIV_ID" foreign="CIV_ID"/>
    </foreign-key>
    <foreign-key foreignTable="PEOPLE">
        <reference local="PEOPLE_ID" foreign="PEOPLE_ID"/>
    </foreign-key>
  </table>

  <table name="PEOPLE">
    <column name="PEOPLE_ID" required="true" autoIncrement="true" primaryKey="true" type="INTEGER"/>
    <column name="NAME" required="true" size="255" type="VARCHAR"/>
    <column name="SPECIES" type="INTEGER" default="-2"/>
    <column name="PLANET" type="INTEGER" default="-1"/>
  </table>
</database>

=head1 METHODS

=head2 CONSTRUCTION METHOD

use Autodia::Handler::Torque;

my $handler = Autodia::Handler::Torque->New(\%Config);
This creates a new handler using the Configuration hash to provide rules selected at the command line.

=head2 ACCESS METHODS

$handler->Parse(filename); # where filename includes full or relative path.

This parses the named file and returns 1 if successful or 0 if the file could not be opened.

=head1 SEE ALSO

Autodia

Torque

Autodia::Handler

=cut
