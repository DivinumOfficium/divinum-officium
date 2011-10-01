#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Date::Format;
use Algorithm::Diff;

my $USAGE = <<USAGE ;
Run divinumofficium regression tests against a current version.
Usage: divinum-replay [options] FILE...

Parameters:
    FILE...         file(s) of tests previously established by divinum-get

Options:
--url=BASE          base URL of site to download current version from
                    defaults to environment DIVINUM_OFFICIUM_URL if defined
                    otherwise http://divinumofficium.com
--ignore=IGNORE     suppress differences of type IGNORE.
                    This option can be specified many times.
--ignore=IJ         Ignore differences between I and J or i and j.
--ignore=accents    Ignore differences between accented and unaccented letters.
--ignore=urls       Completely ignore differences in URLs

--update            Update the contents of each FILE... to match current revisions
                    Doesn't report any differences.  
                    This option excludes --ignore= and --url=.
                    Warning: copy the FILEs first if you want to keep the old ones.
USAGE

my @ignore;
my $update;
my $new_base_url;
my $example_url = 'http://base.url/';
my @ignores = qw/IJ accents urls /;

GetOptions(
    'url=s' => \$new_base_url,
    'ignore=s' => \@ignore,
    'update' => \$update
) or die $USAGE;

die "Do not specify --update with other options.\n" if $update && ($new_base_url || @ignore);

$new_base_url = $ENV{DIVINUM_OFFICIUM_URL} unless $new_base_url;
$new_base_url = 'http://divinumofficium.com' unless $new_base_url;

foreach my $ignore ( @ignore )
{
    die "Invalid --ignore=$ignore\n" unless grep $ignore eq $_, @ignores
}

die "Specify at least one FILE." unless @ARGV;

foreach my $file ( @ARGV )
{
    if ( open IN, "<$file" )
    {
        if ( <IN> =~ /^DIVINUM OFFICIUM TEST CASE/ )
        {
            my $url = <IN>;
            my @old_result = <IN>;
            close IN;

            # Get new result
            if ( $url =~ /^(.*)(\/cgi-bin.*)/ )
            {
                my $old_base_url = $1;
                my $query = $2;

                my $new_url = "$new_base_url$query";
                print STDERR "$new_url\n";
                print STDOUT "$new_url\n";

                my @new_result = `curl -s '$new_url'`;
                unless ( $? == 0 )
                {
                    print STDERR "error: cannot download $new_url\n";
                    next;
                }

                if ( $update )
                {
                    if ( open OUT, ">$file" )
                    {
                        my @now = localtime;
                        print OUT "DIVINUM OFFICIUM TEST CASE ". asctime(@now);
                        print OUT "$url\n";
                        print OUT @new_result;
                        close OUT;
                    }
                    else
                    {
                        print STDERR "Warning: cannot update $file\n";
                        next;
                    }
                }
                else
                {

                    # Ignore differences in embedded urls.
                    s/$old_base_url/$example_url/g for @old_result;
                    s/$new_base_url/$example_url/g for @new_result;

                    # Ignore specified differences.
                    foreach ( @ignore )
                    {
                        if ( $_ eq 'IJ' )
                        {
                            # TODO : do this better (!!)
                            tr/Jj/Ii/ for @old_result, @new_result;
                        }
                        elsif ( $_ eq 'accents' )
                        {
                            # Write accented letters back to nonaccented.
                            tr/áéëíóúÁÉËÍÓÚ/aeeiouAEEIOU/ for @old_result, @new_result;
                            s/æ/ae/g for @old_result, @new_result;
                            s/Æ/Ae/g for @old_result, @new_result;
                        }
                        elsif ( $_ eq 'urls' )
                        {
                            s/\bhttp:[^ '"]*//g for @old_result, @new_result;
                        }
                    }

                    # Report differences
                    #
                    my $diff = Algorithm::Diff->new(\@old_result, \@new_result);

                    $diff->Base( 1 );   # Return line numbers, not indices
                    while ( $diff->Next() )
                    {
                        next if $diff->Same();
                        my $sep = '';
                        if ( ! $diff->Items(2) )
                        {
                            printf "%d,%dd%d\n",
                            $diff->Get(qw( Min1 Max1 Max2 ));
                        }
                        elsif ( ! $diff->Items(1) )
                        {
                            printf "%da%d,%d\n",
                            $diff->Get(qw( Max1 Min2 Max2 ));
                        }
                        else
                        {
                            $sep = "---\n";
                            printf "%d,%dc%d,%d\n",
                            $diff->Get(qw( Min1 Max1 Min2 Max2 ));
                        }
                        print "OLD $_"   for  $diff->Items(1);
                        print $sep;
                        print "NEW $_"   for  $diff->Items(2);
                    }
                }
            }
            else
            {
                print STDERR "warning: URL in $file is strange, skipping\n";
                next;
            }
        }
        else
        {
            print STDERR "warning: $file doesn't look like a test case\n";
            next;
        }
    }
    else
    {
        print STDERR "warning: can't read $file\n";
        next;
    }
    print "\n";
}

