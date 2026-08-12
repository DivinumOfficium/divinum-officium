#!/usr/bin/perl
#
# The entries a translation has and the Latin has not.
#
# The Latin is the schema.  A translation lines up with the others by
# carrying the Latin's keys, and the index decides what renders, so an
# entry with no key in the Latin does not appear at all.  That settles
# most of these without anyone having to judge them: the Spanish edition
# prints the day's calendar and a page of commentary between the entries,
# and none of it is martyrology, so none of it needs a key.
#
# What is left is one question per entry -- ought the Latin to carry this
# elogium? -- and the answer is written down in latin-todo.txt:
#
#      <day> <key>     yes: the Latin gets a section, empty until someone
#                      writes the Latin.  No translation is invented here.
#     -<day> <key>     no: it is not an elogium, or not one this schema
#                      carries.  It keeps its text and stops rendering.
#     <<day> <key>     it is the rest of the entry above it, wrapped onto a
#                      second line, and is joined back onto it.
#
#     perl latin_todo.pl --report    rebuild the file, keeping decisions
#                                    already recorded in it
#     perl latin_todo.pl --apply     make the tree match the file
#
# --report never overrules a line already in the file, so a hand decision
# survives a rebuild.  --apply adds and removes Latin sections and index
# lines to match, and is safe to run twice.

use strict;
use warnings;
use utf8;
use FindBin;
use lib "$FindBin::Bin/internal";
use Getopt::Long;

use MartyrLib qw(
  $TOOLS all_days latin_entries pool_read pool_entries pool_write elogia_path do_read_lines
);
use Cognates qw(proper_nouns set_lexicon);

binmode STDOUT, ':encoding(utf-8)';

my $TODO = "$TOOLS/latin-todo.txt";
my @LANGS = qw(English Espanol Francais Italiano Polski Bohemice);

my ($apply, $report);
GetOptions('apply' => \$apply, 'report' => \$report) or die "bad options\n";
die "usage: latin_todo.pl --report | --apply\n" unless $apply || $report;

#*** classify($text, $lang)
# ('', reason) when the entry is not an elogium this schema carries;
# ('elogium', '') when it is.
sub classify {
  my ($text, $lang) = @_;
  local $_ = $text;
  s/^\s+|\s+$//g;

  return ('', 'spacer') if $_ eq '=' || $_ eq '';
  return ('', 'dots') if /^[\x{2025}\x{2026}.\x{b7}]+$/;

  # A line opening in lower case is the rest of the sentence above it, not
  # an entry: every one of these languages capitalises a sentence start.
  # These are proposed as '<', to be joined back on.  The ones opening with
  # a capitalised back-reference: 'Il suo corpo', 'He held', 'Avec lui'
  # read the same way and have to be marked by hand.
  return ('', 'fragment') if /^\p{Ll}/;

  # the Spanish book prints the day's calendar: the feast, its rank, its colour
  return ('', 'calendar')
    if /\b(Blanco|Rojo|Morado|Verde|Negro)\b/
    || /\b\d\s*[\x{aa}a]?\s*cl\./
    || /\bDm\.|\bSd\.\s|\bS\.\s+-/;
  return ('', 'calendar')
    if /^(?:S|Sta|Sto|St)\.\s/ && length() < 60;
  return ('', 'calendar')
    if /^(?:San|Santa|Santos|Santas|Sant[oa])\s+\p{Lu}/ && length() < 60;

  return ('', 'heading') if /:\s*$/;
  return ('', 'heading') if /^Dnia\s+\d/i;
  return ('', 'heading') if /^Le\s+\d+\s+\p{L}+\s*,?\s*(sont|$)/i;
  return ('', 'heading') if /^\d+\.\s*\p{L}*\s*$/;
  return ('', 'heading') if /^Upon the\s+\d/i;

  # nothing is named, so there is no saint for the Latin to carry
  return ('', 'no names') unless proper_nouns($_, $lang);

  return ('elogium', '');
}

#*** recorded()
# The decisions already in the file, so a rebuild keeps them.
sub recorded {
  my %seen;
  return %seen unless -e $TODO;

  foreach my $line (do_read_lines($TODO)) {
    next if $line =~ /^\s*#/ || $line !~ /\S/;
    my $mark = substr($line, 0, 1);
    $line =~ /(\d\d-\d\d)\s+(\S+)/ or next;
    my ($day, $key) = ($1, $2);
    $seen{"$day\0$key"} = ($mark eq '-' || $mark eq '<') ? $mark : ' ';
  }
  return %seen;
}

