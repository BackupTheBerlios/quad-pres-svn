package Shlomif::MiniReporter;

use strict;
use DBI;
use Template;
use WWW::Form;

use WWW::FieldValidator;

sub initialize
{
	my $self = shift;
	
    my $config = shift;
	$self->{'config'} = $config; 
	$self->{'cgi'} = shift;

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

sub new 
{
	my $class = shift;
	my $self = {};
	
	bless($self, $class);
	
	$self->initialize(@_);
	
	return $self;	
}

sub linux_il_header
{
	my $title = shift;
	my $header = shift;
	
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

	$ret .= <<"EOF"
<!DOCTYPE html
    PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<?xml version="1.0" encoding="iso-8859-1"?>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en-US" lang="en-US">
<head>
$title1
<link rel="stylesheet" href="./style.css" type="text/css" />
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
<div style = "font-size : smaller">
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
    
    $ret .= linux_il_header($title, $title);
    
    $ret .= <<'EOF'
<h3>Search the Database</h3>

<form action="search.pl" method="post">

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

    $ret .= "<p><a href=\"search.pl?all=1\">" . $config->{'strings'}->{'show_all_records_text'} . "</a><br />\n";
    $ret .= "<a href=\"add_form.pl\">" . $config->{'strings'}->{'add_a_record_text'} . "</a></p>";

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
    
    my @field_names = ("area", (map { $_->{'sql'} } @{$config->{'fields'}}));

    return \@field_names;
}

sub search_results
{
    my $self = shift;

    my %config = %{$self->{'config'}};
    
    my $conn = DBI->connect($config{'dsn'});

    my $q = $self->{'cgi'};

    my @area_list = @{$config{'areas'}};
    
    my $ret = "";

    my ($where_clause_template, @areas);

    my $all_param = $q->param("all") || "";

    if ($all_param eq "1")
    {
    	$where_clause_template = "WHERE status=1";	
    	
    	@areas = @area_list;
    }
    else
    {
        my $keyword_param = $q->param("keyword") || "";
    	if ($keyword_param =~ /^\s*$/) {
    		$where_clause_template = "WHERE status=1";
    	}
    	else
    	{
    		my $keyword = $q->param("keyword");
    		
    		$keyword =~ s/'/ /g;

    		my (@search_clauses);

    		foreach my $field (@{$config{'fields'}})
    		{
    			push @search_clauses, "(" . $field->{'sql'} . " LIKE '%" . $keyword
    			. "%')";
    		}

    		$where_clause_template = "WHERE status=1 AND (" . join(" OR ", @search_clauses) . ")";
    	}

        my $area_param = $q->param("area") || "";
    	
    	if ($area_param eq 'All')
    	{
    		@areas = @area_list;
    	}
    	else
    	{
    		@areas = $q->param("area");
    	}
    }


    $ret .= linux_il_header("Search Results", "Search Results");

    my $field_names = $self->get_field_names();

    my (@values);
    my $query_str = "SELECT " . join(", ", @$field_names).  
                    " FROM " . $config{'table_name'} . 
    		" " . $where_clause_template . 
    		(" ORDER BY " . ($config{'order_by'} || "id DESC"));

    my $query = $conn->prepare($query_str);

    $query->execute();

    my (%areas_jobs);

    foreach my $a (@area_list)
    {
    	$areas_jobs{$a} = [ ];
    }

    my ($string);

    while (@values = $query->fetchrow_array())
    {
        my $string = 
            $self->render_record(
                'values' => \@values,
                'fields' => $field_names,
            );

        push @{$areas_jobs{$values[0]}}, $string;
    }

    foreach my $area (@areas)
    {
    	$ret .= "<h2>" . $area . "</h2>\n\n";

    	$ret .= join("", @{$areas_jobs{$area}});
    }

    $ret .= linux_il_footer();

    $conn->disconnect();

    return $ret;

}

sub get_form_fields
{
    my $self = shift;

    my $q = $self->{cgi};

    my $config = $self->{config};

    my %fields = ();

    $fields{area} = {
        label => "Area",
        defaultValue => "Tel Aviv",
        type => 'select',
        optionsGroup => [
            map { +{ 'label' => $_, 'value' => $_, }, } @{$config->{'areas'}},
        ],
        validators => [],
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
        };
    }

    return \%fields;
}

sub get_form_fields_sequence
{
    my $self = shift;

    my $config = $self->{config};

    my @ret;
    
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
    my $q = $self->{cgi};

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

    my $ret = "";

    my %config = %{$self->{'config'}};

    $ret .= linux_il_header("Add a job to the Linux-IL jobs' list", "Add a job");
    
    my $form = $self->get_form();

    $ret .= $self->get_form_html($form, 
        [
            submit_label => "Preview", 
            action => './add.pl',
            submit_name => "preview",
            submit_class => "preview",
            attributes => { 'class' => "myform" },
        ]
    );

    $ret .= linux_il_footer();

    return $ret;
}

sub add_post
{
    my $self = shift;

    my $q = $self->{'cgi'};

    # return join("\n<br />\n", (map { "$_ = " . $q->param($_) } $q->param()));
    
    my %config = %{$self->{'config'}};

    my $conn = DBI->connect($config{'dsn'});

    my $id = 0;

    # Prepare the insert statement

    my (@values, @field_names);

    foreach my $a (@{$config{'fields'}})
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
    if ($q->param('preview') || (! $valid_params))
    {
        if ($valid_params)
        {
            $ret .= linux_il_header($config{'strings'}->{'preview_result_title'}, "Preview the Added Record");
        }
        else
        {
            $ret .= linux_il_header("Invalid Parameters Entered", 
            "Invalid Paramterers Entered");
        }

        $ret .= 
            $self->render_record(
                'fields' => \@field_names,
                'values' => \@values,
            );

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
                    ($valid_params ?
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
        $ret .= linux_il_header($config{'strings'}->{'add_result_title'}, "Success");

        my $query_str = "INSERT INTO " . $config{'table_name'} . 
            " (" . join(",", "id", "status", "area", @field_names) . ") " .
            " VALUES ($id, 1, '" . $q->param("area") . "'," .  join(",", (map { $conn->quote($_); } @values)) . ")";

        $conn->do($query_str);

        $conn->disconnect();

        $ret .= <<'EOF';
The job was added to the database.<br>
<br>
EOF
        ;
        
        $ret .= "<a href=\"main.pl\">" . $config{'strings'}->{'add_back_link_text'} . "</a>\n";
    }   

    $ret .= linux_il_footer();

    return $ret;
}
1;
