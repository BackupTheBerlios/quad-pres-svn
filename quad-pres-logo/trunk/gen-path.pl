#!/usr/bin/perl -w

use strict;

use SVG;
use SVG::Path;

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
            'stroke' => 'green',
            'fill' => "none",
            'stroke-width' => 10.375,
        },
        d => gen_path(),
    );

print $svg->xmlify();