if ($report) {
  my %was = recorded();
  my (%rows, %text, %langs, %why);

  foreach my $lang (@LANGS) {
    set_lexicon($lang);

    foreach my $day (all_days()) {
      my %latin = map { $_->[0] => 1 } latin_entries($day);
      my $path = elogia_path($lang, $day);
      next unless -e $path;

      foreach my $e (pool_entries(pool_read($path, $day))) {
        my ($key, $body) = @$e;
        next if $latin{$key} || !defined $body || $body !~ /\S/;
        my $id = "$day\0$key";
        push @{$langs{$id}}, $lang;
        next if $text{$id};
        my ($verdict, $reason) = classify($body, $lang);
        $why{$id} = $reason;
        $text{$id} = $body;
        push @{$rows{$lang}}, [$day, $key, $id];
      }
    }
  }

  my ($yes, $no, $kept) = (0, 0, 0);
  my $out = <<'EOT';
# Entries a translation has and the Latin has not.
#
# The Latin is the schema: what has no key here does not render.  One
# question per line -- ought the Latin to carry this elogium?
#
#      <day> <key>     yes.  The Latin gets an empty section, to be filled
#                      in by someone who has the Latin.  No translation is
#                      invented.
#     -<day> <key>     no.  Not an elogium, or not one this schema carries.
#                      The text stays where it is and stops rendering.
#
# Grouped by the book it came from, because the books differ in what they
# print between the entries.  Rebuilding keeps every decision already here.

EOT

  foreach my $lang (@LANGS) {
    my @rs = sort { $a->[0] cmp $b->[0] || $a->[1] cmp $b->[1] } @{$rows{$lang} || []};
    next unless @rs;
    $out .= sprintf("\n# ---------------- %s (%d) ----------------\n", $lang, scalar @rs);

    foreach my $r (@rs) {
      my ($day, $key, $id) = @$r;
      my $mark;

      if (exists $was{$id}) { $mark = $was{$id}; $kept++ }
      elsif ($why{$id} eq 'fragment') { $mark = '<' }
      else { $mark = $why{$id} ? '-' : ' ' }
      $mark eq ' ' ? $yes++ : $no++;
      my $t = $text{$id};
      $t =~ s/\s+/ /g;
      my $also = @{$langs{$id}} > 1 ? ' +' . (@{$langs{$id}} - 1) : '';
      $out .= sprintf("%s%s %-26s %-9s%-3s %.64s\n",
        $mark, $day, $key, ($why{$id} || 'elogium'), $also, $t);
    }
  }
  open(my $fh, '>:raw', $TODO) or die "$TODO: $!";
  utf8::encode($out);
  print $fh $out;
  close $fh;
  printf "%d entries: %d for the Latin to carry, %d not (%d decisions kept)\n",
    $yes + $no, $yes, $no, $kept;
  exit 0;
}

# ---------------------------------------------------------------- --apply
die "no latin-todo.txt; run --report first\n" unless -e $TODO;
my (%want, %drop, %join);

foreach my $line (do_read_lines($TODO)) {
  next if $line =~ /^\s*#/ || $line !~ /\S/;
  my $mark = substr($line, 0, 1);
  $line =~ /(\d\d-\d\d)\s+(\S+)/ or next;
  if ($mark eq '-') { $drop{$1}{$2} = 1 }
  elsif ($mark eq '<') { $join{$1}{$2} = 1; $drop{$1}{$2} = 1 }
  else { $want{$1}{$2} = 1 }
}

# a tail marked '<' goes back onto the entry above it, in every language
# that has it, before anything else is decided about the day
my $joined = 0;

foreach my $day (all_days()) {
  next unless $join{$day};

  foreach my $lang (@LANGS) {
    my $path = elogia_path($lang, $day);
    next unless -e $path;
    my $pool = pool_read($path, $day);
    my (@keep, $last, $changed);

    foreach my $name (@{$pool->{order}}) {
      if ($join{$day}{$name} && defined $last) {
        $pool->{sections}{$last} .= "\n" . $pool->{sections}{$name};
        $joined++;
        $changed = 1;
        next;
      }
      push @keep, $name;
      $last = $name unless $name eq 'Titulus' || $name eq 'Separatio';
    }
    next unless $changed;
    $pool->{order} = \@keep;
    pool_write($pool, $path);
  }
}

my ($added, $removed, $pruned, $listed) = (0, 0, 0, 0);

