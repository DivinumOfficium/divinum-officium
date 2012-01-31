#!/usr/bin/perl
use warnings;
use strict;
use FindBin;

$\ = "\n";

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
    unless ( $rule || $rank || $line =~ /[{&\$[}_@]/ )
    {

        my @words = split(/([^a-zA-Z]+)/, $line);

        for my $word ( @words )
        {
            my $accented = $word;
            $accented =~ tr/A-Z/a-z/ unless $accented =~ /^Mari/;  # María vs mária

            my $lowered = $accented ne $word;
            $accented = $table{$accented};
            if ( $accented )
            {
                if ( $lowered )
                {
                    my $a1 = substr($accented,0,1);
                    $a1 =~ tr/a-z\x{9c}\x{e6}\x{e1}\x{e9}\x{ed}\x{f3}\x{fa}/A-Z\x{8c}\x{c6}\x{c1}\x{c9}\x{cd}\x{d3}\x{da}/;
                    $accented = $a1 . substr($accented,1);
                }
                $word = $accented;
            }
        }
        $line = join('', @words);

        $line =~ s/ae/\x{e6}/g;
        $line =~ s/Ae/\x{c6}/g;
        $line =~ s/oe/\x{9c}/g;
        $line =~ s/Oe/\x{8c}/g;
    }
    else
    {
        $rule = ($line =~ /\[Rule\]/) || ($rule && $line !~ /^\[/);
        $rank = ($line =~ /\[Rank\]/) || ($rank && $line !~ /^\[/);
    }
    print $line;
}
