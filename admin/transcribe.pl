#!/usr/bin/perl -CO
#
# transcribe.pl - add Latin accent marks to plain text.
#
# A UTF-8 text filter: reads lines from stdin (or from files given as
# arguments, via <>) and writes the same text to stdout with Latin
# words looked up and replaced by their accented equivalents (e.g.
# "Maria" -> "María"), as found in the accompanying data file
# admin/accent_table.
#
# Usage:
#   perl transcribe.pl < input.txt > output.txt
#   perl transcribe.pl file1.txt [file2.txt ...] > output.txt
#
# Input must be valid UTF-8; the script dies with a line-numbered error
# otherwise. The accent_table format is described where it is loaded,
# below.
#
# Lookup algorithm, per word:
#   1. Strip any existing accents/ligatures from the word to get a
#      plain lookup key (so both "María" and "maría" map to the same
#      table entry).
#   2. Try the table case-sensitively first.
#   3. If that fails, try again with the word lowercased, then re-case
#      the first letter of the replacement to match the original
#      word's case (so both "petrus" and "Petrus" work from a single
#      lowercase table entry).
#   4. If there's still no match, leave the word unchanged. If the
#      original word was already accented, record it in %learned (see
#      the "Learned words" report at the end) so it can be reviewed
#      and, if appropriate, added to accent_table.
#
# Lines are mostly transcribed in full, but:
#   - Lines inside a [Rule] or [Rank] section (until the next [...]
#     header), or starting with one of !&#$@[, are considered markup/
#     directives rather than prose and are passed through unchanged.
#   - For other lines, any leading "prefix" up to an '=' or a
#     "{ :...}" construct is left untouched; only the remaining
#     free-text suffix is split into words and transcribed.
#
# After transcription, a heuristic pass rewrites "ae"/"oe" (and their
# capitalized forms) into the æ/œ ligatures. This is often but not
# always correct (e.g. "coeptus" is actually "coëptus", not "cœptus",
# and Michael is actually "Michaël", not "Michæl"), so any such
# exceptions should be added to accent_table rather than special-cased
# here.
#
# At the end of input, if any words were "learned" (i.e. already
# accented in the input but not resolvable via accent_table), a
# "Learned words:" report is printed listing each as
# <plain-form>\t<accented-form>, intended to be reviewed and merged
# into accent_table by hand.
#
# This is a standalone, actively maintained authoring aid (not invoked
# by any other script) used when preparing new Latin liturgical text.
#
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
{
  local $/;
  %table = split(' ', <ACCENTS>);
}
close ACCENTS;

my $convert = Encode::find_encoding('utf-8');

my $rule;
my $rank;

my %learned;

while (my $line = <>) {
  chomp $line;
  eval {
    $line = $convert->decode($line, Encode::FB_CROAK);
    1;
  }
    or die "transcribe: input not UTF-8 on line $.\n";

  unless ($rule || $rank || $line =~ /^ *[!&#\$\@\[]/) {

    # Only transcribe the suffix text, not the prefix rules, whatever they are.
    next unless $line =~ /^([^=]*=|.*{ *:[^{}]*})?([^={}]*)$/;
    my $prefix = $1 ? $1 : '';
    my $words = $2;

    my @words = split(/([^\pL]+)/, $words);

    my $n = 0;

    for my $word (@words) {

      # First word in some lines is special but unmarked.
      next if $n == 0 && $word eq 'Benedictio';
      next if $n == 0 && $word eq 'Absolutio';
      next if $n == 0 && $word eq 'Antiphona';

      # Denormalize accents but not case.
      # This handles the difference between María and mária.
      my $originalword = $word;

      $word =~ tr/áéíóúÁÉÍÓÚ/aeiouAEIOU/;
      $word =~ s/[æǽ]/ae/g;
      $word =~ s/[ÆǼ]/Ae/g;
      $word =~ s/œ/oe/g;
      $word =~ s/Œ/Oe/g;

      # Try case specific first.

      if ($table{$word}) {
        $word = $table{$word};
      } else {
        my $replacement = $word;
        $replacement =~ tr/A-Z/a-z/;

        my $lowered = $replacement ne $word;
        $replacement = $table{$replacement};

        if ($replacement) {
          if ($lowered) {
            my $a1 = substr($replacement, 0, 1);
            $a1 =~ tr/a-záéíóúǽæ/A-ZÁÉÍÓÚǼÆ/;
            $replacement = $a1 . substr($replacement, 1);
          }
          $word = $replacement;
        } else {
          $learned{$word} = $originalword if $originalword =~ /[áéíóúÁÉÍÓÚǽǼ]/;
          $word = $originalword;
        }
      }
    } continue {
      $n = $n + 1;
    }
    $line = join('', @words);

    # The following are more often right than wrong, but sometimes wrong,
    # since coeptus is coëptus, and aerus is aërus.
    # Corrections should do in the accents_table.
    $line =~ s/ae/æ/g;
    $line =~ s/Ae/Æ/g;
    $line =~ s/oe/œ/g;
    $line =~ s/Oe/Œ/g;

    $line = $prefix . $line;
  } else {
    $rule = ($line =~ /\[Rule\]/) || ($rule && $line !~ /^\[/);
    $rank = ($line =~ /\[Rank\]/) || ($rank && $line !~ /^\[/);
  }
} continue {
  print $line;
}

if (%learned) {
  print "\n Learned words:\n";

  foreach my $entry (sort keys %learned) {
    print lc($entry) . "\t" . lc($learned{$entry});
  }
}
