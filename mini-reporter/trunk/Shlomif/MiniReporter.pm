package Shlomif::MiniReporter;

use strict;
use DBI;
use Template;
# Inherit from CGI::Application.
use base 'CGI::Application';
use MyConfig;

use WWW::Form;

use WWW::FieldValidator;

my %modes = 
(
    'main' => 
    {
        'url' => "/",
        'func' => "main_page",
    },
    'add' =>
    {
        'url' => "/add/",
        'func' => "add_form",
    },
    'search' =>
    {
        'url' => "/search/",
        'func' => "search_results",
    },
    'css' =>
    {
        'url' => "/style.css",
        'func' => "css_stylesheet",
    },
    'admin' =>
    {
        'url' => "/admin/",
        'func' => "admin_screen",
    },
);

my %urls_to_modes = (map { $modes{$_}->{'url'} => $_ } keys(%modes));

sub setup
{
    my $self = shift;

    $self->initialize($MyConfig::config);

    $self->start_mode("main");

    $self->run_modes(
        (map { $_ => $modes{$_}->{'func'}, } keys(%modes)),
        # Remmed out:
        # I think of deprecating it because there's not much difference
        # between it and add.
        # "add_form" => "add_form",
        'redirect_to_main' => "redirect_to_main",
        'correct_path' => "correct_path",
    );
}

sub redirect_to_main
{

}

sub correct_path
{
    my $self = shift;

    my $path = $self->get_path();

    $path =~ m#([^/]+)/*$#;

    my $last_component = $1;

    # This is in case we were passed the script name without a trailing /
    # in which case the last component would be undefined. So consult
    # the request uri.
    if (!defined($last_component))
    {
        # Extract the Request URI
        my $request_uri = $ENV{REQUEST_URI} || "";
        $request_uri =~ m#([^/]+)/*$#;
        $last_component = $1;
        if (!defined($last_component))
        {
            $last_component = "";
        }
    }

    $self->header_type('redirect');
    $self->header_props(-url => "./$last_component/");
}

sub get_path
{
    my $self = shift;

    my $q = $self->query();

    my $path = $q->path_info();

    return $path;
}

sub cgiapp_prerun
{
    my $self = shift;

    my $path = $self->get_path();

    if ($path =~ /\/\/$/)
    {
        $self->prerun_mode("correct_path");
        return;
    }

    my $mode = $urls_to_modes{$path};

    if (!defined($mode))
    {
        my $slash_mode = $urls_to_modes{"$path/"};
        if (defined($slash_mode))
        {
            $self->prerun_mode("correct_path");
            return;
        }
        $self->prerun_mode("redirect_to_main");
    }

    $self->prerun_mode($mode);
}

sub initialize
{
	my $self = shift;
	
    my $config = shift;
	$self->{'config'} = $config; 

    my $tt = Template->new(
        {
            'BLOCKS' => 
                {
                    'main' => $config->{'record_template'},
                },
        },
    );

    $self->{'record_tt'} = $tt;

	return 0;
}

sub get_record_template_gen
{
    my $self = shift;

    return $self->{record_tt};
}

