#!/usr/bin/perl
use strict;
use warnings;
$\ = "\n";

use Getopt::Long;
use FindBin;

my $verbose = 1;
my $trial = 1;
my $log = "$FindBin::Bin/log";
my $source = 'https://divinum-officium.googlecode.com/svn/tags/web';
my $target = '/home1/lzkissne/public_html/divinumofficium';
my $tag = '';
my $help = 0;

my $debug = defined $ENV{DEBUG};

sub saydo($)
{
    my $command = shift;
    print STDERR "DEBUG: saydo('$command')" if $debug;

    print STDERR $command if $verbose;

    system $command unless $trial;
    die "fatal: failed $command.\n" unless $? == 0;
}

sub main()
{
    # Process command line

    my $USAGE = <<END;
Usage: release_web [options] tag
Release divinumofficium project from svn to live web site.
Parameters:
    tag             tag to install from
Options:
    --log=path      pathname of log history file (default $log)
    --source=url    url of source tag directory(default $source)
    --target=path   pathname of target site files (default $target)
    --[no]verbose   say nothing [default:--verbose]
    --[no]trial     do no actual changes [default:--trial]
    --help          this
END

    my $result = GetOptions(
        'verbose!' => \$verbose,
        'trial!' => \$trial,
        'log=s' => \$log,
        'source=s' => \$source,
        'target=s' => \$target,
        'help' => \$help,
        'tag=s' => \$tag,
        'debug' => \$debug,
    ) or eval 
    {
        print STDERR $USAGE;
        exit -1;
    };

    if ( $help )
    {
        print STDOUT $USAGE;
        exit 0;
    }

    unless ( @ARGV == 1 )
    {
        print STDERR "error: specify exactly one tag.";
        print STDERR $USAGE;
        exit -2;
    }

    print "This is the release installer for the Divinum Officium Project.";
    printf 'Options chosen: %sverbose, %strial'."\n\n",
        $verbose ? "" : "no",
        $trial ? "" : "no";

    die "error: cannot find directory $target\n" unless -d $target;
    print "info: installing to : $target";

    $tag = $ARGV[0];

    # Read log file
    my $log_data;
    if ( -f $log )
    {
        open LOG, "<$log" or die "error: cannot read log file $log\n";
        { local $/; $log_data = <LOG> } # slurp
        close LOG;
    }
    else
    {
        $log_data = '';
    }
    open LOG, ">>$log" or die "error: cannot write log file $log\n";

    # Check sanity
    my @previous = ($log_data =~ /INSTALLED (.*)/g);
    die "error: cannot determine currently installed version\n" unless @previous;

    print "info: most recently installed version is $previous[-1]";

    # Get tags
    print "info: discovering current tags...";
    my @tags = `svn ls $source/$tag`;
    die "error: cannot access $source/$tag\n" unless $? == 0 && @tags;

    print "Found @tags";

    die;

    my @urls;
    foreach my $url ( @urls )
    {
        next unless $url =~ /\/$tag\/(.*)$/;
        my $path = $1;
        saydo "svn export $url $target/$path";
    }

    print LOG "INSTALLED $source/$tag";
}

main();
