#!/usr/bin/perl -CO
# vim: set encoding=utf-8 :
use utf8;
use warnings;
use strict;
use FindBin;
use Encode;

$\ = "\n";

# The format of the accent table is an unordered set of lines of the form
#       plaintextword accentedtextword
# with exactly one range of whitespace in between.
# The program looks up words from the left and replaces them with words from the right.
# If there's no match, but there is a match after downcases the initial letter of the
# source word, then the replacement is done and then its initial is upcased.

# This program works in UTF-8 only.

my $Bin = $FindBin::Bin;

my @accents;
open ACCENTS, '<:encoding(utf-8)', "$Bin/accent_table"
    or die "Can't read $Bin/accent_table\n";
my %table;
{ local $/; %table = split(' ', <ACCENTS>); }
close ACCENTS;

my $convert = Encode::find_encoding('utf-8');

my $rule;
my $rank;

while ( my $line = <> )
{
    chomp $line;
    eval { $line = $convert->decode($line, Encode::FB_CROAK) }
        or die "transcribe: input not UTF-8 on line $.\n";
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
                        $a1 =~ tr/a-záéíóúǽæ/A-ZÁÉÍÓÚǼÆ/;
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

        # The following are more often right than wrong, but sometimes wrong,
        # since coeptus is coëptus, and aerus is aërus.   
        # Corrections should do in the accents_table.
        $line =~ s/ae/æ/g;
        $line =~ s/Ae/Æ/g;
        $line =~ s/oe/œ/g;
        $line =~ s/Oe/Œ/g;

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
