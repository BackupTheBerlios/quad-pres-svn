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
<p>For more info mail <a href="/cgi-bin/m/infonospam@dhtlinux.org.il">info</a>,
for website remarks mail the 
<a href="/cgi-bin/m/webmasternospam@dhtlinux.org.il"><em>webmasters</em></a>.
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
	my $string = shift;
	
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

    my $config = $args{config};
    my $values = $args{'values'};
    my $fields = $args{'fields'};

    my $vars = { map { $fields->[$_] => htmlize($values->[$_]) } (1 .. $#$values)};
        
    $self->get_record_template_gen()->process('main', $vars, \$ret);

    return $ret;
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

    if ($q->param("all") eq "1")
    {
    	$where_clause_template = "WHERE status=1";	
    	
    	@areas = @area_list;
    }
    else
    {
    	if ($q->param("keyword") =~ /^\s*$/) {
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
    	
    	if ($q->param("area") eq 'All')
    	{
    		@areas = @area_list;
    	}
    	else
    	{
    		@areas = $q->param("area");
    	}
    }


    $ret .= linux_il_header("Search Results", "Search Results");

    my (@values);
    my (@field_names);

    foreach my $field (@{$config{'fields'}})
    {
    	push @field_names, $field->{'sql'};
    }

    my @field_names = ("area", (map { $_->{'sql'} } @{$config{'fields'}}));

    my $query_str = "SELECT " . join(", ", @field_names).  
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
                'config' => \%config,
                'fields' => \@field_names,
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
                $f->{sameline} ? 
                (
                    WWW::FieldValidator->new(WWW::FieldValidator::REGEX_MATCH,
                    "No newlines allowed",
                    '^([^\n\r]*)$'
                    ), 
                ): 
                ()
            ],
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

sub add_form
{
    my $self = shift;

    my $ret = "";

    my %config = %{$self->{'config'}};

    $ret .= linux_il_header("Add a job to the Linux-IL jobs' list", "Add a job");
    
    my $form = 
        WWW::Form->new(
            $self->get_form_fields(),
            undef,
            $self->get_form_fields_sequence(),
        );

     $ret .= $form->get_form_HTML(
         submit_label => "Preview", 
         action => './add.pl',
         submit_name => "preview",
         submit_class => "preview",
     );

     $ret .= linux_il_footer();
}

sub add_post
{
    my $self = shift;

    my $q = $self->{'cgi'};

    return join("\n<br />\n", (map { "$_ = " . $q->param($_) } $q->param()));
    
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
        
    $ret .= linux_il_header($config{'strings'}->{'add_result_title'}, "Success");
    

    if ($q->param('Preview'))
    {
        my $form = 
            WWW::Form->new(
                $self->get_form_fields(),
                undef,
                $self->get_form_fields_sequence(),
            );

        $ret .= $form->get_form_HTML(
            'buttons' =>
            [
                {
                    submit_label => "Preview", 
                    action => './add.pl',
                    submit_name => "preview",
                    submit_class => "preview",
                },
                {
                    submit_label => "Submit",
                    action => './add.pl',
                    submit_name => "submit",
                },
            ],
         );
    }
    else
    {
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
