#!/usr/bin/perl -w

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

package main;

use strict;

use SVG;

# Definitions:

my $letter_height = 100 ;

my $u_arc_height = int($letter_height/4);

my $u_pipes_height = $letter_height - $u_arc_height;

my $u_width = int($letter_height * 1);

my $path = SVG::Path->new();

sub gen_u
{
    my $curve_len = $u_arc_height * 2;
    $path->line_down($u_pipes_height);
    $path->bezier_rel(0,$curve_len,$u_width,$curve_len,$u_width,0);
    $path->line_up($u_pipes_height);
}

sub gen_path
{
    $path->move_rel(10,10);
    gen_u();
    return join("", map { "$_ " } @{$path->get_commands()});
}

my $svg = SVG->new(width => 1024, height => 256);

my $svg_path = 
    $svg->path(
        id => "quadpres",
        style => 
        {
            'fill-opacity' => 0,
            'fill-color'   => 'green',
            'stroke-color' => 'rgb(250,123,23)'
        },
        d => gen_path(),
    );

print $svg->xmlify();

