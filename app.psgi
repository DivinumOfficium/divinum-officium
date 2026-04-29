use strict;
use warnings;
use Plack::Builder;
use Plack::App::CGIBin;
use Plack::App::File;
use Cwd qw(abs_path);
use File::Basename qw(dirname);

use lib "/usr/local/lib/site_perl";
use lib "/usr/share/perl5";

# --- HOTFIX: Fix missing return_405 method in Perl 5.42 / Plack 1.005x ---
# This prevents the "Can't locate object method" crash in Cloud Run.
{
    no strict 'refs';
    if (!defined &{"Plack::App::CGIBin::return_405"}) {
        *{"Plack::App::CGIBin::return_405"} = sub {
            my $self = shift;
            return [ 405, ['Content-Type' => 'text/plain'], ['405 Method Not Allowed'] ];
        };
    }
}

# Hardcoded for the Docker environment to ensure stability
my $base_dir = "/var/www";

$ENV{WWWROOT} = "$base_dir/web";
$ENV{PERL5LIB} = join(':', "$base_dir/web/cgi-bin", $ENV{PERL5LIB} || ());

# Inject the library paths directly into the Perl controller
use lib "/var/www/web/cgi-bin";
use lib "/var/www/web";


builder {

# --- BOT FIREWALL (Hard Block) ---
    # If the UA matches, we exit immediately with a 403, saving CPU.
    enable sub {
        my $app = shift;
        sub {
            my $env = shift;
            # Block the specific fake Chrome version seen in the logs
            if (($env->{HTTP_USER_AGENT} || '') =~ /Chrome\/142\.0/) {
                return [403, ['Content-Type' => 'text/plain'], ['Forbidden']];
            }
            return $app->($env);
        };
    };

    # 1. The Asset Mounts
    mount "/www" => Plack::App::File->new(root => "$base_dir/web/www")->to_app;

    # 2. CGI Wrapper
    my $cgi_wrapper = sub {
        my $file = shift;
        chdir dirname(abs_path($file)) if -f $file;
        return 1;
    };

    # 3. The Script Mounts
    my $horas_app = Plack::App::CGIBin->new(
        root => "$base_dir/web/cgi-bin/horas",
        exec_cb => $cgi_wrapper
    )->to_app;

    my $missa_app = Plack::App::CGIBin->new(
        root => "$base_dir/web/cgi-bin/missa",
        exec_cb => $cgi_wrapper
    )->to_app;

    mount "/cgi-bin/horas" => $horas_app;
    mount "/horas"         => $horas_app;
    mount "/cgi-bin/missa" => $missa_app;
    mount "/missa"         => $missa_app;

    # --- Robots.txt Handler ---
    mount "/robots.txt" => sub {
        return [
            200, 
            ['Content-Type' => 'text/plain'], 
            [
                # Block Meta (Facebook/Instagram AI)
                "User-agent: Meta-ExternalAgent\n" .
                "Disallow: /\n\n" .
                
                # Block OpenAI (ChatGPT / GPTBot)
                "User-agent: GPTBot\n" .
                "Disallow: /\n\n" .
                
                # Block Common Crawl (Used by many smaller AI models)
                "User-agent: CCBot\n" .
                "Disallow: /\n\n" .
                
                # Block Anthropic (Claude)
                "User-agent: anthropic-ai\n" .
                "Disallow: /\n\n" .

                # Block Perplexity AI
                "User-agent: PerplexityBot\n" .
                "Disallow: /\n\n" .

                # Block Ahrefs (SEO Crawler)
                "User-agent: AhrefsBot\n" .
                "Disallow: /\n\n" .

                # Block Barkrowler (SEO Crawler)
                "User-agent: Barkrowler\n" .
                "Disallow: /\n\n" .

                # Allow regular Search Engines (Google, Bing, DuckDuckGo)
                "User-agent: *\n" .
                "Disallow:\n"
            ]
        ];
    };

    # 4. The Root Handler
    mount "/" => sub {
        my $env = shift;
        my $path = $env->{PATH_INFO} || '';

        if ($path eq '/' || $path eq '') {
            return Plack::App::File->new(file => "$base_dir/web/index.html")->call($env);
        }

        return Plack::App::File->new(root => "$base_dir/web")->call($env);
    };
};