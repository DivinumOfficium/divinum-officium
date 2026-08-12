package LearnNames;

# Learns the Latin <-> vernacular name pairs no spelling rule can reach.
#
# The rules in Cognates.pm handle names that differ predictably (Æthérii /
# Etherius).  They cannot handle Michaélis/Miguel or Gállia/Francia, and a
# hand-written table of those is never finished.
#
# They can be read off the corpus instead.  Most of the year already aligns
# on the rules alone, and in an aligned pair the leftover names on each
# side are probably translations of each other.  A pair that turns up on
# several unrelated days is real; one that turns up once is noise.
#
# So: align, count the leftovers, keep the pairs that are common and that
# pick each other, write namelex/<Lang>.txt, align again.  Three or four
# rounds settle.  The file is data, meant to be read and corrected.

use strict;
use warnings;
use utf8;
use Exporter 'import';
use File::Path qw(make_path);

use MartyrLib qw($TOOLS all_days do_read_lines flat_path latin_entries);
use Cognates qw(proper_nouns cognate stem normalize set_lexicon);
use ConvertLib qw(parse_flat_loose align);

our @EXPORT_OK = qw(learn installed_days);

my $LEXDIR = $ENV{MARTYR_NAMELEX} || "$TOOLS/namelex";

my $MIN_COUNT = 2;      # distinct entries the pair must co-occur in
my $MIN_DICE = 0.50;    # 2*c(l,v) / (c(l)+c(v))
my $MIN_LEN = 4;        # ignore very short tokens: too collision-prone

#*** _pairs_for(\%days)
# How often each Latin name is left over beside each vernacular one.
sub _pairs_for {
  my $days = shift;
  my (%pair, %lc, %vc, %rep);

  foreach my $day (sort keys %$days) {
    my ($h, $s, $body, $err) = parse_flat_loose($days->{$day});
    next if $err;
    my @entries = latin_entries($day);
    my $assign = align(\@entries, $body);

    foreach my $j (sort { $a <=> $b } keys %$assign) {
      my @la = proper_nouns($entries[$assign->{$j}][1]);
      my @vb = proper_nouns($body->[$j]);

      # names the rules could not pair up
      my @lrest = grep { my $x = $_; length($x) >= $MIN_LEN && !grep { cognate($x, $_) } @vb } @la;
      my @vrest = grep { my $y = $_; length($y) >= $MIN_LEN && !grep { cognate($_, $y) } @la } @vb;
      next unless @lrest && @vrest;

      my %lseen = map { $_ => 1 } @lrest;
      my %vseen = map { $_ => 1 } @vrest;

      foreach my $x (keys %lseen) {
        my $sx = stem(normalize($x));
        $lc{$sx}++;
        $rep{$sx} = $x unless exists $rep{$sx};
        $pair{"$sx\0" . stem(normalize($_))}++ foreach keys %vseen;
      }

      foreach my $y (keys %vseen) {
        my $sy = stem(normalize($y));
        $vc{$sy}++;
        $rep{$sy} = $y unless exists $rep{$sy};
      }
    }
  }
  return (\%pair, \%lc, \%vc, \%rep);
}

# three decimals with the trailing zeros dropped, so the notes read 1.0
# and 0.5 rather than 1 and 0.500
sub _dice {
  my $s = sprintf('%.3f', shift);
  $s =~ s/0+$//;
  $s .= '0' if substr($s, -1) eq '.';
  return $s;
}

#*** _select($pair, $lc, $vc)
# Keeps the pairs that are common and that pick each other.
#
# Two candidates for one name are often tied on count -- Willebaldi turns
# up beside both Willibald and Saxons the same number of times -- and then
# whichever is seen first wins.  Going through the pairs in sorted order
# makes that a property of the corpus rather than of the run.
sub _select {
  my ($pair, $lc, $vc) = @_;
  my (%best_l, %best_v);

  foreach my $k (sort keys %$pair) {
    my ($l, $v) = split(/\0/, $k);
    $best_l{$l} = $v if !exists $best_l{$l} || $pair->{$k} > $pair->{"$l\0$best_l{$l}"};
    $best_v{$v} = $l if !exists $best_v{$v} || $pair->{$k} > $pair->{"$best_v{$v}\0$v"};
  }
  my @out;

  foreach my $k (sort keys %$pair) {
    my ($l, $v) = split(/\0/, $k);
    my $c = $pair->{$k};
    next if $c < $MIN_COUNT;
    next unless $best_l{$l} eq $v && $best_v{$v} eq $l;    # mutually best
    my $dice = 2 * $c / ($lc->{$l} + $vc->{$v});
    next if $dice < $MIN_DICE;
    push @out, [$l, $v, $c, _dice($dice)];
  }
  return sort { $b->[2] <=> $a->[2] || $a->[0] cmp $b->[0] } @out;
}

my $MARKER = '# ---- learned (rewritten by learn_names) ----';

