#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;
use Date::Calc
    qw/check_date Date_to_Days Add_Delta_Days Decode_Date_US/;

$\ = "\n";

my @horae = qw/Matutinum Laudes Prima Tertia Sexta Nona Vespera Completorium/;
my $horae_list = join(' ', @horae);

my $USAGE = <<USAGE ;
Set up regression tests for a given hour and a range of dates.
Usage: graball [options] param=value, param=value...

Parameters:
    param=value     parameters passed directly to officium.pl
    param           [accented browsertime caller expand
                    expandnum lang1 lang2 local notes priest screenheight
                    searchvalue setup testmode version votive]
    value           corresponding value

Options:
    --hora=[$horae_list]
    --from=MM-DD-YYYY   start downloading for this date (required)
    --to=MM-DD-YYYY     end downloading for this date (default=from date)
    --dir=DIR           put downlaods in DIR, named by date (default: all to stdout)
    --url=BASE          base url of site to download from
                        defaults to environment DIVINUM_OFFICIUM_URL if defined
                        otherwise http://divinumofficium.com
USAGE

my $hora;
my $from;
my $to;
my $dir;
my $base_url = $ENV{DIVINUM_OFFICIUM_URL};

$base_url = 'http://divinumofficium.com' unless $base_url;

GetOptions(
    'hora=s' => \$hora,
    'from=s' => \$from,
    'to=s' => \$to,
    'dir=s' => \$dir,
    'url=s' => \$base_url
) or die $USAGE;

die $USAGE unless $from && $hora;

die "invalid date: $from\n" unless my ($y1,$m1,$d1) = Decode_Date_US($from);
$to = $from unless $to;
die "invalid date: $to\n" unless my ($y2,$m2,$d2) = Decode_Date_US($to);

my $args = join('&',@ARGV);

die "Start date must be before end date\n" unless Date_to_Days($y1,$m1,$d1) <= Date_to_Days($y2,$m2,$d2);

if ( $dir )
{
    mkdir $dir;
    die "Can't find or create directory $dir\n" unless -d $dir;
}

die $USAGE unless grep $hora eq $_, @horae;

while ( Date_to_Days($y1,$m1,$d1) <= Date_to_Days($y2,$m2,$d2) )
{
    my $date = "$m1-$d1-$y2";

    my $url = "$base_url/cgi-bin/horas/officium.pl?$args&date=$date&command=pray$hora";

    my $file = $dir? "$dir/$date" : '>&STDOUT';
    open OUT, ">$file" or die "Can't write\n";
    print OUT $url;
    print OUT '-'x30;
    my $result = `curl -s '$url'`;
    print OUT $result;
    close OUT;

    ($y1,$m1,$d1) = Add_Delta_Days($y1,$m1,$d1,1);
}
