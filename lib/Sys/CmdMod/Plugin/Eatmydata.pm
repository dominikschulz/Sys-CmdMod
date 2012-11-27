package Sys::CmdMod::Plugin::Eatmydata;
# ABSTRACT: CmdMod plugin for eatmydata

use 5.010_000;
use mro 'c3';
use feature ':5.10';

use Moose;
use namespace::autoclean;

# use IO::Handle;
# use autodie;
# use MooseX::Params::Validate;

use Linux::ForkAsync;

extends 'Sys::CmdMod::Plugin';

has '_init_ok' => (
    'is'      => 'rw',
    'isa'     => 'Bool',
    'default' => 0,
);

sub BUILD {
    my $self = shift;

    if ( -x $self->binary() ) {
        return 1;
    }
    else {
        die( 'Could not find eatmydata executable at ' . $self->binary() );
    }
}

sub _init_binary {
    my $self = shift;

    return $self->_find_binary('eatmydata');
}

sub cmd {
    my $self = shift;
    my $cmd  = shift;

    # we only want sync to be called later if eatmydata was actually used ...
    $self->_init_ok(1);

    return $self->binary() . q{ } . $cmd;
}

sub DEMOLISH {
    my $self = shift;

    # run 'sync' in background
    if ( $self->_init_ok() ) {
        my $FA  = Linux::ForkAsync::->new();
        my $sub = sub {
            sleep 1;
            system('sync');
        };
        $FA->dispatch($sub);
    }

    return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Sys::CmdMod::Plugin::Eatmydata - Abstract base class for command modifier

=method BUILD

Detect binary and initialize this module.

=method DEMOLISH

If this module was successfully initialized in BUILD this will run an async 'sync'.

=method cmd

Return this modules command prefix.

=cut
