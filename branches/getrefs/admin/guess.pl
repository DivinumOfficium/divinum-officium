#!/usr/bin/perl
use Encode;
use strict;
use warnings;
$\ = "\n";

binmode(STDOUT, ':utf8');

for my $file ( @ARGV )
{
    local $/;
    if ( open IN, "<$file" and my $data = <IN> )
    {
        close IN;

        my @nots = ();

        if ( $data =~ /([^\x{01}-\x{7e}])/ )
        {
            push @nots, 'not pure ascii, found '.sprintf('0x%x', ord($1))
        }
        else
        {
            push @nots, 'pure ascii';
        }

        if ( $data =~ /([^\x{01}-\x{7e}\x{86}\x{87}\x{8A}\x{8C}\x{8E}\x{91}-\x{94}\x{96}\x{97}\x{9A}\x{9C}\x{9E}\x{9F}\x{AB}\x{AE}\x{BB}\x{BF}-\x{D6}\x{D8}-\x{F6}\x{F8}-\x{FF}])/ )
        {
            push @nots, 'not windows-1252 text, found '.sprintf('0x%x', ord($1))
        }
        else
        {
            push @nots, 'windows-1252 text'
        }

        my $decoded = eval { decode('UTF-8', $data, 1) } or undef;

        if ( $decoded )
        {
            if ( $decoded =~ /([^\x{0001}-\x{007E}\x{00C0}-\x{00D6}\x{00D8}-\x{00F6}\x{00F8}-\x{024F}\x{2719}-\x{2720}])/ )
            {
                push @nots, 'not utf-8 latin-based text, found '.sprintf('0x%x', ord($1))
            }
            else
            {
                push @nots, 'utf-8 latin-based text'
            }
        }
        else
        {
            push @nots, 'not utf-8 encoded'
        }

        print "$file : ", (@nots? join(', ', @nots): 'unrecognized');
    }
    else
    {
        print "$file : can't read";
    }
}
