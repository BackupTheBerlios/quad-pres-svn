#!/usr/bin/perl -w

# use strict;

use Gimp qw(:auto __ N_);
# use Gimp::Fu;
use Cwd;

# The letter height in pixels

Gimp::init();

my $image = gimp_image_new(1024, 256, RGB);

my $layer = 
    gimp_layer_new($image, 1024, 256, RGB_IMAGE, 
        "Text Layer", 100, NORMAL_MODE);

# gimp_path_set_points($image, 
gimp_image_add_layer($image, $layer, -1);

$layer->add_alpha();
# $layer->fill(TRANSPARENT_FILL);
$layer->fill(WHITE_FILL);

gimp_display_new($image);

my $points = 
    [0,0,BEZIER_ANCHOR, 
     $u_pipes_height*2/3, 0, BEZIER_CONTROL,
     $u_pipes_height/3, 0, BEZIER_CONTROL,
     $u_pipes_height, 0, BEZIER_ANCHOR,
    ];

# gimp_path_set_points($image, "Quad Pres Text", 1, scalar(@$points)/3, $points);

gimp_path_import($image, ((Cwd::getcwd())."/quad-pres-path.svg"), 0, 0), 

