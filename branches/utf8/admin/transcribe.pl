#!/usr/bin/perl
use warnings;
use strict;
use FindBin;

$\ = "\n";

# The format of the accent table is an unordered set of lines of the form
#       plaintextword accentedtextword
# with exactly one range of whitespace in between.
# The program looks up words from the left and replaces them with words from the right.
# If there's no match, but there is a match after downcases the initial letter of the
# source word, then the replacement is done and then its initial is upcased.

my $Bin = $FindBin::Bin;
open TABLE, "$Bin/accent_table" or die "Can't read $Bin/accent_table\n";
my %table;
{ local $/; %table = split(' ',<TABLE>); }
close TABLE;

my $rule;
my $rank;

while ( my $line = <> )
{
    chomp $line;
    unless ( $rule || $rank || $line =~ /^ *[!&#\$\@\[]/ )
    {
        # Only transcribe the suffix text, not the prefix rules, whatever they are.
        next unless $line =~ /^([^=]*=|.*{ *:[^{}]*})?([^={}]*)$/;
        my $prefix = $1 ? $1 : '';
        my $words = $2;

        my @words = split(/([^a-zA-Z]+)/, $words);

        my $n = 0;
        for my $word ( @words )
        {
            # First word in some lines is special but unmarked.
            next if $n == 0 && $word eq 'Benedictio';
            next if $n == 0 && $word eq 'Absolutio';
            next if $n == 0 && $word eq 'Antiphona';

            # Try unnormalized first.
            # This handles the difference between María and mária.

            if ( $table{$word} )
            {
                $word = $table{$word}
            }
            else
            {
                my $replacement = $word;
                $replacement =~ tr/A-Z/a-z/;

                my $lowered = $replacement ne $word;
                $replacement = $table{$replacement};
                if ( $replacement )
                {
                    if ( $lowered )
                    {
                        my $a1 = substr($replacement,0,1);
                        $a1 =~ tr/a-z\x{9c}\x{e6}\x{e1}\x{e9}\x{ed}\x{f3}\x{fa}/A-Z\x{8c}\x{c6}\x{c1}\x{c9}\x{cd}\x{d3}\x{da}/;
                        $replacement = $a1 . substr($replacement,1);
                    }
                    $word = $replacement;
                }
            }
        }
        continue
        {
            $n = $n + 1
        }
        $line = join('', @words);

        $line =~ s/ae/\x{e6}/g;
        $line =~ s/Ae/\x{c6}/g;
        $line =~ s/oe/\x{9c}/g;
        $line =~ s/Oe/\x{8c}/g;

        $line = $prefix. $line;
    }
    else
    {
        $rule = ($line =~ /\[Rule\]/) || ($rule && $line !~ /^\[/);
        $rank = ($line =~ /\[Rank\]/) || ($rank && $line !~ /^\[/);
    }
}
continue
{
    print $line;
}
