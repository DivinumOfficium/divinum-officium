#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Date::Format;
use Algorithm::Diff;

my @filters = qw/kalendar hymns titles psalms antiphons html accents ij site urls punctuation spacing/;
my $filters = join(' ', @filters);

my $USAGE = <<USAGE ;
Run divinumofficium regression tests against a current version.
Usage: divinum-replay [options] FILE...

Parameters:
    FILE...         file(s) of tests previously established by divinum-get

Options:
--url=BASE            base URL of site to download current version from
                      defaults to environment DIVINUM_OFFICIUM_URL if defined
                      otherwise http://divinumofficium.com
--filter=[+|-]FILTER  suppress (-) or include only (+) differences of type FILTER
--[no]baulk           Stop reporting differences if the observance doesn't match [default baulk]
--update              Update the contents of each FILE... to match current revisions
                      Doesn't report any differences.  
                      This option excludes --filter= and --url=.
                      Warning: copy the FILEs first if you want to keep the old ones.

Parameters:
FILTER                one of [$filters]
                      When + is specified, compare only the filtered content
                         and ignore everything else.  This is the default.
                      When - is specified, ignore differences in the filtered content.
                      The filters are applied in order, e.g.
                          +hymns,+html       compare only the html presentation of hymns
                          +psalms,-antiphons compare only psalm textual content
                      It doesn't make sense to use +ij or +accents or +spacing.
                      The filter -site applied first by default unless the site filter
                      is specified explicitly.

