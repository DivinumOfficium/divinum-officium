use strict;
use warnings;
use Plack::Builder;
use Plack::App::WrapCGI;
use Plack::App::File;
use Cwd qw(abs_path);
use File::Basename qw(dirname);

# --- ENVIRONMENT SETUP ---
my $base_dir = "/var/www";
my $cgi_dir  = "$base_dir/web/cgi-bin";

# Set the library paths for the new $dioecesis / PR #5143 logic
use lib "/var/www/web/cgi-bin";
use lib "/var/www/web";

$ENV{WWWROOT}  = "$base_dir/web";
$ENV{PERL5LIB} = join(':', $cgi_dir, $ENV{PERL5LIB} || ());

# Helper to wrap a CGI script safely
sub wrap_cgi {
    my $script_path = shift;
    return Plack::App::WrapCGI->new(
        script  => $script_path,
        execute => 1 
    )->to_app;
}

builder {
    # 1. BOT FIREWALL
    enable sub {
        my $app = shift;
        sub {
            my $env = shift;
            if (($env->{HTTP_USER_AGENT} || '') =~ /Chrome\/142\.0/) {
                return [403, ['Content-Type' => 'text/plain'], ['Forbidden']];
            }
            return $app->($env);
        };
    };

    # 2. STATIC ASSETS
    mount "/www" => Plack::App::File->new(root => "$base_dir/web/www")->to_app;

    # 3. EXPLICIT SCRIPT MOUNTS
    # These handle the primary entry points specifically to avoid any path ambiguity.
    mount "/cgi-bin/missa/missa.pl"    => wrap_cgi("$cgi_dir/missa/missa.pl");
    mount "/missa/missa.pl"            => wrap_cgi("$cgi_dir/missa/missa.pl");
    mount "/cgi-bin/horas/officium.pl" => wrap_cgi("$cgi_dir/horas/officium.pl");
    mount "/horas/officium.pl"         => wrap_cgi("$cgi_dir/horas/officium.pl");

    # 4. CGI SAFETY NET (CATCH-ALL)
    # If the app calls a script not explicitly listed (like a popup or helper script), 
    # this block will attempt to find and wrap it dynamically.
    mount "/cgi-bin" => sub {
        my $env = shift;
        my $path = $env->{PATH_INFO} || '';
        my $full_path = "$cgi_dir$path";

        if (-f $full_path && -x $full_path) {
            return wrap_cgi($full_path)->($env);
        }
        return [404, ['Content-Type' => 'text/plain'], ["Script not found: $path"]];
    };

    # 5. ROBOTS.TXT
    mount "/robots.txt" => sub {
        return [200, ['Content-Type' => 'text/plain'], ["User-agent: *\nDisallow: /cgi-bin/\n"]];
    };

    # 6. ROOT / FALLBACK HANDLER
    mount "/" => sub {
        my $env = shift;
        my $path = $env->{PATH_INFO} || '';

        # Serve index.html if root is requested
        if ($path eq '/' || $path eq '') {
            foreach my $file ("$base_dir/web/index.html", "$base_dir/web/www/index.html") {
                if (-f $file) {
                    return Plack::App::File->new(file => $file)->call($env);
                }
            }
        }

        # Serve other static files (css, js, images) from the web root
        return Plack::App::File->new(root => "$base_dir/web")->call($env);
    };
};