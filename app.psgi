use strict;
use warnings;
use Encode qw(encode_utf8);
use File::Basename;
use File::Spec;
use Plack::Builder;
use Plack::App::CGIBin;
use Plack::App::File;

my $app_root = "/var/www";
my $cache_dir = "$app_root/web/ordo-cache";

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

# Helper: URL-decode a string
sub url_decode {
    my $v = shift;
    $v =~ s/\+/ /g;
    $v =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/ge;
    return $v;
}

# Helper: parse a query string or POST body into a hash
sub parse_params {
    my $str = shift || '';
    my %p;
    for my $pair (split /&/, $str) {
        my ($k, $v) = split /=/, $pair, 2;
        next unless defined $k && defined $v;
        $p{url_decode($k)} = url_decode($v);
    }
    return %p;
}

# Helper: build a filesystem-safe cache key from a version string.
# Must match the logic in warm-ordo-cache.sh
sub version_to_cache_key {
    my $v = lc(shift);
    $v =~ s/[^a-z0-9]/-/g;
    $v =~ s/-+/-/g;
    $v =~ s/^-//; $v =~ s/-$//;
    return $v;
}

# Helper: serve a cached ordo HTML file with correct encoding
sub serve_cache_file {
    my ($file) = @_;

    open my $fh, '<:encoding(UTF-8)', $file or return undef;
    local $/;
    my $content = <$fh>;
    close $fh;

    return undef unless $content;

    # Encode to raw UTF-8 bytes — Starman requires bytes, not Perl wide chars
    my $bytes = encode_utf8($content);
    my $size  = length($bytes);

    return [
        200,
        [
            'Content-Type'   => 'text/html; charset=utf-8',
            'Content-Length' => $size,
            'X-Ordo-Cache'   => 'HIT',
        ],
        [ $bytes ],
    ];
}

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

            # --- ORDO CACHE: intercept full-year (Totus) kalendar requests ---
            if ($env->{PATH_INFO} =~ m|kalendar\.pl|) {

                # Read params from both GET query string and POST body
                my %params = parse_params($env->{QUERY_STRING});

                if ($env->{REQUEST_METHOD} eq 'POST') {
                    # Read the POST body without consuming it for the CGI handler
                    my $body = '';
                    if ($env->{'psgi.input'}) {
                        $env->{'psgi.input'}->read($body, $env->{CONTENT_LENGTH} || 0);
                        # Restore the input stream so the CGI handler can read it too
                        open my $fh, '<', \$body;
                        $env->{'psgi.input'} = $fh;
                    }
                    my %post_params = parse_params($body);
                    %params = (%params, %post_params);
                }

                if (($params{kmonth} || '') eq '14') {
                    my $year    = $params{kyear}   || (localtime)[5] + 1900;
                    my $version = $params{version} || 'Rubrics 1960 - 1960';
                    my $key     = version_to_cache_key($version);
                    my $cache_file = "$cache_dir/${year}-${key}.html";

                    if (-f $cache_file && -s $cache_file) {
                        my $response = serve_cache_file($cache_file);
                        return $response if $response;
                        # Fall through to live CGI if file read fails
                    }
                    # Cache miss — fall through to live CGI
                }
            }
            # --- END ORDO CACHE ---

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