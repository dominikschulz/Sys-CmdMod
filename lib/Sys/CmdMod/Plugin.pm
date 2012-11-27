package Sys::CmdMod::Plugin;
# ABSTRACT: Abstract base class for command modifier

use 5.010_000;
use mro 'c3';
use feature ':5.10';

use Moose;
use namespace::autoclean;

# use IO::Handle;
# use autodie;
# use MooseX::Params::Validate;

use Sys::Run;

has 'name' => (
    'is'       => 'ro',
    'isa'      => 'Str',
    'required' => 1,
);

has 'binary' => (
    'is'      => 'ro',
    'isa'     => 'Str',
    'lazy'    => 1,
    'builder' => '_init_binary',
);

has 'sys' => (
    'is'      => 'rw',
    'isa'     => 'Sys::Run',
    'lazy'    => 1,
    'builder' => '_init_sys',
);

has 'priority' => (
    'is'    => 'ro',
    'isa'   => 'Int',
    'lazy'  => 1,
    'builder' => '_init_priority',
);

with qw(Log::Tree::RequiredLogger);

sub _init_priority { return 0; }

sub _init_sys {
    my $self = shift;

    my $Sys = Sys::Run::->new( { 'logger' => $self->logger(), } );

    return $Sys;
}

# this baseclass just passes the given commands through
sub cmd {
    my @cmd = @_;
    return @cmd;
}

sub _find_binary {
    my $self   = shift;
    my $binary = shift;

    return $self->sys()->check_binary($binary);
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Sys::CmdMod - Abstract base class for command modifier

=method cmd

Subclasses MUST implement this method.

This methods MUST return the command list passed to it.

Subclasses SHOULD prepend their own commands to this list.

=cut
