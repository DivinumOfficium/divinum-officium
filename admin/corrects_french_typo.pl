#!/usr/bin/env perl
use utf8;
use strict;
use warnings;
use feature 'say';
use open qw( :encoding(UTF-8) :std );
use autodie;
use File::Temp qw/ tempfile /;
use File::Copy;

sub Usage() {
    print <<EOF;
$0 -h
$0          (read from STDIN)
$0 FILES

Corrects some usual errors on the french punctuation and accents.
If a file from FILES must be corrected, the original one is save with the ".old" extension.

EOF
}

Main(@ARGV);
exit 0;

sub Main {
    return ConvertStream() unless @_;
    return Usage() if ($_[0] =~ m/-h/);
    ConvertFile($_) for (@_);
}

sub ConvertFile($) {
    my $filename = shift;
    my $modified = 0;
    say "Reading \"", $filename, "\"… ";
    my ($tmpfh, $tmpfilename) = tempfile; binmode $tmpfh, ':utf8';
    open my $fh, '<', $filename;
    while (<$fh>) {
        chomp;
        $modified |= ConvertLine(1);
        say $tmpfh $_;
    }
    close $fh;
    close $tmpfh;
    if ($modified) {
        move $filename, $filename.".old";
        move $tmpfilename, $filename;
        say "corrected! Original file is \"", $filename.".old", "\"";
    } else {
        say "no error found!";
    }
    say "";  # newline
    return $modified;
}

sub ConvertStream {
    foreach (<STDIN>) {
        ConvertLine(0);
        print $_;
    }
}

sub ConvertLine($) {
    my $verbose = shift or 0;
    my $modified = 0;
    my $old = $_;
    $modified |= s/'/’/g;
    $modified |= s/O /Ô /g;
    $modified |= s/(E|É)pitre/Épître/g;
    $modified |= s/E(vangile|glise|pître)/É$1/g;
    $modified |= s/ (:|;|!|\?)/ $1/g;  # replace the usual space with a unbreakable space
    print <<EOF
l. $.:
< $old
> $_
EOF
     if $modified and $verbose;
    return $modified;
}

__END__
