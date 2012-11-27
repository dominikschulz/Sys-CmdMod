package Sys::CmdMod;
# ABSTRACT: Command mutators.

use 5.010_000;
use mro 'c3';
use feature ':5.10';

use Moose;
use namespace::autoclean;

# use IO::Handle;
# use autodie;
# use MooseX::Params::Validate;
# use Carp;
use Try::Tiny;

# extends ...
# has ...
# with ...
with 'Config::Tree::OrderedPlugins' => { -version => 0.18 };

sub _plugin_base_class { return 'Sys::CmdMod::Plugin'; }
# initializers ...

# your code here ...
sub cmd {
    my ($self, $cmd) = @_;

    foreach my $Plugin (@{$self->plugins()}) {
        $self->logger()->log( message => 'Executing plugin '.ref($Plugin), level => 'debug', );
        try {
            $cmd = $Plugin->cmd($cmd);
        } catch {
            $self->logger()->log( message => 'Failed to execute plugin '.ref($Plugin).' w/ error: '.$_, level => 'notice', );
        };
    }

    return $cmd;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Sys::CmdMod - Command mutators.

=head1 SYNOPSIS

    use Sys::CmdMod;
    my $Mod = Sys::CmdMod::->new();
    my $cmd = 'echo 1';
    $cmd = $Mod->cmd($cmd);

=head1 SUBROUTINES/METHODS

=head2 cmd

Accumulate all command prefixes.

=cut
