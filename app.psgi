use strict;
use warnings;
use File::Basename;
use File::Spec;
use Plack::Builder;
use Plack::App::CGIBin;
use Plack::App::File;

my $app_root = "/var/www";

# Set library paths once at startup, not per-request
$ENV{PERL5LIB} = join(':', 
    "$app_root/web/cgi-bin",
    "$app_root/web/DivinumOfficium"
);

# PRE-LOAD: These stay in memory (Persistent)
my $cgi_app = Plack::App::CGIBin->new(
    root => "$app_root/web/cgi-bin",
    exec_cb => sub { 1 }
)->to_app;

my $static_app = Plack::App::File->new(root => "$app_root/web")->to_app;

builder {
    # 1. Setup Environment once per request
    enable sub {
        my $app = shift;
        sub {
            my $env = shift;

            # Handle Root Redirect
            if ($env->{PATH_INFO} eq '/' || $env->{PATH_INFO} eq '') {
                $env->{PATH_INFO} = '/index.html';
            }

            return $app->($env);
        };
    };

    # 2. THE DISPATCHER: Routes CGI requests vs static files
    sub {
        my $env = shift;

        if ($env->{PATH_INFO} =~ m|^/cgi-bin/|) {
            # Fix CWD for the script so relative file paths in CGI scripts work.
            # Note: chdir() is global per-worker — acceptable under low concurrency
            # but may cause intermittent path issues under heavy parallel load.
            my $script_path = File::Spec->catfile("$app_root/web", $env->{PATH_INFO});
            my $script_dir = dirname($script_path);
            chdir($script_dir) if -d $script_dir;

            # Strip '/cgi-bin' so CGIBin finds the file relative to its root
            $env->{PATH_INFO} =~ s|^/cgi-bin||;

            return $cgi_app->($env);
        }

        # Otherwise, serve as a static file
        return $static_app->($env);
    };
};
