#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;
use Date::Format;
use Date::Calc
    qw/check_date Date_to_Days Add_Delta_Days Decode_Date_US Today/;

my ($y, $m, $d) = Today();

my @horae = qw/Matutinum Laudes Prima Tertia Sexta Nona Vespera Completorium/;
my $horae_list = join(' ', @horae);

my @versions = qw/1570 1910 Divino 1955 1960/;
my $version_list = join(' ', @versions);

my @params = qw/accented browsertime caller expand expandnum lang1 lang2 local
                notes priest screenheight searchvalue setup testmode votive/;
my $params_list = join(' ', @params);

my $USAGE = <<USAGE ;
Establish divinumofficium web results for a given hour and a range of dates.
Usage: divinum-get --hora=HORA [option...]

Options:
--version=VERSION   rubric version [no default]
--from=MM-DD-YYYY   start downloading for this date [default: today]
--to=MM-DD-YYYY     end downloading for this date [default: from-date]
--dir=DIR           put downlaods into directory DIR [default: current dir]
--url=BASE          base URL of site to download from
                    [default: \$DIVINUM_OFFICIUM_URL]
                    [default default: http://divinumofficium.com]
--entry=PATH        relative URL of entry point [default: horas/officium.pl]
--cgi=PARAM=VALUE   query parameters passed directly as P1=V1&P2=V2...
HORA                [$horae_list]
VERSION             [$version_list]
PARAM               [$params_list]
                    or anything else (unchecked)
VALUE               anything

Download files are named by the hora and date.  Replay tests using divinum-replay.
USAGE

my $hora;
my $version;
my $entry = 'horas/officium.pl';
my $from = "$m-$d-$y";
my $to;
my $dir;
my $base_url;
my @cgi = ();

$base_url = $ENV{DIVINUM_OFFICIUM_URL};
$base_url = 'http://divinumofficium.com' unless $base_url;

GetOptions(
    'hora=s' => \$hora,
    'version=s' => \$version,
    'from=s' => \$from,
    'to=s' => \$to,
    'dir=s' => \$dir,
    'url=s' => \$base_url,
    'cgi=s' => \@cgi
) or die $USAGE;

die $USAGE unless $hora && grep $hora eq $_, @horae;

die $USAGE unless !defined($version) || grep $version eq $_, @versions;

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
    my $date = "$m1-$d1-$y2";
    my @arglist = ();

    push @arglist, "command=pray$hora";
    push @arglist, "version=$version" if $version;
    push @arglist, "date=$date";
    push @arglist, @cgi;

    my $args = join('&', @arglist);
    my $url = "$base_url/cgi-bin/$entry?$args";

    print STDERR "$url\n";
    @result = `curl -s '$url'`;

    my $file = "$hora-$date";
    $file = "$file-$version" if $version;

    my $path = $dir ? "$dir/$file" : "$file";
    open OUT, ">$path" or die "Can't write $path\n";
    my @now = localtime;
    print OUT "DIVINUM OFFICIUM TEST CASE ". asctime(@now);
    print OUT "$url\n";
    print OUT @result;
    close OUT;

    ($y1,$m1,$d1) = Add_Delta_Days($y1,$m1,$d1,1);
}