sub linux_il_header
{
    my $self = shift;
	my $title = shift;
	my $header = shift;
    my $path = $self->get_path();
	
	my ($ret, $title1, $title2);
	
	if ($title)
	{
		$title1 = "<title>" . $title . "</title>\n";
	}
	else
	{	
		$title1 = "";
	}
	
	if ($header)
	{	
		$title2 = "<h1>" . $header . "</h1>\n";
	}
	else
	{
		$title2 = "";
	}

    my $path2 = $path;

    $path2 =~ s/^\///;

    my @css_path_components = (map { "../" } split(/\//, $path2));

    my $css_path = join("", @css_path_components);

	$ret .= <<"EOF"
<!DOCTYPE html
    PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<?xml version="1.0" encoding="iso-8859-1"?>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en-US" lang="en-US">
<head>
$title1
<link rel="stylesheet" href="./${css_path}style.css" type="text/css" />
</head>
<body>
<p>
<a href="/" title="Back to the IGLU Homepage"><img 
    src="/images/IGLU-banner.jpg" 
    width="499" height="86" 
    alt="IGLU - Israeli Group of Linux Users" 
    style="border : 0" /></a>
</p>
<p style="margin-bottom : 2em">[<a href="/">Home</a> |
<a href="/IGLU/">News</a> |
<a href="/about.shtml">About</a> |
<a href="/faq/">FAQ</a> |
<a href="/mailing-lists/">Mailing Lists</a> |
<a href="/events/">Events</a> |
<a href="/faq/cache/52.html">Help!</a> |
<a href="/faq/cache/8.html">Hebrew</a>]</p>

$title2	
EOF
	;
	
	return $ret;
}

sub linux_il_footer
{
    my $ret;
    
    $ret .= <<'EOF';
<hr />
<div class="footer">
<p>For more info or
for website remarks mail the 
<a href="mailto:webmaster@iglu.org.il"><em>webmasters</em></a>.
</p>
<p>
All Trademarks and copyrights are owned by their respective owners, Linux is a Tradmark of Linus Torvalds.
</p>
<p>
The information contained herein is CopyLeft IGLU, you are granted permission to
copy it and distribute it.
</p>
</div>
</body>
</html>
EOF

	;
    
    return $ret;
}

sub main_page
{
    my $self = shift;

    my $ret = "";
    my $config = $self->{'config'};
    
    my $title = $config->{'strings'}->{'main_title'};
    
    $ret .= $self->linux_il_header($title, $title);
    
    $ret .= <<'EOF'
<h3>Search the Database</h3>

<form action="./search/" method="post">

<p>Area: 
<select name="area">
<option selected="selected">All</option>
EOF

    ;

    foreach my $area (@{$config->{'areas'}})
    {
    	$ret .= ( "<option>" . $area . "</option>\n");
    }

    $ret .= <<'EOF';
</select>
</p>
<p>
Keyword from description: <input name="keyword" />
</p>
<p>
<input type="submit" value="Search" />
</p>
</form>
EOF
	;

    $ret .= "<ul>\n";
    $ret .= "<li><a href=\"./search/?all=1\">" . $config->{'strings'}->{'show_all_records_text'} . "</a></li>\n";
    $ret .= "<li><a href=\"./add/\">" . $config->{'strings'}->{'add_a_record_text'} . "</a></li>\n";
    $ret .= "<li><a href=\"./remove/\">" . $config->{'strings'}->{'remove_a_record_text'} . "</a></li>\n" ;
    $ret .= "</ul>\n";

    $ret .= linux_il_footer();

    return $ret;
}

sub htmlize
{
	my $string = shift || "";
	
	my $char_convert = 
	sub {
		my $char = shift;
        my $ascii = ord($char);
		
		if ($char eq '&')
		{
			return "&amp;";
		}
		elsif ($char eq '>')
		{
			return "&gt;";
		}
		elsif ($char eq '<')
		{
			return "&lt;";
        }
        elsif ($ascii > 127)
        {
            return sprintf("&#x%.4x;", $ascii);
        }
	};

	$string =~ s/([&<>\x80-\xFF])/$char_convert->($1)/ge;
	
	$string =~ s/\n\r?/<br \/>\n/g;
	
	return $string;
}

sub render_record
{
    my $self = shift;

    my $ret = "";
    my %args = (@_);

    my $config = $self->{config};
    my $values = $args{'values'};
    my $fields = $args{'fields'};

    my $vars = { map { $fields->[$_] => htmlize($values->[$_]) } (0 .. $#$values)};
        
    $self->get_record_template_gen()->process('main', $vars, \$ret);

    return $ret;
}

sub get_field_names
{
    my $self = shift;

    my $config = $self->{config};
    
    my @field_names = ("area", "id", (map { $_->{'sql'} } @{$config->{'fields'}}));

    return \@field_names;
}

=head2 $self->display_records(%args)

Accepts the following optional parameters:

    all_records - if set, display all records (by default only active ones)
    keyword - a keyword to search for.
    area_choice - an area to choose for (or All for all areas)
    toolbox - display the toolbox of admining a record (defaults to 0)
    show_disabled - show disabled records as well.
    show_enabled - show enabled records as well.
=cut

sub display_records
{
    my $self = shift;

    my %args = (@_);

    my $all_param = $args{'all_records'} || "";

    my $keyword_param = $args{'keyword'} || "";

    my $area_param = $args{'area_choice'} || "";

    my $display_toolbox = $args{'toolbox'} || 0;

    my $config = $self->{'config'};
    
    my $conn = DBI->connect($config->{'dsn'});

    my @area_list = @{$config->{'areas'}};
    
    my $ret = "";

    my ($where_clause_template, @areas);

    my %does_area_exists_map = (map { $_ => 1} @area_list);

    if ($all_param eq "1")
    {
    	$where_clause_template = "WHERE status=1";
    	
    	@areas = @area_list;
    }
    else
    {
    	if ($keyword_param =~ /^\s*$/) {
    		$where_clause_template = "WHERE status=1";
    	}
    	else
    	{
    		$keyword_param =~ s/'/ /g;

    		my (@search_clauses);

    		foreach my $field (@{$config->{'fields'}})
    		{
    			push @search_clauses, "(" . $field->{'sql'} . " LIKE '%" . $keyword_param
    			. "%')";
    		}

    		$where_clause_template = "WHERE status=1 AND (" . join(" OR ", @search_clauses) . ")";
    	}

    	if ($area_param eq 'All')
    	{
    		@areas = @area_list;
    	}
    	else
    	{
    		@areas = $area_param;
    	}
    }


    $ret .= $self->linux_il_header("Search Results", "Search Results");

    my $field_names = $self->get_field_names();

    push @$field_names, ('status');

    my $query_str = "SELECT " . join(", ", @$field_names).  
                    " FROM " . $config->{'table_name'} . 
    		" " . $where_clause_template . 
    		(" ORDER BY " . ($config->{'order_by'} || "id DESC"));

    my $sth = $conn->prepare($query_str);

    $sth->execute();

    my (%areas_jobs);

    foreach my $a (@area_list)
    {
    	$areas_jobs{$a} = [ ];
    }

    my ($string);

    my $field_names_with_usability_additions = [ @$field_names ];

    if ($display_toolbox)
    {
        push @$field_names_with_usability_additions, 'toolbox';
    }

    my $values;

    while ($values = $sth->fetchrow_arrayref())
    {
        my $string = 
            $self->render_record(
                'values' => ($display_toolbox ? [@$values, 1] : \@$values),
                'fields' => $field_names_with_usability_additions,
            );

        push @{$areas_jobs{$values->[0]}}, $string;
    }

    AREA_LOOP: foreach my $area (@areas)
    {
        # Check if the area is a valid one and if not skip this 
        # iteration.
        if (!exists($does_area_exists_map{$area}))
        {
            next AREA_LOOP;
        }
    	$ret .= "<h2>" . $area . "</h2>\n\n";

    	$ret .= join("", @{$areas_jobs{$area}});
    }

    $ret .= linux_il_footer();

    $conn->disconnect();

    return $ret;
}

sub search_results
{
    my $self = shift;

    my $q = $self->query();

    my $all_param = $q->param("all") || "";

    my $keyword_param = $q->param("keyword") || "";

    my $area_param = $q->param("area") || "";

    return $self->display_records(
        'all_records' => $all_param,
        'keyword' => $keyword_param,
        'area_choice' => $area_param,
    );
}

sub get_form_fields
{
    my $self = shift;

    my $q = $self->query();

    my $config = $self->{config};

    my %fields = ();

    my $field_idx = 0;

    my $get_alternate_style = sub {
        my $ret = (($field_idx % 2 == 1) ? "hilight" : "hilight2");

        $field_idx++;
        
        return $ret;
    };

    my $get_attribs = sub {
        my $class = $get_alternate_style->();
        return ('container_attributes' => 
                { 'class' => $class, },
                'hint_container_attributes' => 
                { 'class' => "$class space", },
               );
    };
   
    $fields{area} = {
        label => "Area",
        defaultValue => "Tel Aviv",
        type => 'select',
        optionsGroup => [
            map { +{ 'label' => $_, 'value' => $_, }, } @{$config->{'areas'}},
        ],
        validators => [],
        $get_attribs->(),
        hint => ("The area in Israel of the employing firm.<br />" . 
                "If the work is from home, select the area of the office."),
    };

    # Number of characters for the input tag or textarea to be as wide;
    my $input_length = 40;
    my $input_height = 10;

    

    foreach my $f (@{$config->{fields}})
    {
        if ($f->{'gen'}->{'auto'})
        {
            next;
        }

        $fields{$f->{sql}} = 
        {
            label => $f->{'pres'},
            defaultValue => ($q->param($f->{sql}) || ""),
            type => ($f->{sameline} ? "text" : "textarea"),
            validators => 
            [ 
                ($f->{sameline} ? 
                (
                    WWW::FieldValidator->new(WWW::FieldValidator::REGEX_MATCH,
                    "No newlines allowed",
                    '^([^\n\r]*)$'
                    ), 
                ): 
                ()),
                ($f->{len} ?
                (
                    WWW::FieldValidator->new(
                        WWW::FieldValidator::MAX_STR_LENGTH,
                        "$f->{pres} is limited to $f->{len} characters",
                        $f->{len}
                    ),
                ) :
                ()),
            ],
            extraAttributes => 
                ($f->{sameline} ? 
                    " size=\"$input_length\" " :
                    " cols=\"$input_length\" rows=\"$input_height\""
                ),
            # Give the hint if it exists
            (exists($f->{hint}) ? (hint => $f->{hint}) : ()),
            # Highlight the odd numbered fields
            $get_attribs->(),
        };
    }

    return \%fields;
}

sub get_form_fields_sequence
{
    my $self = shift;

    my $config = $self->{config};

    my @ret;

    # Don't forget to put the area - otherwise WWW::Form won't display it.
    push @ret, 'area';
    
    foreach my $f (@{$config->{fields}})
    {
        if ($f->{'gen'}->{'auto'})
        {
            next;
        }
        push @ret, $f->{sql};
    }
    
    return \@ret;
}

sub get_form
{
    my $self = shift;
    my $q = $self->query();

    my $form = 
        WWW::Form->new(
            $self->get_form_fields(),
            $q->{Vars},
            $self->get_form_fields_sequence(),
        );

    return $form;
}

sub get_form_html
{
    my $self = shift;

    my $form = shift;

    my $params = shift;

    my $ret = "";

    $ret .= "<p class=\"warning\"><b>Note:</b> all entries must be in English.".
            "(or else they won't be displayed correctly</p>";

    $ret .= $form->get_form_HTML(@$params);

    return $ret;
}

sub add_form
{
    my $self = shift;

    my $q = $self->query();

    # return join("\n<br />\n", (map { "$_ = " . $q->param($_) } $q->param()));
    
    my $config = $self->{config};

    my $id = 0;

    # Prepare the insert statement

    my (@values, @field_names);

    foreach my $a (@{$config->{'fields'}})
    {
    	push @field_names, $a->{'sql'};
        my $v;
        if (exists($a->{'gen'}))
        {
            $v= $a->{'gen'}->{callback}->($q->param($a->{'sql'}));
        }
        else
        {
    	    $v = $q->param($a->{'sql'});
        }
        push @values, $v;
    }

    my $ret = "";

    my $form = $self->get_form();

    $form->validate_fields();
    
    my $valid_params = $form->is_valid();

    my $no_cgi_params = (scalar($q->param()) ? 0 : 1);

    if ($q->param('preview') || (! $valid_params) || $no_cgi_params)
    {
        if ($no_cgi_params)
        {
            $ret .= $self->linux_il_header("Add a job to the Linux-IL jobs' list", "Add a job");
        }
        elsif ($valid_params)
        {
            $ret .= $self->linux_il_header($config->{'strings'}->{'preview_result_title'}, "Preview the Added Record");
        }
        else
        {
            $ret .= $self->linux_il_header("Invalid Parameters Entered", 
            "Invalid Paramterers Entered");
        }

        if (! $no_cgi_params)
        {
            $ret .= 
                $self->render_record(
                    'fields' => \@field_names,
                    'values' => \@values,
                );
        }

        $ret .= $self->get_form_html($form,
            [
                'buttons' =>
                [
                    {
                        submit_label => "Preview", 
                        action => './add.pl',
                        submit_name => "preview",
                        submit_class => "preview",
                    },
                    (($valid_params && ! $no_cgi_params)?
                    ({
                        submit_label => "Submit",
                        action => './add.pl',
                        submit_name => "submit",
                    },) :
                    (),
                    )
                ],
                attributes => { 'class' => "myform" },
            ]
         );
    }
    else
    {
        $ret .= $self->linux_il_header($config->{'strings'}->{'add_result_title'}, "Success");

        my $conn = DBI->connect($config->{'dsn'});
        my $query_str = "INSERT INTO " . $config->{'table_name'} . 
            " (" . join(",", "id", "status", "area", @field_names) . ") " .
            " VALUES ($id, 1, '" . $q->param("area") . "'," .  join(",", (map { $conn->quote($_); } @values)) . ")";

        $conn->do($query_str);

        $conn->disconnect();

        $ret .= <<'EOF';
The job was added to the database.<br>
<br>
EOF
        ;
        
        $ret .= "<a href=\"../\">" . $config->{'strings'}->{'add_back_link_text'} . "</a>\n";
    }   

    $ret .= linux_il_footer();

    return $ret;
}

sub css_stylesheet
{
    my $self = shift;

    local (*I);
    open I, "<style.css";
    $self->header_props(-type => "text/css");
    my $output = join("", <I>);
    close(I);
    
    return $output;
}

sub admin_screen
{
    my $self = shift;

    return $self->display_records(
       'all_records' => 1,
       'toolbox' => 1,
    );
}

1;


