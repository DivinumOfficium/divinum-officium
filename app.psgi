use strict;
use warnings;
use Plack::Builder;
use Plack::App::CGIBin;
use Plack::App::File;
use Cwd qw(abs_path);
use File::Basename qw(dirname);

use lib "/usr/local/lib/site_perl";
use lib "/usr/share/perl5";

# Hardcoded for the Docker environment to ensure stability
my $base_dir = "/var/www";

$ENV{WWWROOT} = "$base_dir/web";
$ENV{PERL5LIB} = join(':', "$base_dir/web/cgi-bin", $ENV{PERL5LIB} || ());

# Inject the library paths directly into the Perl controller
use lib "/var/www/web/cgi-bin";
use lib "/var/www/web";

builder {
    # 1. The Asset Mounts
    # Keeps images/css working if they are in web/www
    mount "/www" => Plack::App::File->new(root => "$base_dir/web/www")->to_app;

    # 2. CGI Wrapper (Keep this the same)
    my $cgi_wrapper = sub {
        my $file = shift;
        chdir dirname(abs_path($file)) if -f $file;
        return 1;
    };

    # 3. The Script Mounts (Standard + Aliases)
    
    # HORAS App
    my $horas_app = Plack::App::CGIBin->new(
        root => "$base_dir/web/cgi-bin/horas",
        exec_cb => $cgi_wrapper
    )->to_app;

    # MISSA App
    my $missa_app = Plack::App::CGIBin->new(
        root => "$base_dir/web/cgi-bin/missa",
        exec_cb => $cgi_wrapper
    )->to_app;

    # Mount Horas
    mount "/cgi-bin/horas" => $horas_app;
    mount "/horas"         => $horas_app;
    
    # Mount Missa (This fixes the code-dump you saw!)
    mount "/cgi-bin/missa" => $missa_app;
    mount "/missa"         => $missa_app;

    # 4. The Corrected Root Handler
    mount "/" => sub {
        my $env = shift;
        my $path = $env->{PATH_INFO} || '';

        # If they hit the root, serve index.html from /var/www/web/
        if ($path eq '/' || $path eq '') {
            return Plack::App::File->new(file => "$base_dir/web/index.html")->call($env);
        }

        # If they are looking for anything else (like /www/images/...) 
        # try the web folder first
        return Plack::App::File->new(root => "$base_dir/web")->call($env);
    };
};