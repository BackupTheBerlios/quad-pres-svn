package Shlomif::MiniReporter;

use strict;
use DBI;
use Template;

sub initialize
{
	my $self = shift;
	
	$self->{'config'} = shift;
	$self->{'cgi'} = shift;
	
	return 0;
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

    my $doctype = q{<!DOCTYPE html
PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">};

	$ret .= <<"EOF"
<?xml version="1.0" encoding="iso-8859-1"?>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en-US" lang="en-US">
<head>
$title1
<link rel="stylesheet" href="./style.css" type="text/css" />
</head>
<body>
<a href="/"><img SRC="/images/IGLU-banner.jpg" LENGTH=499 HEIGHT=86 ALT="IGLU -
Israeli Group of Linux Users" BORDER=0 ></a>
<p>[<a href="/">Home</a> |
<a href="/IGLU/">News</a> |
<a href="/about.shtml">About</a> |
<a href="/faq/">FAQ</a> |
<a href="/lists/">Lists</a>
(<a href="http://plasma-gate.weizmann.ac.il/Linux/maillists/">Main Archive</a>)
|
<a href="/events/">Events</a> |
<a href="/faq/cache/52.html">Help!</a> |
<a href="/faq/cache/8.html">Hebrew</a>]
<br>

<br>
$title2	
EOF
	;
	
	return $ret;
}

sub linux_il_footer
{
    my $ret;
    
    $ret .= <<'EOF';
<HR>
<font size=-1>
<P>for more info mail <a href="/cgi-bin/m/infonospam@dhtlinux.org.il">info</a>,
for website remarks mail the <a href="/cgi-bin/m/webmasternospam@dhtlinux.org.il
"><EM>webmasters</EM></A>.
<br>
All Trademarks and copyrights are owned by their respective owners, Linux is a Tradmark of Linus Torvalds.
<br>
The information contained herein is CopyLeft IGLU, you are granted permission to
copy it and distribute it.
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
<br>

<h3>Search the Database</h3>

<form action="search.pl" method="POST">

Area: 
<select name="area">
<option selected>All
EOF

    ;

    foreach my $area (@{$config->{'areas'}})
    {
    	$ret .= ( "<option>" . $area . "\n");
    }

    $ret .= <<'EOF';
</select>
<br>
<br>
Keyword from description: <input name="keyword"><br>
<br>
<input type="submit" value="Search">
</form>
<br>
EOF
	;

    $ret .= "<a href=\"search.pl?all=1\">" . $config->{'strings'}->{'show_all_records_text'} . "</a><br>\n";
    $ret .= "<a href=\"add_form.pl\">" . $config->{'strings'}->{'add_a_record_text'} . "</a>";

    $ret .= <<'EOF';
<br><br><br><br><br>
EOF

       ;

    $ret .= linux_il_footer();

    return $ret;
}

sub htmlize
{
	my $string = shift;
	
	my $char_convert = 
	sub {
		my $char = shift;
		
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
	};

	$string =~ s/([&<>])/$char_convert->($1)/ge;
	
	$string =~ s/\n\r?/<br>\n/g;
	
	return $string;
}

sub tt_render_record
{
    my $self = shift;

    my $ret = "";
    my %args = (@_);

    my $config = $args{config};
    my $values = $args{'values'};
    my $fields = $args{'fields'};

    # TODO: Make a persistent cross-object templater.
    my $tt = Template->new(
        {
            'BLOCKS' => 
                {
                    'main' => $config->{'record_template'},
                },
        },
    );
    
    my $vars = { map { $fields->[$_] => $values->[$_] } (1 .. $#$values)};
        
    $tt->process('main', $vars, \$ret);

    return $ret;
}

sub render_record
{
    my $self = shift;

    my $string = "";

    # An ad-hoc hack to switch Template Toolkit on and off.
    my $q = $self->{'cgi'};

    if ($q->param("tt"))
    {
        $string .= $self->tt_render_record(@_);
    }

    my %args = (@_);

    my %config = %{$args{'config'}};
    my @values = @{$args{'values'}};
    
    $string .=
    "<table border=1>\n" .
    "<tr>\n" .
    "<td>\n";
    
    for(my $a=0 ; $a<scalar(@{$config{'fields'}}) ; $a++)
    {
        $string .= "<b>" . $config{'fields'}->[$a]->{'pres'} .
"</b>: ";
    if (! $config{'fields'}->[$a]->{'sameline'})
    {
        $string .= "<br>\n";
    }
    
    if ($config{'fields'}->[$a]->{'flags'} =~ /email/)
    {
        $string .= "<a href=\"mailto:". htmlize($values[$a+1]) . "\">" . htmlize($values[$a+1]) . "</a>";
    }
    else
    {
        $string .= htmlize($values[$a+1]);
    }
    
    
    $string .= "<br>\n";	
    }
    
    $string .=  "</td>\n" .
        "</tr>\n" .
        "</table>\n";

    return $string;
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

    	$ret .= join("<br>\n<br>\n\n", @{$areas_jobs{$area}});
    }

    $ret .= <<'EOF' ;
<br><br><br><br>
EOF

      ;

    $ret .= linux_il_footer();

    $conn->disconnect();

    return $ret;

}

sub add_form
{
    my $self = shift;

    my $ret = "";

    my %config = %{$self->{'config'}};

    $ret .= linux_il_header("Add a job to the Linux-IL jobs' list", "Add a job");
    
    $ret .= <<'EOF';

<form action="add.pl" method="POST">

Area: 
<select name="area">
EOF

    ;

    foreach my $area (@{$config{'areas'}})
    {
    	$ret .= ( "<option>" . $area . "\n");
    }

    $ret .= <<'EOF';
</select>
<br>
<br>
EOF


    foreach my $field (@{$config{'fields'}})
    {
        if ($field->{'gen'}->{'auto'})
        {
            next;
        }
    	$ret .= ( $field->{'pres'} .  ": ");
    	if ($field->{'sameline'})
    	{
    		$ret .= ("<input name=\"" . $field->{'sql'} . "\">");
    	}
    	else
    	{
    		$ret .= ( "<br>\n<textarea name=\"" . $field->{'sql'} . "\" rows=\"5\" cols=\"60\">\n");
    		$ret .= "</textarea>";
    	}
    	$ret .= "\n<br><br>\n";
    }



    $ret .= <<'EOF';
<br><br>
<input type="SUBMIT" value="Submit">
</form>
<br><br><br><br>
EOF
	;
	
     $ret .= linux_il_footer();
	
}

sub add_post
{
    my $self = shift;
    
    my %config = %{$self->{'config'}};

    my $conn = DBI->connect($config{'dsn'});
    
    my $q = $self->{'cgi'};

    # Retrieve the ID for the new record

    my $id_query_str = "SELECT max(id) FROM " . $config{'table_name'};

    my $id_query = $conn->prepare($id_query_str);

    $id_query->execute();

    my $id = $id_query->fetchrow_array();

    $id_query->finish();

    $id++;

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

    my $query_str = "INSERT INTO " . $config{'table_name'} . 
    	" (" . join(",", "id", "status", "area", @field_names) . ") " .
        " VALUES (" . $id . ", 1, '" . $q->param("area") . "'," .  join(",", (map { $conn->quote($_); } @values)) . ")";

    $conn->do($query_str);

    $conn->disconnect();

    my $ret = "";
    
    $ret .= linux_il_header($config{'strings'}->{'add_result_title'}, "Success");
    $ret .= <<'EOF';

The job was added to the database.<br>
<br>
EOF
	;
    
    $ret .= "<a href=\"main.pl\">" . $config{'strings'}->{'add_back_link_text'} . "</a>\n";

    $ret .= linux_il_footer();

    return $ret;
}
1;
