package MyConfig;

use Exporter;

use vars qw(%config @EXPORT @ISA);

@EXPORT=qw(%config);

@ISA = qw(Exporter);

use POSIX;

%config = 
(
    'strings' => 
    {
        'main_title' => "Linux-IL Jobs Tracker",
        'add_result_title' => "Job was added to the database",
        'add_back_link_text' => "Back to the Jobs Database",
        'show_all_records_text' => "Show all the jobs",
        'add_a_record_text' => "Add a job to the database",
        'preview_result_title' => "Preview the Job Before Adding",
    },
    'dsn' => 'dbi:mysql:test_jobs',
    'table_name' => 'jobs2',
    'areas' => [ "Tel Aviv", "Haifa", "Jerusalem", "North", "South" ],
    'order_by' => "post_date DESC, id DESC",
    'fields' =>
    [
        {
            'sql' => "post_date",
            'pres' => "Post Date",
            'sameline' => 1,
            'gen' => 
                {
                    'auto' => 1,
                    'callback' =>
                        sub {
                            return POSIX::strftime("%Y-%m-%d",localtime(time()));
                        },      
                },
        },
        {
            'sql' => "title",
            'pres' => "Job Title",
            'sameline' => 1,
        },
        {
            qw(sql workplace pres Workplace sameline 1)
        },
        {
            qw(sql description pres Description sameline 0)
        },
        {
            qw(sql requirements pres Requirements sameline 0)
        },
        {
            qw(sql address pres Address sameline 0)
        },
        {
            qw(sql phone pres Phone sameline 1)
        },
        {
            'sql' => "cellphone",
            'pres' => "Cell Phone",
            'sameline' => 1,
        },
        {
            qw(sql fax pres Fax sameline 1)
        },
        {    
            qw(sql email pres E-mail sameline 1 flags email)
        },
        {
            'sql' => 'contact_person',
            'pres' => 'Contact Person',
            'sameline' => 1,
        },
    ],
    'record_template' => <<EOF
<div class="record">
<h3>[% title %]</h3>
<p class="posted">
Posted at <b>[% post_date %]</b>
</p>
<p class="data">
<b>Company</b>: [% workplace %]<br />
<b>Job Description:</b><br />
</p>
<div class="desc">
[% description %]
</div>
<p>
<b>Requirements:</b>
</p>
<div class="desc">
[% requirements %]
</div>
<p class="data">
<b>Address:</b> [% address %]<br />
<b>Phone:</b> [% phone %]<br />
<b>Cell Phone:</b> [% cellphone %]<br />
<b>Fax:</b> [% fax %]<br />
<b>E-mail:</b> [% email %]<br />
<b>Contact Person Name:</b> [% contact_person %]<br />
</p>
</div>
EOF
);

1;
