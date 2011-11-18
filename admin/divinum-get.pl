#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;
use Date::Format;
use URL::Encode ('url_encode');
use Date::Calc
    qw/check_date Date_to_Days Add_Delta_Days Decode_Date_US Today/;

my ($y, $m, $d) = Today();

my @prayers = qw/Matutinum Laudes Prima Tertia Sexta Nona Vespera Completorium SanctaMissa/;
my $prayers = join(' ', @prayers);
my %prayers = map (($_,$_), @prayers);

my @versions = (
    'Trident 1570',
    'Trident 1910',
    'Divino Afflatu',
    'Reduced 1955',
    'Rubrics 1960'
);
my $versions = join('|', @versions);

my @actions = qw/pray kalendar edit popup/;
my $actions = join(' ', @actions);
my %actions = map (($_,$_), @actions);

my @params = qw/accented browsertime caller expand expandnum lang1 lang2 local
                notes priest screenheight searchvalue setup testmode votive/;
my $params = join(' ', @params);
my %params = map (($_,$_), @params);

my $prayer;
my $action = 'pray';
my $compare;
my $mobile;
my $version;
my $from = "$m-$d-$y";
my $to;

my $query;
my @cgi = ();

my $entry;
my $dir;
my $base_url = 'http://divinumofficium.com/cgi-bin';
sub resource_to_filename($);

my $help;

my $USAGE = <<USAGE ;
Establish divinumofficium web results for a given hour and a range of dates.
Usage: divinum-get [--prayer=PRAYER|--query=QUERY] [option...]

Options:
--prayer=PRAYER     retrieve an Hour of the Divine Office, or the Mass
--action=ACTION     [$actions] [default: $action]
--compare           retrieve "comparison" variant of PRAYER and ACTION
--mobile            retrieve "mobile" variant of PRAYER and ACTION
--version=VERSION   rubric version [no default]
--from=MM-DD-YYYY   start downloading for this date [default: $from]
--to=MM-DD-YYYY     end downloading for this date [default: from-date]

--query=QUERY       retrieve BASE/QUERY
--cgi=PARAM=VALUE   query parameters passed directly as PARAM=VALUE&PARAM=VALUE...

--dir=DIR           put downlaods into directory DIR [default: current directory]
--url=BASE          base URL of site to download from [default: $base_url]

--help              This.

PRAYER              [$prayers]
VERSION             [$versions]
VERSION can be abbreviated as long as it's unambiguous.
QUERY               Any HTTP subquery, possibly including (CGI) query parameters
PARAM               [$params]
                    or anything else (unchecked)
VALUE               anything
PARAM=VALUE may need to be escaped or quoted from the shell.
Both PARAM and VALUE will be urlencoded for transmission.

Download files are named by the hora and date and version; or by the entry if specified.
To replay tests use divinum-replay.

Note: the default URL is the live site. The default for divinum-replayh is the 
environment variable DIVINUM_OFFICIUM_URL.  This allows -get to establish live results
and -replay to test against a test site.
USAGE

my $version_arg;
GetOptions(
    'prayer=s' => \$prayer,
    'action=s' => \$action,
    'compare' => \$compare,
    'mobile' => \$mobile,
    'version=s' => \$version_arg,
    'from=s' => \$from,
    'to=s' => \$to,

    'query=s' => \$query,
    'cgi=s' => \@cgi,

    'dir=s' => \$dir,
    'url=s' => \$base_url,

    'help' => \$help
) or die $USAGE;

if ( $help )
{
    print STDOUT $USAGE;
    exit 0;
}

die "Specify one or --prayer or --query\n" unless ($prayer && !$query) || (!$prayer && $query);

