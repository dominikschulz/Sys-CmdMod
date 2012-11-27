package Sys::CmdMod::Plugin::Nice;
# ABSTRACT: CmdMod Plugin for nice

use 5.010_000;
use mro 'c3';
use feature ':5.10';

use Moose;
use namespace::autoclean;

# use IO::Handle;
# use autodie;
# use MooseX::Params::Validate;

extends 'Sys::CmdMod::Plugin';

has 'priority' => (
    'is'       => 'rw',
    'isa'      => 'Num',
    'default'  => 19,
);

sub BUILD {
    my $self = shift;

    if ( !-x $self->binary() ) {
        die( 'Could not find nice executable at ' . $self->binary() );
    }
}

sub _init_binary {
    my $self = shift;

    return $self->_find_binary('nice');
}

sub cmd {
    my $self = shift;
    my $cmd  = shift;
    return $self->binary() . ' -n ' . $self->priority() . q{ } . $cmd;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Sys::CmdMod::Plugin::Nice - nice processes

=head1 METHODS

=head2 BUILD

Initialize this module.

=head2 cmd

Prepend the nice invocation.

=cut
