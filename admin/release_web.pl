#!/usr/bin/perl
use strict;
use warnings;
$\ = "\n";

use Getopt::Long;
use FindBin;

my $verbose = 1;
my $trial = 1;
my $log = "$FindBin::Bin/log";
my $source = 'https://divinum-officium.googlecode.com/svn/tags';
my $target = '/home1/lzkissne/public_html/divinumofficium';
my $help = 0;

sub saydo($)
{
    my $command = shift;
    print STDERR $command if $verbose;
    unless ( $trial )
    {
        if ( $ENV{DEBUG} )
        {
            print STDERR "DEBUG: would $command"
        }
        else
        {
            system $command unless $trial;
        }
    }
}

sub main()
{
    # Process command line

    my $USAGE = <<END;
Usage: release_web [options]
Release divinumofficium project from svn to live web site.
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
        'target=s' => \$target
        'help' => \$help,
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

    print "This is release_web for divinumofficium.com.";
    printf 'Options: %sverbose, %strial'."\n\n",
        $verbose ? "" : "no",
        $trial ? "" : "no";

    # Get previous log file

    my $log_data;
    if ( -f $log )
    {
        open LOG, "<$log" or die "**Error: cannot read log file $log\n";
        { local $/; $log_data = <LOG> } # slurp
        close LOG;
    }
    else
    {
        $log_data = '';
    }
    open LOG, ">>$log" or die "**Error: cannot write log file $log\n";

    # Check sanity
    my @previous = ($log_data =~ /INSTALLED VERSION (.*)/g);
    die "**Error: cannot determine currently installed version\n" unless @previous;

    print $previous[-1];
    die;

    chdir $target or die "**Error: cannot change directory to $target\n";

    my $date = '2011-09-16';

    my @files;
    foreach my $f ( @files )
    {
        next unless $f =~ /$date\/(.*)$/;
        saydo "svn export $f $1";
    }
}

main()
