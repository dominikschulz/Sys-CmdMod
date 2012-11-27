package Sys::CmdMod::Plugin::Ionice;
# ABSTRACT: CmdMod plugin for ionice

use 5.010_000;
use mro 'c3';
use feature ':5.10';

use Moose;
use namespace::autoclean;

# use IO::Handle;
# use autodie;
# use MooseX::Params::Validate;

use Version::Compare;

use Sys::Run;
use File::Blarf;

extends 'Sys::CmdMod::Plugin';

has 'priority' => (
    'is'       => 'rw',
    'isa'      => 'Int',
    'default' => 7,
);

has 'class' => (
    'is'       => 'rw',
    'isa'      => 'Int',
    'default' => 3,
);

has 'sysinfo' => (
    'is'      => 'ro',
    'isa'     => 'Linux::Inventory',
    'lazy'    => 1,
    'builder' => '_init_sysinfo',
);

sub _init_binary {
    my $self = shift;

    return $self->_find_binary('ionice');
}

sub BUILD {
    my $self = shift;

    if ( !-x $self->binary() ) {
        die( 'Could not find executable at ' . $self->binary() );
    }

    # check prio = 0-7
    if ( $self->priority < 0 || $self->priority > 7 ) {
        die('Invalid priority given. Must be 0-7.');
    }

    # check class = 0-3
    if ( $self->class < 0 || $self->class > 3 ) {
        die('Invalid class given. Must be 0-3.');
    }

    # check kernel
    my $kernel = $self->_kernel_version();
    if ( $kernel && Version::Compare::version_compare( $kernel, '2.6.13' ) < 0 ) {
        die( 'Running Kernel version (' . $kernel . ') too old to possibly support ionice.' );
    }

    return 1;
}

sub _kernel_version {
    my $proc_version = '/proc/version';
    if ( -f $proc_version ) {
        my $kernel_version = File::Blarf::slurp( $proc_version, { Chomp => 1, } );
        if ( $kernel_version =~ m/^Linux version (\S+) \(/ ) {
            return $1;
        }
    } ## end if ( -f $proc_version )

    return;
}

sub cmd {
    my $self = shift;
    my $cmd  = shift;

    if ( $self->class() == 1 || $self->class() == 2 ) {
        return $self->binary() . ' -c' . $self->class() . ' -n' . $self->priority() . q{ } . $cmd;
    }
    else {
        return $self->binary() . ' -c' . $self->class() . q{ } . $cmd;
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Sys::CmdMod::Plugin::Ionice - ionice support

=method BUILD

Initialize this module.

=method cmd

Prepend the ionice invocation.

=cut
