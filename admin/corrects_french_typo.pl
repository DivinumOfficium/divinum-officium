#!/usr/bin/env perl
use utf8;
use strict;
use warnings;
use feature 'say';
use open qw( :encoding(UTF-8) :std );
use autodie;
use File::Temp qw/ tempfile /;
use File::Copy;

Main(@ARGV);
exit 0;

sub Main {
    return Usage() unless @_ ;
    ConvertFile($_) for (@_);
}

sub ConvertFile($) {
    my $filename = shift;
    my $modified = 0;
    print "Reading \"", $filename, "\"… ";
    my ($tmpfh, $tmpfilename) = tempfile; binmode $tmpfh, ':utf8';
    open my $fh, '<', $filename;
    while (<$fh>) {
        $modified |= ConvertLine();
        print $tmpfh $_;
    }
    close $fh;
    close $tmpfh;
    if ($modified) {
        copy $filename, $filename.".old";
        move $tmpfilename, $filename;
        say "corrected! Original file is \"", $filename.".old", "\"\n" ;
    } else {
        say "no error found!\n" ;
    }
    return $modified;
}

sub ConvertLine {
    my $modified = 0;
    my $old = $_;
    $modified |= s/'/’/g;
    $modified |= s/O /Ô /g;
    $modified |= s/Evangile/Évangile/g;
    $modified |= s/Epître/Épître/g;
    $modified |= s/(É|E)pitre/Épître/g;
    $modified |= s/ (:|;|!|\?)/ $1/g;
    print "\n< ", $old, "> ", $_ if $modified;
    return $modified;
}

sub Usage() {
    print <<"__USAGE__";
    $0 /path/*.txt

        Corrects some usual errors on the french punctuation and accents.

__USAGE__
}

__END__
