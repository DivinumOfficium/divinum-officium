#!/usr/bin/env perl
#
# corrects_french_typo.pl - fix common French typography mistakes.
#
# Corrects a small fixed set of frequent errors in French text (see
# ConvertLine, below, for the exact substitutions): straight
# apostrophes, a couple of missing acute/circumflex accents, and a
# missing non-breaking space before certain punctuation.
#
# Usage:
#   corrects_french_typo.pl -h       print help and exit
#   corrects_french_typo.pl          read from STDIN, write corrected
#                                     text to STDOUT (silent/no report)
#   corrects_french_typo.pl FILE...  correct each FILE in place
#
# When correcting files, each corrected FILE has its original content
# preserved as "FILE.old" before being overwritten with the corrected
# text, and every changed line is reported to STDOUT as a small
# before/after block (line number, "< " old text, "> " new text). If a
# file needed no corrections, it is left untouched and "no error
# found!" is reported instead.
#
# This is a standalone admin/maintenance tool, unreferenced by any
# other script in the repository, dating from February 2016; it has
# received no functional changes since then (only whitespace/style-only
# commits).
#
use utf8;
use strict;
use warnings;
use feature 'say';
use open qw(:encoding(UTF-8) :std);
use autodie;
use File::Temp qw/tempfile/;
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
  my ($tmpfh, $tmpfilename) = tempfile;
  binmode $tmpfh, ':utf8';
  open my $fh, '<', $filename;

  while (<$fh>) {
    chomp;
    $modified |= ConvertLine(1);
    say $tmpfh $_;
  }
  close $fh;
  close $tmpfh;

  if ($modified) {
    move $filename, $filename . ".old";
    move $tmpfilename, $filename;
    say "corrected! Original file is \"", $filename . ".old", "\"";
  } else {
    say "no error found!";
  }
  say "";    # newline
  return $modified;
}

sub ConvertStream {
  foreach (<STDIN>) {
    ConvertLine(0);
    print $_;
  }
}

sub ConvertLine($) {

  # Note: "shift or 0" is really "(my $verbose = shift) or 0" due to
  # operator precedence ('or' binds looser than '='), so the "or 0"
  # has no effect; $verbose always ends up as whatever shift() returned.
  # Harmless as used: callers only ever pass 1 (ConvertFile, verbose)
  # or 0 (ConvertStream, silent).
  my $verbose = shift or 0;
  my $modified = 0;
  my $old = $_;

  # The corrections, applied in order:
  #   1. straight apostrophe -> French/typographic closing quote
  #   2. "O " -> "Ô " (missing circumflex)
  #   3. "(E|É)pitre" -> "Épître" (missing circumflex/accent on Épître)
  #   4. "E" + vangile|glise|pître -> "É" + same (missing acute accent
  #      on Évangile / Église / Épître)
  #   5. a plain space before : ; ! ? -> a non-breaking space (U+00A0),
  #      per French typographic convention for these punctuation marks.
  #      Note: the replacement " $1" below is NOT a plain space + $1 -
  #      the leading character is an actual U+00A0 non-breaking space,
  #      which renders identically to a plain space in most editors/
  #      terminals, so this is easy to misread from the source alone.
  $modified |= s/'/’/g;
  $modified |= s/O /Ô /g;
  $modified |= s/(E|É)pitre/Épître/g;
  $modified |= s/E(vangile|glise|pître)/É$1/g;
  $modified |= s/ (:|;|!|\?)/ $1/g;    # replace the usual space with a unbreakable space
  print <<EOF
l. $.:
< $old
> $_
EOF

    if $modified and $verbose;
  return $modified;
}

__END__
