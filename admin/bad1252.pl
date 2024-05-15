#!/usr/bin/perl
use strict;
use warnings;
$\ = "\n";

# Find files with narrowly undesired windows-1252 data

for my $file ( @ARGV )
{
    local $/;
    if ( open IN, "<$file" )
    {
        my $data = <IN>;
        close IN;

        if ( $data )
        {
            my @bads = $data =~ /([^\x{01}-\x{7e}\x{86}\x{87}\x{8A}\x{8C}\x{8E}\x{91}-\x{94}\x{96}\x{97}\x{9A}\x{9C}\x{9E}\x{9F}\x{AB}\x{AE}\x{BB}\x{BF}-\x{D6}\x{D8}-\x{F6}\x{F8}-\x{FF}])/g;

            if ( @bads )
            {
                my %bads;
                $bads{sprintf('0x%x',ord $_)} = 1 for @bads;
                print "$file : ". join(',',keys %bads)
            }
            else
            {
                print "$file : clean";
            }
        }
        else
        {
            print "$file : empty";
        }
    }
    else
    {
        print "$file : can't read";
    }
}
