package ConvertLib;

# Turns a flat day file into a pool file.
#
# One section per line of the original, in the original order.  A line that
# names the same saints as a Latin elogium takes that Latin key; the rest
# get a key made from their own text, never one the Latin already uses.
# Values are the lines verbatim, with '=' in front of anything that would
# otherwise look like section grammar.
#
# Reading the sections back in order reproduces the flat file exactly, and
# convert_day() checks that for every day it writes.

use strict;
use warnings;
use utf8;
use Exporter 'import';
use POSIX qw(floor);

use MartyrLib qw(
  pool_new pool_set pool_get pool_render pool_read_text pool_entries
  make_key key_name_ok latin_entries reserved_keys
);
use Cognates qw(entry_score match_quality);

our @EXPORT_OK = qw(parse_flat_loose escape_value unescape_value align convert_day);

#*** parse_flat_loose(\@lines)
# Splits a flat day into (\@heading, $separator, \@body, $error).
#
# Loose: the separator is the first line in the file whose stripped form is
# '_' (searched in the first six lines); its exact spelling is kept.  Files
# without a separator (headingless French days, English days whose body
# follows the heading directly) are stored entirely as body, and the
# renderer emits a separator only when a heading exists.
sub parse_flat_loose {
  my $lines = shift;
  return (undef, undef, undef, 'empty file') unless @$lines;
  my $sep;

  for my $i (0 .. ($#$lines > 5 ? 5 : $#$lines)) {
    my $l = $lines->[$i];
    $l =~ s/^\s+|\s+$//g;

    if ($l eq '_') { $sep = $i; last }
  }
  return ([], undef, [@$lines], undef) if !defined $sep || $sep == 0;
  my @heading = @$lines[0 .. $sep - 1];

  # heading lines the format cannot carry verbatim: store as body
  foreach my $h (@heading) {
    return ([], undef, [@$lines], undef)
      if $h !~ /\S/ || $h =~ /^[\[=]/;
  }
  return (\@heading, $lines->[$sep], [@$lines[$sep + 1 .. $#$lines]], undef);
}

# Whitespace-only lines must be escaped, or the section reader's
# trailing-blank trim would swallow them.  So must a line opening with a
# bracket: setupstring reads that as a conditional and drops the line when
# it does not come out true, which is what happened to the English
# Austremonius, whose elogium begins '(At Clermont,)'.
sub escape_value {
  my $line = shift;
  return "=$line" if $line !~ /\S/ || $line =~ /^[\[=(]/;
  return $line;
}

sub unescape_value {
  my $v = shift;
  return substr($v, 0, 1) eq '=' ? substr($v, 1) : $v;
}

sub _round3 {
  my $y = shift() * 1000;
  my $f = floor($y);
  my $d = $y - $f;
  my $r = $d > 0.5 ? $f + 1 : $d < 0.5 ? $f : ($f % 2 == 0 ? $f : $f + 1);
  return $r / 1000;
}

#*** align(\@latin_entries, \@body)
# Greedy unique content alignment: returns { body index => latin index }.
#
# Pairs are ranked by two-way name agreement, so a long notice sharing a
# city cannot outrank a short entry whose names match exactly, and then by
# positional distance; a pair is accepted only when both sides are still
# free and at least one proper noun matched.
sub align {
  my ($latin, $body) = @_;
  my @candidates;

  for my $j (0 .. $#$body) {
    next unless $body->[$j] =~ /\S/;

    for my $i (0 .. $#$latin) {
      my ($m) = entry_score($latin->[$i][1], $body->[$j]);
      next unless $m >= 1;
      push @candidates,
        [-_round3(match_quality($latin->[$i][1], $body->[$j])), abs($i - $j), $i, $j];
    }
  }
  @candidates = sort {
         $a->[0] <=> $b->[0]
      || $a->[1] <=> $b->[1]
      || $a->[2] <=> $b->[2]
      || $a->[3] <=> $b->[3]
  } @candidates;

  my (%used_i, %used_j, %assign);

  foreach my $c (@candidates) {
    my ($i, $j) = @$c[2, 3];
    next if $used_i{$i} || $used_j{$j};
    $used_i{$i} = $used_j{$j} = 1;
    $assign{$j} = $i;
  }
  return \%assign;
}

#*** convert_day($day, \@lines, $no_align)
# Converts flat-file lines into a pool.  Returns ($pool, \%stats, $error).
#
# $no_align turns alignment off, for text that is not an elogium-per-line
# translation (commentary, say); then every line keeps a key of its own.
# stats: aligned, extras, structural, nonstandard_separator.
sub convert_day {
  my ($day, $lines, $no_align) = @_;
  my ($heading, $sep_line, $body, $err) = parse_flat_loose($lines);
  return (undef, undef, $err) if $err;

  my @latin = $no_align ? () : latin_entries($day);
  my $assign = align(\@latin, $body);
  my %used = reserved_keys($day);

  my $pool = pool_new($day);
  my $nonstandard = (defined $sep_line && $sep_line ne '_') ? 1 : 0;

  if (@$heading) {
    pool_set($pool, 'Titulus', join("\n", @$heading));
    pool_set($pool, 'Separatio', $sep_line) if $nonstandard;
  }
  my %stats = (aligned => 0, extras => 0, structural => 0,
    nonstandard_separator => $nonstandard);

  for my $j (0 .. $#$body) {
    my $vline = $body->[$j];
    my $key;

    if (exists $assign->{$j}) {
      $key = $latin[$assign->{$j}][0];
      $stats{aligned}++;
    } else {
      my $bare = $vline;
      $bare =~ s/^\s+|\s+$//g;

      if ($bare eq '' || $bare eq '_') {
        $key = 'Linea';
        $stats{structural}++;
      } else {
        $key = make_key($vline);
        $stats{extras}++;
      }
      $key = 'Elogium' unless key_name_ok($key);
      my ($base, $n) = ($key, 1);

      while ($used{$key} || exists $pool->{sections}{$key}) {
        $n++;
        $key = "$base-$n";
      }
    }
    $used{$key} = 1;
    pool_set($pool, $key, escape_value($vline));
  }

  # byte-identity self-check THROUGH THE WRITTEN FORM: reparse the rendered
  # text, so that representation gaps (a whitespace-only line clipped by
  # the section reader, say) cannot hide
  my $reparsed = pool_read_text(pool_render($pool), $day);
  my @rebuilt;

  if (defined pool_get($reparsed, 'Titulus')) {
    push @rebuilt, split(/\n/, pool_get($reparsed, 'Titulus'), -1);
    push @rebuilt, pool_get($reparsed, 'Separatio', '_');
  }

  foreach my $name (@{$reparsed->{order}}) {
    next if $name eq 'Titulus' || $name eq 'Separatio';
    push @rebuilt, unescape_value($reparsed->{sections}{$name});
  }
  return (undef, undef, 'reconstruction mismatch')
    if join("\0", @rebuilt) ne join("\0", @$lines);

  return ($pool, \%stats, undef);
}

1;
