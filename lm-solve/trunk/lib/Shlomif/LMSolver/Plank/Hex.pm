package Shlomif::LMSolver::Plank::Hex;

use strict;

use vars qw(@ISA);

use Shlomif::LMSolver::Plank::Base;

@ISA=qw(Shlomif::LMSolver::Plank::Base);

sub initialize
{
    my $self = shift;

    $self->SUPER::initialize(@_);

    $self->{'dirs'} = [qw(E W S N SE NW)];
}

1;

