package Shlomif::Quad::Pres::Config;

use strict;

use Shlomif::Gamla::Object;

use vars qw(@ISA);

@ISA=qw(Shlomif::Gamla::Object);

use Config::IniFiles;

use Cwd;

sub initialize
{
    my $self = shift;

    my $base_path = ".";

    $self->initialize_analyze_args(
        {
            '[Pp]ath' => sub { my $new_path = shift; $base_path = $new_path; }
        },
        @_
    );

    $self->{'base_path'} = $base_path;

    my $cfg = 
        Config::IniFiles->new( 
            -file => "$base_path/quadpres.ini" 
        );

    if (!defined($cfg))
    {
        die "Could not open the configuration file!";
    }

    $self->{'cfg'} = $cfg;
    
    return 0;
}

sub get_val
{
    my $self = shift;

    return $self->{'cfg'}->val(@_);
}

sub get_server_dest_dir
{
    my $self = shift;

    return $self->get_val("quadpres", "server_dest_dir");
}

sub get_setgid_group
{
    my $self = shift;

    return $self->get_val("quadpres", "setgid_group");
}

sub get_upload_path
{
    my $self = shift;

    return $self->get_val("upload", "upload_path");
}

sub get_upload_util
{
    my $self = shift;

    return $self->get_val("upload", "util");
}

sub get_upload_cmdline
{
    my $self = shift;

    return $self->get_val("upload", "cmdline");
}

sub get_version_control
{
    my $self = shift;

    return $self->get_val("quadpres", "version_control");
}

sub get_hard_disk_dest_dir
{
    my $self = shift;

    return $self->get_val("hard-disk", "dest_dir");
}

1;