# the files in the tree were written by the Python tool this replaced, so
# its marker still has to be recognised when the manual block is read off
my $MARKER_RE = qr/^# ---- learned \(rewritten by learn_names(?:\.py)?\) ----$/m;

sub _default_header {
  my $lang = shift;
  return <<"EOT";
# Latin <-> $lang name correspondences.
#
# Compared by STEM, one pair per line:  <latin-stem> <vernacular-stem>
#
# Everything ABOVE the marker is hand-maintained and preserved across
# regeneration; everything below it is rewritten from the corpus by
# learn_names.  Two kinds of hand entry:
#
#     stem stem      force this pair (a name the mining never saw)
#     -stem stem     veto it (mining found it, but it is wrong)
#
# Vetoes are what to reach for when a learned pair is a coincidence
# rather than a name -- month names lining up because both sides are
# dating a martyrdom, or a common word that happens to be capitalized.
EOT
}

#*** read_manual($lang)
# The hand-kept block above the marker.
sub read_manual {
  my $lang = shift;
  my $path = "$LEXDIR/$lang.txt";
  return _default_header($lang) unless -e $path;
  my $text = join("\n", do_read_lines($path));
  my $head = (split($MARKER_RE, $text, 2))[0];
  $head = '' unless defined $head;
  return $head =~ /\S/ ? $head : _default_header($lang);
}

sub vetoes {
  my $lang = shift;
  my %out;

  foreach my $line (split(/\n/, read_manual($lang))) {
    my $l = $line;
    $l =~ s/^\s+|\s+$//g;
    $l = $l =~ /^#/ ? '' : do { $l =~ s/#.*//; $l =~ s/\s+$//; $l };
    next unless substr($l, 0, 1) eq '-';
    my @parts = split(' ', substr($l, 1));
    $out{"$parts[0]\0$parts[1]"} = 1 if @parts == 2;
  }
  return %out;
}

sub write_lexicon {
  my ($lang, $rows, $rep) = @_;
  make_path($LEXDIR);
  my $head = read_manual($lang);
  $head =~ s/\n+$//;
  my @lines = ($head, $MARKER);

  foreach my $r (@$rows) {
    my ($l, $v, $c, $d) = @$r;
    push @lines, sprintf('%s %s   # %s, %s  (%s/%s)',
      $l, $v, $c, $d, ($rep->{$l} || $l), ($rep->{$v} || $v));
  }
  open(my $fh, '>:raw', "$LEXDIR/$lang.txt") or die "$LEXDIR/$lang.txt: $!";
  my $text = join("\n", @lines) . "\n";
  utf8::encode($text);
  print $fh $text;
  close $fh;
}

#*** learn($lang, \%days, $rounds, $report)
# Writes namelex/<lang>.txt from these day files, returns the pair count.
sub learn {
  my ($lang, $days, $rounds, $report) = @_;
  $rounds = 4 unless defined $rounds;

  # keep what earlier rounds found: once a pair is learned it stops being
  # a leftover, so the next round would not find it again
  my (%acc, @order, %reps);
  my %veto = vetoes($lang);
  write_lexicon($lang, [], {});    # keep the manual block, drop the learned
  set_lexicon(undef);
  set_lexicon($lang);

  for my $round (1 .. $rounds) {
    my ($pair, $lc, $vc, $rep) = _pairs_for($days);
    my @rows = grep { !$veto{"$_->[0]\0$_->[1]"} && !$veto{"$_->[1]\0$_->[0]"} }
      _select($pair, $lc, $vc);
    $reps{$_} = $rep->{$_} foreach keys %$rep;
    my @new;

    foreach my $r (@rows) {
      my $k = "$r->[0]\0$r->[1]";
      next if exists $acc{$k};
      push @new, $r;
      $acc{$k} = [$r->[2], $r->[3]];
      push @order, $r;
    }

    # by count, and by the round that first found it where counts tie
    my $i = 0;
    my @sorted = map { $_->[1] }
      sort { $b->[1][2] <=> $a->[1][2] || $a->[0] <=> $b->[0] }
      map { [$i++, [$_->[0], $_->[1], @{$acc{"$_->[0]\0$_->[1]"}}]] } @order;
    write_lexicon($lang, \@sorted, \%reps);

    if ($report) {
      foreach my $r (@new) {
        printf "      + %-16s ~ %-16s  %d entries, dice %s\n",
          ($reps{$r->[0]} || $r->[0]), ($reps{$r->[1]} || $r->[1]), $r->[2], $r->[3];
      }
    }
    last unless @new;

    # reload, so the next round aligns with everything learned so far
    set_lexicon(undef);
    set_lexicon($lang);
  }
  set_lexicon(undef);
  return scalar(keys %acc);
}

#*** installed_days($lang)
# The language's flat files as already kept under obsolete/.
sub installed_days {
  my $lang = shift;
  my %days;

  foreach my $day (all_days()) {
    my $p = flat_path($lang, $day);
    $days{$day} = [do_read_lines($p)] if -e $p;
  }
  return %days;
}

1;
