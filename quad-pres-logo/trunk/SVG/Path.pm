package SVG::Path;

use strict;

sub new
{
    my $class = shift;
    my $self = {};
    bless $self, $class;
    $self->initialize(@_);
    return $self;
}

sub initialize
{
    my $self = shift;
    my %args = (@_);

    $self->{coords} = [($args{x} || 0), ($args{y} || 0)];
    $self->flush_commands();
    return $self;
}

sub _add_offset
{
    my $self = shift;
    my (@off) = (@_);
    for my $i ( 0 .. 1)
    {
        $self->{coords}->[$i] += $off[$i];
    }
}

sub _add_cmd
{
    my $self = shift;
    my $cmd = shift;

    push @{$self->{cmds}}, $cmd;
    return $cmd;
}

sub get_coords
{
    my $self = shift;

    return [ @{$self->{coords}} ];
}

sub get_commands
{
    my $self = shift;

    return [ @{$self->{cmds}} ];
}

sub flush_commands
{
    my $self = shift;
    $self->{cmds} = [];
}

sub line_rel
{
    my $self = shift;
    my (@off) = (@_); # The offset
    my $ret = "l$off[0],$off[1]";
    $self->_add_offset(@off);
    return $self->_add_cmd($ret);
}

sub line_down
{
    my $self = shift;
    my $len = shift;
    return $self->line_rel(0, $len);
}

sub line_up
{
    my $self = shift;
    my $len = shift;
    return $self->line_down(-$len);
}

sub move_rel
{
    my $self = shift;
    my (@off) = (@_); # The offset
    my $ret = "m$off[0],$off[1]";
    $self->_add_offset(@off);
    return $self->_add_cmd($ret);
}

sub bezier_rel
{
    my $self = shift;
    my (@off) = (@_); # The offsets
    my $cmd = "c$off[0],$off[1] $off[2],$off[3] $off[4],$off[5]";
    $self->_add_offset(@off[4..5]);
    return $self->_add_cmd($cmd);
}

1;

