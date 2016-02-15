#!/usr/bin/env perl
use utf8;
use strict;
use warnings;
use feature 'say';
use open qw( :encoding(UTF-8) :std );
use autodie;
use File::Temp qw/ tempfile /;
use File::Copy;
use autodie;

Main(@ARGV);
exit 0;

sub Main {
    return Usage() unless @_ ;
    ConvertFile($_) for (@_);
}

sub ConvertFile($) {
    my $modified = 0;
    my $infilename = shift;
    print "Reading \"", $infilename, "\"… ";
    my ($outfh, $outfilename) = tempfile; binmode $outfh, ":utf8";
    open my $infh, '<:utf8', $infilename; # autodie dies on error
    while (my $line = <$infh>){
        $modified |= ConvertLine($line);
        print $outfh $line;
    }
    close $infh;
    close $outfh;
    if ($modified) {
        copy $infilename, $infilename.".old" ;
        move $outfilename, $infilename;
    }
    if ($modified) {
        say "corrected! Original file is \"", $infilename.".old", "\"\n" ;
    } else {
        say "no error found!\n" ;
    }
    return $modified;
}

sub ConvertLine($) {
    my $modified = 0;
    my $old = $_[0];
    $modified |= $_[0] =~ s/'/’/g;
    $modified |= $_[0] =~ s/O /Ô /g;
    $modified |= $_[0] =~ s/Evangile/Évangile/g;
    $modified |= $_[0] =~ s/Epître/Épître/g;
    $modified |= $_[0] =~ s/(É|E)pitre/Épître/g;
    $modified |= $_[0] =~ s/ (:|;|!|\?)/ $1/g;
    print "\n< ", $old, "> ", $_[0] if $modified;
    return $modified;
}

sub Usage() {
    print <<"__USAGE__";
    $0 /path/*.txt

        Corrects some usual errors on the french punctuation and accents.

__USAGE__
}

__END__
