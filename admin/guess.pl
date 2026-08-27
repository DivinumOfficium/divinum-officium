#!/usr/bin/perl
#
# guess.pl - guess the text encoding of one or more files.
#
# Usage:
#   perl guess.pl file1 [file2 ...]
#
# For each file given on the command line, prints a line of the form:
#
#   <filename> : <heuristic1>, <heuristic2>, <heuristic3>
#
# or "<filename> : can't read" if the file could not be opened.
#
# Each file's raw bytes are tested against three independent heuristics,
# each of which reports either that the file matches that encoding, or
# that it doesn't (along with the first offending byte/codepoint, printed
# as "found 0xNN"):
#
#   1. Pure ASCII       - every byte is in the printable ASCII range
#                          (0x01-0x7e).
#   2. Windows-1252 text - every byte falls within the printable
#                          Windows-1252 range (ASCII plus the extended
#                          Latin-1/CP1252 punctuation and accented
#                          characters used by that code page).
#   3. UTF-8 latin-based text - the raw bytes are first decoded as
#                          strict UTF-8 (failure is reported as "not
#                          utf-8 encoded"); if decoding succeeds, the
#                          resulting codepoints are checked against a
#                          "Latin-based" range covering ASCII, Latin-1
#                          supplement, Latin Extended-A/B, combining
#                          diacritics, and a handful of quote/dagger
#                          symbols used in liturgical texts.
#
# Since a file can match more than one heuristic (e.g. plain ASCII text
# is also valid Windows-1252 and valid UTF-8), all three results are
# reported for every file so the differences can be compared by hand.
#
# This is a standalone admin/maintenance tool dating from 2011, written
# to help audit the encoding of Divinum Officium data files. It has no
# references from any other script in the repository and has received
# no functional changes since it was first created (only whitespace/
# style-only commits).
#
use Encode;
use strict;
use warnings;
$\ = "\n";

binmode(STDOUT, ':utf8');

for my $file (@ARGV) {
  local $/;

  if (open IN, "<$file" and my $data = <IN>) {
    close IN;

    my @nots = ();

    # Heuristic 1: pure ASCII (bytes 0x01-0x7e only).
    if ($data =~ /([^\x{01}-\x{7e}])/) {
      push @nots, 'not pure ascii, found ' . sprintf('0x%x', ord($1));
    } else {
      push @nots, 'pure ascii';
    }

    # Heuristic 2: Windows-1252 (ASCII plus the printable/accented
    # characters defined by the CP1252 code page).
    if ($data =~
      /([^\x{01}-\x{7e}\x{86}\x{87}\x{8A}\x{8C}\x{8E}\x{91}-\x{94}\x{96}\x{97}\x{9A}\x{9C}\x{9E}\x{9F}\x{AB}\x{AE}\x{BB}\x{BF}-\x{D6}\x{D8}-\x{F6}\x{F8}-\x{FF}])/
    ) {
      push @nots, 'not windows-1252 text, found ' . sprintf('0x%x', ord($1));
    } else {
      push @nots, 'windows-1252 text';
    }

    # Heuristic 3: UTF-8, Latin-based. First try to decode the raw
    # bytes as strict UTF-8; only if that succeeds do we go on to
    # check the decoded codepoints against the Latin-based range.
    my $decoded = eval { decode('UTF-8', $data, 1) } or undef;

    if ($decoded) {
      if ($decoded =~
        /([^\x{01}-\x{1F}\x{20}-\x{7E}\x{AB}\x{BB}\x{A1}\x{BF}\x{BF}-\x{750}\x{1E00}-\x{1FFE}\x{2010}-\x{2021}\x{2719}-\x{2721}])/
      ) {
        push @nots, 'not utf-8 latin-based text, found ' . sprintf('0x%x', ord($1));
      } else {
        push @nots, 'utf-8 latin-based text';
      }
    } else {
      push @nots, 'not utf-8 encoded';
    }

    print "$file : ", (@nots ? join(', ', @nots) : 'unrecognized');
  } else {
    print "$file : can't read";
  }
}
