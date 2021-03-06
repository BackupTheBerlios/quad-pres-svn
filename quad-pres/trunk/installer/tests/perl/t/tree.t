use strict;
use warnings;

use utf8;

use Test::More tests => 9;

# TEST
use_ok("Shlomif::Quad::Pres");

binmode STDOUT, ":utf8";
{
    my $contents1 = 
    {
        'title' => "Do it with the GIMP",
        'subs' =>
        [
            {
                'url' => "intro",
                'title' => "Introduction",
                'subs' =>
                [
                    {
                        'url' => "history.html",
                        'title' => "History of the GIMP",
                    },
                    {
                        'url' => "future.html",
                        'title' => "Future Directions",
                    },
                    {
                        'url' => "conventions.html",
                        'title' => "Conventions Used in this Lecture",
                    },
                ],
            },
            {
                'url' => "features",
                'title' => "Overview of Features",
                'subs' =>
                [
                    {
                        'url' => "colour_modes.html",
                        'title' => "Colour Modes",
                    },
                    {
                        'url' => "8bit.html",                    
                        'title' => "8 bits per colour value",
                    },
                    {
                        'url' => "rgb_and_hsv",
                        'title' => "RGB and HSV modes",
                        'subs' =>
                        [
                            {
                                'url' => "demo.html",
                                'title' => "Demo",
                            },
                            {
                                'url' => "explanation.html",
                                'title' => "What are RGB and HSV?"
                            },
                            {
                                'url' => "cmyk.html",
                                'title' => "What about CMYK?",
                            },
                        ],
                    },
                    {
                        'url' => "toolbox.html",
                        'title' => "Basic Effects using the Toolbox",
                    },
                    {
                        'url' => "plug_ins.html",
                        'title' => "Plug-ins",
                    },
                    {
                        'url' => "selection",
                        'title' => "Selection and its Usage",
                        'subs' =>
                        [
                            {
                                'url' => "red.html",
                                'title' => "Using the Red \"Paint Selection\" Button",
                            },
                            {
                                'url' => "menu.html",
                                'title' => "The \"&lt;Image&gt; -> Select\" Menu",
                            },
                        ],
                    },
                    {
                        'url' => "layers",
                        'title' => "Layers",
                        'subs' =>
                        [
                            {
                                'url' => 'alpha',
                                'title' => "Alpha",
                                'subs' =>
                                [
                                    {
                                        'url' => "demo1.html",
                                        'title' => "Demo 1",
                                    },
                                    {
                                        'url' => "demo_grad.html",
                                        'title' => "Demo : Using a Gradient as a Layer Mask",
                                    },
                                ],
                            },
                            {
                                'url' => "filters.html",
                                'title' => "Filters and Layers",
                            },
                            {
                                'url' => "modes.html",
                                'title' => "Layer Modes",
                            },
                            {
                                'url' => "gradients.html",
                                'title' => "Gradients",
                            },
                        ],
                    },
                ],
            },
            {
                'url' => "lut",
                'title' => "LUT (Look-Up Tables Effects)",
                'subs' =>
                [
                    {
                        'url' => "brightness_and_contrast",
                        'title' => "Brightness and Contrast",
                        'subs' =>
                        [
                            {
                                'url' => "answer.html",
                                'title' => "Answer",
                            },
                            {
                                'url' => "demo.html",
                                'title' => "Demonstration",
                            },
                        ],
                    },
                    {
                        'url' => "gamma_correction",
                        'title' => "Gamma Correction",
                        'subs' =>
                        [
                            {
                                'url' => "concept.html",
                                'title' => "Concept",
                            },
                            {
                                'url' => "demo.html",
                                'title' => "Demonstration",
                            },
                        ],
                    },
                    {
                        'url' => "equalize.html",
                        'title' => "Equalize",
                    },
                    {
                        'url' => "color_map_rotation.html",
                        'title' => "Color Map Rotation",
                    },
                    {
                        'url' => "color_balance.html",
                        'title' => "Color Balance",
                    },
                    {
                        'url' => "more_luts.html",
                        'title' => "More LUTs",
                    },
                ],
            },
            {
                'url' => "areal",
                'title' => "Basic Areal Effects",
                'subs' =>
                [
                    {
                        'url' => "blur",
                        'title' => "Blur",
                        'subs' =>
                        [
                            {
                                'url' => "answer.html",
                                'title' => "Answer to how one can blur an image",
                            },
                            {
                                'url' => "demo.html",
                                'title' => "Demo of a simple blur",
                            },
                            {
                                'url' => "gaussian",
                                'title' => "Gaussian Blur",
                                'subs' =>
                                [
                                    {
                                        'url' => "iir_rle.html",
                                        'title' => "IIR vs. RLE Gaussian Blurs",
                                    },
                                    {
                                        'url' => "demo_iir.html",
                                        'title' => "Demo of IIR Gauss. Blur",
                                    },
                                    {
                                        'url' => "demo_rle.html",
                                        'title' => "Demo of RLE Gauss. Blur",
                                    },
                                ],
                            },
                        ],
                    },
                    {
                        'url' => "sharpen",
                        'title' => "Sharpening &amp; Marpening",
                        'subs' =>
                        [
                            {
                                'url' => "answer.html",
                                'title' => "Answer to how one can sharpen",
                            },
                            {
                                'url' => "demo.html",
                                'title' => "Sharpening Demo",
                            },
                        ],
                    },
                    {
                        'url' => "motion_blur",
                        'title' => "Motion Blur",
                        'subs' =>
                        [
                            {
                                'url' => "answer.html",
                                'title' => "Answer to how one can motion blur",
                            },
                            {
                                'url' => "demo.html",
                                'title' => "Demo",
                            }
                        ],
                    },
                ],
            },
            {
                'url' => "areal_transforms",
                'title' => "Basic Areal Transformations",
                'subs' =>
                [
                    {
                        'url' => "scaling",
                        'title' => "Scaling an Image",
                        'subs' =>
                        [
                            {
                                'url' => "interpolation.html",
                                'title' => "Interpolation",
                            },
                        ],
                    },
                    {
                        'url' => "transform_tool",
                        'title' => "The Rotate/Scale/Perspective Tool",
                        'subs' =>
                        [
                            {
                                'url' => 'demo.html',
                                'title' => "Demo",
                            },
                        ],
                    },
                ],
            },
            {
                'url' => "cool_effects",
                'title' => "Some Cool Effects",
                'subs' =>
                [
                    {
                        'url' => "gradient_map",
                        'title' => "Gradient Map",
                        'subs' =>
                        [
                            {
                                'url' => "demo1.html",
                                'title' => "Demo 1 : Real-life picture",
                            },
                            {
                                'url' => "demo2.html",
                                'title' => "Demo 2 : Text Caption",
                            },
                        ],
                    },
                    {
                        'url' => "fractal_explorer.html",
                        'title' => "Fractal Explorer",
                    },
                ],
            },
            {
                'url' => "photo2painting",
                'title' => "Turning a Photograph into a Painting",
                'subs' =>
                [
                    {
                        'url' => "oilify.html",
                        'title' => "Oilify",
                    },
                    {
                        'url' => "gimpressionist.html",
                        'title' => "Gimpressionist",
                    },
                ],
            },
            {
                'url' => "scripting",
                'title' => "Scripting the GIMP",
                'subs' =>
                [
                    {
                        'url' => "pdb.html",
                        'title' => "The Procedural Database",
                    },   
                    {
                        'url' => "script-fu",
                        'title' => "Script-Fu Scripting",
                        'subs' =>
                        [
                            {
                                'url' => "demo.html",
                                'title' => "Interactive Demo",
                            },
                            {
                                'url' => "generating_logo.html",
                                'title' => "Generating a Logo",
                            },                           
                        ],
                    },
                    {
                        'url' => "gimp-perl.html",
                        'title' => "Gimp-Perl Scripting",
                    },
                    {
                        'url' => "plug-ins.html",
                        'title' => "GIMP (C-based) Plug-ins",
                    },
                ],
            },
            {
                'url' => "finale",
                'title' => "Finale",
                'subs' =>
                [
                    {
                        'url' => "links.html",
                        'title' => "References and Links",
                    },
                    {
                        'url' => "images.html",
                        'title' => "Origins and Copyrights of the Images",
                    },
                ],
            },
        ],
        'images' => 
        [ 
            'style.css',
        ],
    };
    
    {
        my $qp = Shlomif::Quad::Pres->new(
            $contents1,
            'doc_id' => 'intro/',
            'mode' => "server",
        );
        # TEST
        ok ($qp, "A Quad-Pres instance was initialized."); 

        my $next_url = $qp->get_control_url($qp->get_next_url());
        # TEST
        is(
            $next_url,
            "history.html", 
            "next OK"
        ); 

        my $prev_url = $qp->get_control_url($qp->get_prev_url());
        is($prev_url, "../", "prev OK"); # TEST
    }

    {
        my $qp = Shlomif::Quad::Pres->new(
            $contents1,
            'doc_id' => 'features/colour_modes.html',
            'mode' => "server",
        );

        # TEST
        ok ($qp, "A Quad-Pres instance was initialized. (No. 2)"); 

        # TEST
        is ($qp->get_breadcrumbs_trail(),
            q{<a href="./../">Do it with the GIMP</a> → <a href="./">Overview of Features</a> → <a href="./colour_modes.html">Colour Modes</a>},
            "Testing the breadcrumbs trail",
        );
    }

    {
        my $qp = Shlomif::Quad::Pres->new(
            $contents1,
            'doc_id' => 'areal/sharpen/',
            'mode' => "server",
        );

        # TEST
        ok ($qp, "A Quad-Pres instance was initialized. (No. 3)"); 

        # TEST
        is ($qp->get_breadcrumbs_trail(" → "),
            q{<a href="../../">Do it with the GIMP</a> → <a href="../">Basic Areal Effects</a> → <a href="./">Sharpening &amp; Marpening</a>},
            "Testing the breadcrumbs trail",
        );

        # TEST
        is ($qp->get_breadcrumbs_trail(" ← "),
            q{<a href="../../">Do it with the GIMP</a> ← <a href="../">Basic Areal Effects</a> ← <a href="./">Sharpening &amp; Marpening</a>},
            "Testing the breadcrumbs trail",
        );        
    }
}
