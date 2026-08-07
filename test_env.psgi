use Plack::Builder;
use Plack::App::CGIBin;
use Plack::App::File;
use Cwd qw(abs_path);
use File::Basename qw(dirname);
use FindBin;

=pod
  Allows you to run via Plack wrapper
 
  Command:   plackup -r -E development test_env.psgi
 
     -r,Reload - Restarts the server automatically when you save files.
 
     -E,Environment - "Sets the context (Development, Deployment, or Test)."
        development - Enables verbose error reporting and debugging tools.
 
     test_env.psgi - The specific script that defines your web application
 
  To run on Termux, I had to install the following
 
    $ apt update && apt upgrade -y && pkg install perl -y
    $ pkg install perl build-essential 
    $ cpan App::cpanminus
    $ cpanm Plack
    $ cpanm CGI::Emulate::PSGI 
    $ cpanm CGI::Compile 
 
    $ plackup -r -E development test_env.psgi
=cut

my $base_dir = $FindBin::Bin;

$ENV{WWWROOT} = "$base_dir/web";
$ENV{PERL5LIB} = join(':', "$base_dir/web/cgi-bin", $ENV{PERL5LIB} || ());

use lib "$FindBin::Bin/web/cgi-bin";
use lib "$FindBin::Bin/web";

builder { 
    # Helper to fix the directory context for CGI scripts
    my $cgi_wrapper = sub {
        my $file = shift;
        chdir dirname(abs_path($file));
        return 1;
    };

    mount "/cgi-bin/horas" => Plack::App::CGIBin->new( 
        root => "$base_dir/web/cgi-bin/horas", 
        exec_cb => $cgi_wrapper
    )->to_app; 

    mount "/cgi-bin/missa" => Plack::App::CGIBin->new(
        root => "$base_dir/web/cgi-bin/missa",
        exec_cb => $cgi_wrapper  # <--- Add this!
    )->to_app;

    mount "/www" => Plack::App::File->new(
        root => "$base_dir/web/www"
    )->to_app; 

    mount "/" => sub { 
        return [301, ['Location' => '/cgi-bin/horas/officium.pl'], []]; 
    }; 
};