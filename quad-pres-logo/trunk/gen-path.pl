#!/usr/bin/perl -w

use strict;

use SVG;

# Definitions:

my $letter_height = 100 ;

my $u_arc_height = int($letter_height/4);

my $u_pipes_height = $letter_height - $u_arc_height;

my $u_width = int($letter_height * 1);

my @offset = (0,0);

sub line_rel
{
    my ($x,$y) = @_;
    my $ret = "l$x,$y ";
    $offset[0] += $x;
    $offset[1] += $y;
    return $ret;
}

sub line_down
{
    my $len = shift;
    return line_rel(0,$len);
}

sub line_up
{
    my $len = shift;
    return line_down(-$len);
}

sub gen_u
{
    my $curve_len = $u_arc_height * 2;
    return line_down($u_pipes_height) ."c0,$curve_len $u_width,$curve_len $u_width,0 " . line_up($u_pipes_height);
}

sub gen_path
{
    return "m10,10 . " . gen_u();
}

my $svg = SVG->new(width => 1024, height => 256);

my $path = 
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

