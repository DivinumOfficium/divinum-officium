#!/usr/bin/perl
#
# bad1252.pl - find files containing bytes that are not valid printable
# Windows-1252 text.
#
# Usage:
#   perl bad1252.pl file1 [file2 ...]
#
# For each file given on the command line, the whole content is scanned
# for any byte that falls outside the printable Windows-1252 range
# (ASCII plus the extended Latin-1/CP1252 punctuation and accented
# characters used by that code page - the same range used by the
# "windows-1252" heuristic in guess.pl). Unlike guess.pl, this script
# collects and reports *every distinct* offending byte value found in
# the file, not just the first one.
#
# Prints one line per file, in one of the following forms:
#
#   <filename> : clean            - no bytes outside the CP1252 range
#   <filename> : 0x.. ,0x.. ,...   - the distinct offending byte values,
#                                    as hex, e.g. "0x80,0x99"
#   <filename> : empty            - file opened but had no content
#   <filename> : can't read       - file could not be opened
#
# This is a standalone admin/maintenance tool dating from 2011 (created
# alongside guess.pl, in the same commit), used to spot mis-encoded or
# corrupted Divinum Officium data files. It has no references from any
# other script in the repository and has received no functional changes
# since it was first created (only whitespace/style-only commits).
#
use strict;
use warnings;
$\ = "\n";

for my $file (@ARGV) {
  local $/;

  if (open IN, "<$file") {
    my $data = <IN>;
    close IN;

    if ($data) {

      # Match every byte outside the printable Windows-1252 range
      # (ASCII 0x01-0x7e plus CP1252's extended punctuation/accented
      # characters); /g collects all occurrences, not just the first.
      my @bads = $data =~
        /([^\x{01}-\x{7e}\x{86}\x{87}\x{8A}\x{8C}\x{8E}\x{91}-\x{94}\x{96}\x{97}\x{9A}\x{9C}\x{9E}\x{9F}\x{AB}\x{AE}\x{BB}\x{BF}-\x{D6}\x{D8}-\x{F6}\x{F8}-\x{FF}])/g;

      if (@bads) {
        my %bads;
        $bads{sprintf('0x%x', ord $_)} = 1 for @bads;
        print "$file : " . join(',', keys %bads);
      } else {
        print "$file : clean";
      }
    } else {
      print "$file : empty";
    }
  } else {
    print "$file : can't read";
  }
}
