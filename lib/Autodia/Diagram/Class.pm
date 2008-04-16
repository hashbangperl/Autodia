package Autodia::Diagram::Class;
use strict;

=head1 NAME

DiagramClass - Class that holds, updates and outputs the values of a diagram element of type class.

=head1 SYNOPSIS

use DiagramClass;

my $Class = DiagramClass->new;

=head2 Description

DiagramClass is an object that represents the Dia UML Class element within a Dia diagram. It holds, outputs and allows the addition of attributes, relationships and methods.

=cut

use vars qw($VERSION @ISA @EXPORT);
require Exporter;

use Autodia::Diagram::Object;
use Data::Dumper;

@ISA = qw(Autodia::Diagram::Object Exporter);

=head1 METHODS

=head2 Constructor

my $Class = DiagramClass->new($name);

creates and returns a simple DiagramClass object, containing its name and its original position (default 0,0).

=head2 Accessors

DiagramClass attributes are accessed through methods, rather than directly. Each attribute is available through calling the method of its name, ie Inheritances(). The methods available are : 

Operations, Attributes, Inheritances, Dependancies, Parent, and has_child. The first 4 return a list, the later return a string.

Adding elements to the DiagramClass is acheived through the add_<attribute> methods, ie add_inheritance().

Rather than remove an element from the diagram it is marked as redundant and replaced with a superceding element, as DiagramClass has highest precedence it won't be superceded and so doesn't have a redundant() method. Superclass and Component do.

=head2 Accessing and manipulating the DiagramClass

$DiagramClass->Attributes(), Inheritances(), Operations(), and Dependancies() all return a list of their respective elements.

$DiagramClass->Parent(), and has_child() return the value of the parent or child respectively if present otherwise a false.

$Diagram->add_attribute(), add_inheritance(), add_operation(), and add_dependancy() all add a new element of their respective types.

=cut

#####################
# Constructor Methods

sub new
{
  my $class = shift;
  my $name = shift;
  my $DiagramClass = {};
  bless ($DiagramClass, ref($class) || $class);
  $DiagramClass->_initialise($name);
  return $DiagramClass;
}

#-------------------------------------------------------------------------

################
# Access Methods

sub Dependancies
{
  my $self = shift;
  if (defined $self->{"dependancies"})
    {
      my @dependancies = @{$self->{"dependancies"}};
      return @dependancies;
    }
  else
    { return; }
}


sub add_dependancy
{
  my $self = shift;
  my $new_dependancy = shift;
  my @dependancies;

  if (defined $self->{"dependancies"})
  { @dependancies = @{$self->{"dependancies"}}; }

  push(@dependancies, $new_dependancy);
  $self->{"dependancies"} = \@dependancies;

  return scalar(@dependancies);
}

sub Inheritances
{
  my $self = shift;

  if (defined $self->{"inheritances"})
    {
      my @inheritances = @{$self->{"inheritances"}};
      return @inheritances;
    }
  else
    { return; }
}

sub add_inheritance
{
  my $self = shift;
  my $new_inheritance = shift;
  my @inheritances;

  if (defined $self->{"inheritances"})
  { @inheritances = @{$self->{"inheritances"}}; }

  push(@inheritances, $new_inheritance);
  $self->{"inheritances"} = \@inheritances;
  $self->Parent($new_inheritance->Id);

  return scalar(@inheritances);
}

sub Attributes
{
  my $self = shift;

  if (defined $self->{"attributes"})
    {
      my @attributes = @{$self->{"attributes"}};
      return \@attributes;
    }
  else { return; }
}

sub add_attribute
{
  my $self = shift;
  my %new_attribute = %{shift()};

  # discard new attribute if duplicate
  my $discard = 0;
  foreach my $attribute ( @{$self->{"attributes"}} )
  {
      my %attribute = %$attribute;
      if ($attribute{name} eq $new_attribute{name})
      { $discard = 1; }
  }

  unless ($discard)
  {
      push (@{$self->{"attributes"}},\%new_attribute);
      $self->_set_updated("attributes");
      $self->_update;
  }

  return scalar(@{$self->{"attributes"}});
}

sub has_child
{
    my $self   = shift;
    my $child  = shift;
    my $return = 0;

    if (defined $child) { $self->{"child"} = $child;  }
    else { $return = $self->{"child"}; }
}

sub Parent
{
    my $self   = shift;
    my $parent = shift;
    my $return = 0;

    if (defined $parent) { $self->{"parent"} = $parent;  }
    else { $return = $self->{"parent"}; }
}

sub replace_superclass
{
    my $self       = shift;
    my $superclass = shift;

    if (ref ($superclass->Inheritances))
      {
	my @inheritances = @{$superclass->Inheritances};
	foreach my $inheritance (@inheritances)
	  { $inheritance->Parent($self->Id); }
      }
    return 1;
}

sub replace_component
{
  my $self = shift;
  my $component = shift;

  if (ref ($component->Dependancies) )
    {
      my @dependancies = $component->Dependancies;
      foreach my $dependancy (@dependancies)
	{
	  $dependancy->Parent($self->Id);
	}
    }

  return 1;
}

sub Operations
{
  my $self = shift;

  if (defined $self->{"operations"})
    {
      my @operations = $self->{"operations"};
      return @operations;
    }
  else
    { return; }
}

sub add_operation
{
  my $self = shift;
  my %operation = %{shift()};
  push (@{$self->{"operations"}},\%operation);

  $self->_set_updated("operations");
  $self->_update;

  return scalar(@{$self->{"operations"}});
}

#-----------------------------------------------------------------------

##################
# Internal Methods

sub _initialise # over-rides method in DiagramObject
{
  my $self = shift;
  $self->{"name"} = shift;
  $self->{"type"} = "class";
  $self->{"top_y"} = 1;
  $self->{"left_x"} = 1;
  $self->{"width"} = 2; # arbitary
  $self->{"height"} = 2; # arbitary
  #$self->{"operations"} = [];
  #$self->{"attributes"} = [];

  return 1;
}

sub _update
  {
    my $self = shift;

    my %updated = %{$self->{_updated}};

    if ($updated{"attributes"})
    {
	my $longest_element = ($self->{"width"} -1) / 0.5;
	my @attributes = @{$self->{"attributes"}};
	my $last_element = pop @attributes;
	if (length $last_element > $longest_element)
	{
	    $self->{"width"} = (length $last_element * 0.5) + 1;
	}
	$self->{height} += 0.8;
    }

    if ($updated{"operations"})
    {
	my $longest_element = ($self->{width} -1) / 0.5;
	my @operations = @{$self->{"operations"}};
	my $last_element = pop @operations;
	if (length $last_element > $longest_element)
	{
	    $self->{"width"} = (length $last_element * 0.5) + 1;
	}
	$self->{"height"} += 0.8;
    }

    undef $self->{"_updated"};

    return 1;
  }


1;

##############################################################################


=head2 See Also

L<Autodia::DiagramObject>

L<Autodia::Diagram>

L<Autodia::DiagramSuperclass>

L<Autodia::DiagramInheritance>

=head1 AUTHOR

Aaron Trevena, E<lt>aaron.trevena@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by Aaron Trevena

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.1 or,
at your option, any later version of Perl 5 you may have available.

=cut

########################################################################