#*** after($day, $key)
# The entry the Latin already has that this one comes after.  The Latin has
# no opinion -- it does not carry the entry yet -- so the translations that
# do are asked where they print it, and the nearest entry above it that the
# Latin knows is the answer.
sub after {
  my ($day, $key, $known) = @_;

  foreach my $lang (@LANGS) {
    my $path = elogia_path($lang, $day);
    next unless -e $path;
    my @order = map { (my $b = $_) =~ s/\]\s*\(.*$//; $b } @{pool_read($path, $day)->{order}};
    my ($at) = grep { $order[$_] eq $key } 0 .. $#order;
    next unless defined $at;

    for (my $i = $at - 1; $i >= 0; $i--) {
      return $order[$i] if $known->{$order[$i]};
    }
    return '';    # it opens the day
  }
  return undef;
}

foreach my $day (all_days()) {
  my $path = elogia_path('Latin', $day);
  next unless -e $path;
  my $pool = pool_read($path, $day);
  my %empty = map { $_->[0] => 1 }
    grep { !defined $_->[1] || $_->[1] !~ /\S/ } pool_entries($pool);
  my %have = map { $_ => 1 } @{$pool->{order}};

  my @new = grep { !$have{$_} } sort keys %{$want{$day} || {}};
  my @gone = grep { $empty{$_} } sort keys %{$drop{$day} || {}};
  next unless @new || @gone || $drop{$day};

  my $index = $pool->{sections}{Martyrologium} // '';
  my %known = map { $_ => 1 } grep { !$drop{$day}{$_} }
    map { /^\@(?:\d\d-\d\d)?:(.+?)\s*$/ ? $1 : () } split(/\n/, $index);
  my %pos;

  foreach my $key (@new) {
    my $a = after($day, $key, \%known);
    $pos{$key} = $a if defined $a;
  }
  open(my $in, '<:encoding(utf-8)', $path) or die "$path: $!";
  my @lines = <$in>;
  close $in;
  my (@out, $open, $in_index, %placed, %indexed, $skip, @pending);

  # A conditional reaches back over everything up to the last blank line, so
  # an index line has to stand alone in its own: the new ones are held until
  # the chunk they belong after has ended.
  my $settle = sub {
    foreach my $key (@pending) {
      push @out, "\n", "\@:$key\n";
      $listed++;
    }
    @pending = ();
  };

  my $flush = sub {
    return unless defined $open;

    foreach my $key (@new) {
      next unless defined $pos{$key} && $pos{$key} eq $open && !$placed{$key}++;
      push @out, "[$key]\n", "\n";
      $added++;
    }
    $open = undef;
  };

  foreach my $line (@lines) {
    if ($line =~ /^\[([^\]]+)\]/) {
      $settle->() if $in_index;
      $flush->();
      (my $bare = $1) =~ s/\]\s*\(.*$//;
      $open = $bare;
      $in_index = $bare eq 'Martyrologium';

      # an empty section for something the file says is not an elogium
      $skip = (grep { $_ eq $bare } @gone) ? 1 : 0;
      $removed++ if $skip;
      push @out, $line;

      # one that opens the day is named above every other line of the index
      if ($in_index) {
        foreach my $key (@new) {
          next unless defined $pos{$key} && $pos{$key} eq '' && !$indexed{$key}++;
          push @out, "\@:$key\n", "\n";
          $listed++;
        }
      }
      next;
    }

    # an index line for something the file says is not an elogium goes too
    if ($line =~ /^\@(?:\d\d-\d\d)?:(.+?)\s*$/) {
      my $at = $1;
      if ($drop{$day}{$at}) { $pruned++; next }
      push @out, $line;

      # the ones the Latin is gaining are named after it, once its own
      # conditional lines are past
      push @pending, grep { defined $pos{$_} && $pos{$_} eq $at && !$indexed{$_}++ } @new;
      next;
    }
    $settle->() if $in_index && $line !~ /\S/;
    push @out, $line unless $skip;
    $open = undef if $skip;
  }
  $settle->();
  $flush->();

  foreach my $key (@new) {
    next if $placed{$key};
    push @out, "[$key]\n", "\n";
    $added++;
  }
  my $text = join('', @out);
  $text =~ s/\n{3,}/\n\n/g;
  open(my $fh, '>:raw', $path) or die "$path: $!";
  utf8::encode($text);
  print $fh $text;
  close $fh;
}

printf "Latin: %d sections added and %d listed in the index, "
  . "%d empty ones removed, %d index lines pruned\n",
  $added, $listed, $removed, $pruned;