# If --prayer is specified, set things up aright.
if ( $prayer )
{
    die "--pray=$prayer is unknown\n" unless $prayers{$prayer};
    die "--action=$action is unknown\n" unless $actions{$action};
    if ( $prayer =~ /Missa/i )
    {
        if ( $action eq 'pray' )
        {
            $entry = $compare ? 'missa/Cmissa.pl': 'missa/missa.pl';
        }
        elsif ( $action eq 'kalendar' )
        {
            $entry = $compare ? 'missa/Ckalendar.pl': 'missa/kalendar.pl';
        }
        elsif ( $action eq 'edit' )
        {
            $entry = 'missa/medit.pl';
        }
        elsif ( $action eq 'popup' )
        {
            $entry = 'missa/mpopup.pl';
        }
    }
    else
    {
        if ( $action eq 'pray' )
        {
            if ( $mobile )
            {
                $entry = 'horas/Pofficium.pl';
            }
            elsif ( $compare )
            {
                $entry = 'horas/Cofficium.pl'
            }
            else
            {
                $entry = 'horas/officium.pl';
            }
        }
        elsif ( $action eq 'kalendar' )
        {
            $entry = $compare ? 'horas/Ckalendar.pl': 'horas/kalendar.pl';
        }
        elsif ( $action eq 'edit' )
        {
            $entry = 'horas/edit.pl';
        }
        elsif ( $action eq 'popup' )
        {
            $entry = 'horas/popup.pl';
        }
    }

    if ( $action eq 'popup' )
    { 
        print STDERR "warning: version ignored\n" if $version_arg
    }
    else
    {
        die "Specify a --version.\n" unless $version_arg;

        # Translate version_arg to version
        my $matches = 0;
        for my $v ( @versions )
        {
            if ( index($v, $version_arg) >= 0 )
            {
                $version = $v;
                $matches = $matches + 1
            }
        }
        die "error: --version=$version_arg is ambiguous\n" unless $matches < 2;
        die "error: --version=$version_arg is invalid\n" unless $matches == 1;
    }
}
else
{
    $entry = $query;
}

die "Invalid date $from .\n" unless my ($y1,$m1,$d1) = Decode_Date_US($from);
$to = $from unless $to;
die "Invalid date $to .\n" unless my ($y2,$m2,$d2) = Decode_Date_US($to);

die "Start date must be before end date.\n" unless Date_to_Days($y1,$m1,$d1) <= Date_to_Days($y2,$m2,$d2);

if ( $dir )
{
    mkdir $dir;
    die "Can't find or create directory $dir\n" unless -d $dir;
}

while ( Date_to_Days($y1,$m1,$d1) <= Date_to_Days($y2,$m2,$d2) )
{
    my @result;
    my $date = "$m1-$d1-$y1";
    my @arglist = ();

    if ( $prayer )
    {
        push @arglist, "command=pray$prayer";
        push @arglist, "version=$version" if $version;
        push @arglist, "date=$date";
    }
    push @arglist, @cgi;

    # Encode for URL transmission
    for ( @arglist )
    {
        # Don't encode the equals-sign.
        if ( /^([^=]*)=(.*)$/ )
        {
            $_ = url_encode($1) . '=' . url_encode($2)
        }
        else
        {
            $_ = url_encode($_)
        }
    }
    my $args = join('&', @arglist);
    my $url = "$base_url/$entry?$args";

    print STDERR "$url\n";
    @result = `curl -s '$url'`;

    my $file = resource_to_filename("$entry/$args");
    my $path = $dir ? "$dir/$file" : "$file";
    open OUT, ">$path" or die "Can't write $path\n";
    my @now = localtime;
    print OUT "DIVINUM OFFICIUM TEST CASE ". asctime(@now);
    print OUT "$url\n";
    print OUT @result;
    close OUT;

    ($y1,$m1,$d1) = Add_Delta_Days($y1,$m1,$d1,1);
}

# Ad hoc conversion of resource identifier to mnemonic filename.
sub resource_to_filename($)
{
    my $resource = shift;

    # Remove common path, param name, punctuation, etc, and join the result using -.
    $resource =~ s:^[^/]*/::;
    $resource =~ s/\.pl//g;
    $resource =~ s/command=(pray|setup|edit)//g;
    $resource =~ s/\w+=//g;
    $resource =~ s/%[0-9a-f][0-9a-f]/ /i;   # cheap urldecode : absolutely works

    return join ('-', split(/\W+/, $resource));
}