kalendar              Title of day 
hymns                 Hymns and their titles
titles                Titles of things
psalms                Psalm content, antiphony, and order
antiphons             Psalm and canticle antiphons
html                  HTML and javascript content
accents               accents and ligatures in all languages (-accents only)
ij                    i vs j (-ij only)
site                  the site specification (from http:// through /cgi-bin) (-site only)
urls                  URL strings
punctuation           presence and type of punctuation in text (-punctuation only)
spacing               all white space (-spaces only)
USAGE

my $filter = '';
my $update;
my $new_base_url;
my $baulk = 1;

GetOptions(
    'url=s' => \$new_base_url,
    'baulk!' => \$baulk,
    'filter=s' => \$filter,
    'update' => \$update
) or die $USAGE;

die "Do not specify --update with other options.\n" if $update && ($new_base_url || $filter);

unless ( $update )
{
    $new_base_url = $ENV{DIVINUM_OFFICIUM_URL} unless $new_base_url;
    $new_base_url = 'http://divinumofficium.com' unless $new_base_url;
}

my @filter = split(',', $filter);
push @filter, '-site' unless $filter =~ /site/;

foreach my $f ( @filter )
{
    die "Invalid filter: $f\n" unless
        $f =~ /^[+-]?(.*)/ && grep $1 eq $_, @filters
}

die "Specify at least one FILE.\n" unless @ARGV;

foreach my $file ( @ARGV )
{
    if ( open IN, "<$file" )
    {
        if ( <IN> =~ /^DIVINUM OFFICIUM TEST CASE/ )
        {
            my $url = <IN>;
            chomp $url;
            my @old_result = <IN>;
            close IN;
            
            # Get new result
            if ( $url =~ /^(.*)(\/cgi-bin.*)/ )
            {
                my $old_base_url = $1;
                my $query = $2;

                my $new_url = $new_base_url ? "$new_base_url$query" : $url;
                print STDERR "$new_url\n";

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
                    # Ignore specified differences.
                    foreach ( @filter )
                    {
                        my $ignore = /-/;
                        if ( /site/ )
                        {
                            if ( $ignore )
                            {
                                # Ignore site specification
                                s/http:..[^ ]*(cgi-bin|www)./.../g for @old_result, @new_result;
                            }
                            else
                            {
                                for ( @old_result, @new_result )
                                {
                                    $_ = '...' unless /http:..[^ ]*cgi-bin/;
                                }
                            }
                        }

                        elsif ( /ij/ )
                        {
                            if ( $ignore )
                            {
                                # TODO : do this better (!!)
                                tr/Jj/Ii/ for @old_result, @new_result;
                            }
                            else
                            {
                                print STDERR "warning: skipping $_\n";
                            }
                        }

                        elsif ( /accents/ )
                        {
                            if ( $ignore )
                            {
                                # Write accented letters back to nonaccented.
                                tr/·ÈÎÌÛ˙˝¡…ÀÕ”⁄/aeeiouyAEEIOU/ for @old_result, @new_result;
                                s/Ê/ae/g for @old_result, @new_result;
                                s/∆/Ae/g for @old_result, @new_result;
                            }
                            else
                            {
                                print STDERR "warning: skipping $_\n";
                            }
                        }

                        elsif ( /urls/ )
                        {
                            for ( @old_result, @new_result )
                            {
                                my @bits = split(/(\bhttp:[^ '"]*)/, $_);
                                for ( @bits )
                                {
                                    my $url = /^http/;
                                    if ( $url == $ignore )
                                    {
                                        $_ = '...'
                                    }
                                }
                                $_ = join('',@bits);
                                $_ = $_ + "\n" unless /\n$/;
                            }
                        }

                        elsif ( /html/ )
                        {
                            for ( @old_result, @new_result )
                            {
                                my @bits = split(/(<[^<>]*>)/, $_);
                                for ( @bits )
                                {
                                    my $html = /^</;
                                    if ( $html == $ignore )
                                    {
                                        $_ = '...'
                                    }
                                }
                                $_ = join('',@bits);
                                $_ = $_ + "\n" unless /\n$/;
                            }
                        }

                        elsif ( /kalendar/ )
                        {
                            for ( @old_result, @new_result )
                            {
                                # Ad hoc!
                                my $match = /<FONT COLOR=[^"]/ && !/COLOR=MAROON/ && !/HREF/;
                                if ( $match == $ignore )
                                {
                                    $_ = "...\n"
                                }
                            }
                        }

                        elsif ( /titles/ )
                        {
                            for ( @old_result, @new_result )
                            {
                                # Ad hoc!
                                my $match =
                                    /^<FONT SIZE=\+/ ||
                                    (/^<FONT COLOR="red"/ && !/Ant\.|\bV\.|\bR./);
                                if ( $match == $ignore )
                                {
                                    $_ = "...\n"
                                }
                            }
                        }

                        elsif ( /spacing/ )
                        {
                            for ( @old_result, @new_result )
                            {
                                # Capture interword spaces as escape character,
                                # then remove all spaces,
                                # then replace the escapes with spaces again.
                                s/\b +\b/\x{1E}/g;
                                s/ //g;
                                s/\x{1E}/ /g;
                            }
                        }

                        elsif ( /punctuation/ )
                        {
                            # Eliminate punctuation but keep word boundaries.
                            # Similar to spacing except capture all punctuation
                            for ( @old_result, @new_result )
                            {
                                s/\b[.,!?:;]+\b/\x{1E}/g;
                                s/[.,!?:;]+//g;
                                s/\x{1E}/ /g;
                            }
                        }

                        else
                        {
                            print STDERR "warning: $_ filtering not implemented\n";
                        }
                    }

                    my @new_slice = ();
                    for ( 0 .. $#new_result )
                    {
                        push @new_slice, $_ if $new_result[$_] ne "...\n";
                    }
                    @new_result = @new_result[@new_slice];

                    my @old_slice = ();
                    for ( 0 .. $#old_result )
                    {
                        push @old_slice, $_ if $old_result[$_] ne "...\n";
                    }
                    @old_result = @old_result[@old_slice];

                    # Report differences
                    my $diff = Algorithm::Diff->new(\@old_result, \@new_result);
                    my $printed = 0;

                    $diff->Base( 1 );   # Return line numbers, not indices
                    DIFF: while ( $diff->Next() )
                    {
                        next if $diff->Same();
                        print STDOUT "\n$new_url\n" unless $printed ++;
                        my @old = $diff->Items(1);
                        my @new = $diff->Items(2);
                        if ( @old && @new )
                        {
                            while ( @old || @new )
                            {
                                my $old = $old[0];
                                my $new = $new[0];
                                chomp $old if $old;
                                chomp $new if $new;
                                if ( defined $old && defined $new )
                                {
                                    print "CHANGED $old TO $new\n";

                                    # cf. /kalendar/ above
                                    last DIFF if 
                                        $baulk                      &&
                                        $old =~ /<FONT COLOR=[^"]/  &&
                                        $old !~ /COLOR=MAROON/      &&
                                        $old !~ /HREF/;
                                }
                                elsif ( defined $old )
                                {
                                    print "REMOVED $old\n";
                                }
                                elsif ( defined $new )
                                {
                                    print "ADDED $new\n";
                                }
                                @old = @old[1 .. $#old];
                                @new = @new[1 .. $#new];
                            }
                        }
                        elsif ( @old )
                        {
                            for ( @old )
                            {
                                print "REMOVED $_";
                            }
                        }
                        else
                        {
                            for ( @new )
                            {
                                print "ADDED $_";
                            }
                        }
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
}
