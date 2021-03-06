#!/usr/bin/perl -w

use strict;

use SVG;
use SVG::Path;

# Definitions:

my $letter_height = 100 ;

my $u_arc_height = int($letter_height/4);

my $u_pipes_height = $letter_height - $u_arc_height;

my $u_width = int($letter_height * 1);

my $large_letter_height = int($letter_height*1.5);

my $path = SVG::Path->new();

sub gen_Q
{
    my $curve_len = int($letter_height / 2);
    my @init_off = @{$path->get_coords()};
    # Move to the line base.
    $path->move_rel(0, $large_letter_height);
    $path->bezier_rel(-$curve_len, 0, -$curve_len, -$large_letter_height, 0, -$large_letter_height);
    $path->bezier_rel($curve_len, 0, $curve_len, $large_letter_height, 0, $large_letter_height);
    $path->line_rel(int($letter_height / 2), 0);
    my @last_off = @{$path->get_coords()};
    # Move to the next letter.
    $path->move_rel(int($letter_height / 2), $init_off[1]-$last_off[1]);
}

sub gen_u
{
    my @init_off = @{$path->get_coords()};
    $path->move_rel(0, $large_letter_height-$letter_height);
    $path->line_down($u_pipes_height);
    my @curve_off = ($u_width/2,$u_arc_height);
    # $path->bezier_rel(0,$curve_len,$u_width,$curve_len,$u_width,0);
    $path->bezier_rel(0,$curve_off[1],$u_width/2-$curve_off[0], $u_arc_height,$u_width/2, $u_arc_height);
    $path->bezier_rel($curve_off[0], 0, $u_width/2, -($u_arc_height-$curve_off[1]),$u_width/2,-$u_arc_height);
    $path->line_up($u_pipes_height);
    my @last_off = @{$path->get_coords()};
    $path->move_rel(int($letter_height / 2) , $init_off[1]-$last_off[1]);
}

sub gen_path
{
    $path->move_rel(100,10);
    gen_Q();
    gen_u();
    return join("", map { "$_ " } @{$path->get_commands()});
}

my $svg = SVG->new(width => 1024, height => 256, style=> "fill : white",);

my $svg_path = 
    $svg->path(
        id => "quadpres",
        style => 
        {
            'stroke' => 'green',
            'fill' => "none",
            'stroke-width' => 10.375,
        },
        d => gen_path(),
    );

print $svg->xmlify();

