#!/usr/bin/perl
# Checks the martyrology still renders the text it always did.
#
# Run this after importing a language. It loads DO's own setupstring and
# specprima and renders through them, which is the only way to find out
# that Perl reads a pool file differently than the tool that wrote it.
#
# Languages are found on disk rather than listed here, so one you have
# just imported is checked too.
#
#   * every day of every language, under all four versions, must come out
#     byte-identical to the flat file kept beside it under source/;
#   * a language with no file for a day falls back the way checkfile does;
#   * gabc still takes the old path.
use utf8;
use FindBin;
use lib "$FindBin::Bin/../web/cgi-bin";
use DivinumOfficium::FileIO qw(do_read);

binmode STDOUT, ':encoding(utf-8)';

our ($datafolder, $version, $langfb, $lang1, $martyrfallback);
$datafolder = "$FindBin::Bin/../web/www/horas";
$langfb = 'English';

do "$FindBin::Bin/../web/cgi-bin/DivinumOfficium/SetupString.pl"
  or die "failed to load SetupString.pl: " . ($@ || $!);
do "$FindBin::Bin/../web/cgi-bin/horas/specials/specprima.pl"
  or die "failed to load specprima.pl: " . ($@ || $!);

*main::checklatinfile = sub { } unless defined &main::checklatinfile;

my @days;
my @dmax = (31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
for my $m (1 .. 12) {
  push @days, sprintf('%02d-%02d', $m, $_) for 1 .. $dmax[$m - 1];
}

my @versions = (
  ['Divino Afflatu',    'Martyrologium'],
  ['Reduced 1955',      'Martyrologium1955R'],
  ['Rubrics 1960',      'Martyrologium1960'],
  ['Tridentine - 1570', 'Martyrologium1570'],
);

my ($total, $ok, @fail) = (0, 0);

# every language with pool files, so a newly imported one is included
my @langs;
opendir(my $root, $datafolder) or die "cannot read $datafolder";
for my $name (sort readdir $root) {
  next if $name =~ /^\.|gabc/;
  next unless -d "$datafolder/$name/Martyrologium";
  next if $name eq 'Latin';
  opendir(my $d, "$datafolder/$name/Martyrologium") or next;
  my $has = grep { /^\d\d-\d\d\.txt$/ } readdir $d;
  closedir $d;
  push @langs, $name if $has;
}
closedir $root;

# plain language names, including ones with no martyrology of their own:
# those fall back to $langfb.  Hyphenated names fall back to their parent
# instead and are checked further down.
my @all_langs;
opendir($root, $datafolder) or die "cannot read $datafolder";
for my $name (sort readdir $root) {
  next if $name =~ /^\.|gabc|-/ || $name eq 'Latin';
  push @all_langs, $name if -d "$datafolder/$name/Psalterium";
}
closedir $root;

# hyphenated names (Latin-Bea, Polski-Newer): these resolve to an ancestor
my @hyphenated;
opendir($root, $datafolder) or die "cannot read $datafolder";
for my $name (sort readdir $root) {
  next if $name =~ /^\.|gabc/ || $name !~ /-/;
  push @hyphenated, $name if -d "$datafolder/$name/Psalterium";
}
closedir $root;

printf "languages with pool files: %s
", join(' ', @langs);
printf "hyphenated languages     : %s
", join(' ', @hyphenated);

# Latin
for my $v (@versions) {
  my ($vname, $dirname) = @$v;
  $version = $vname;
  my $vok = 0;

  for my $day (@days) {
    $total++;
    my @flat = do_read("$datafolder/Latin/$dirname/source/$day.txt");
    my @pool = martyrologium_elogia('Latin', $day);

    if (join("\0", @pool) eq join("\0", @flat)) {
      $ok++;
      $vok++;
    } else {
      push @fail, "Latin/$dirname/$day (pool " . scalar(@pool) . ", flat " . scalar(@flat) . ")";
    }
  }
  printf "Latin  %-20s %d/%d identical\n", $dirname, $vok, scalar(@days);
}

# Vernacular
for my $lang (@langs) {
  my $dir = "$datafolder/$lang/Martyrologium";
  opendir(my $dh, $dir) or die "no Martyrologium dir for $lang";
  my @conv = sort grep { /^\d\d-\d\d\.txt$/ } readdir $dh;
  closedir $dh;

  for my $v (@versions) {
    my ($vname, $dirname) = @$v;
    $version = $vname;
    my $lok = 0;

    for my $f (@conv) {
      (my $day = $f) =~ s/\.txt$//;
      $total++;
      my @flat = do_read("$datafolder/$lang/Martyrologium/source/$day.txt");
      my @pool = martyrologium_elogia($lang, $day);

      if (join("\0", @pool) eq join("\0", @flat)) {
        $ok++;
        $lok++;
      } else {
        push @fail, "$lang/$day under $vname (pool " . scalar(@pool) . ", flat " . scalar(@flat) . ")";
      }
    }
    printf "%-6s under %-15s %d/%d identical to legacy flat\n", $lang, $vname, $lok, scalar(@conv);
  }
}

# fallback-language rendering (no own day file)
# Legacy checkfile served the fallback language's flat file; the pooled
# path must render the fallback language's pool identically.  This covers
# languages where we have no martyrology.
for my $lang (@all_langs) {

  for my $v (@versions) {
    $version = $v->[0];
    my ($lok, $n) = (0, 0);

    for my $day (@days) {
      next if -e "$datafolder/$lang/Martyrologium/$day.txt";
      $n++;
      $total++;
      my @flat = do_read("$datafolder/English/Martyrologium/source/$day.txt");
      my @pool = martyrologium_elogia($lang, $day);

      if (join("\0", @pool) eq join("\0", @flat)) {
        $ok++;
        $lok++;
      } else {
        push @fail, "$lang(fallback)/$day under $v->[0]";
      }
    }
    printf "%-8s fallback under %-15s %d/%d identical to English flat\n", $lang, $v->[0], $lok, $n if $n;
  }
}

# A hyphenated language reads its parent's martyrology: checkfile() drops
# the last '-' segment and looks again, before it ever considers $langfb.
# Latin-Bea reads Latin and Polski-Newer reads Polski.  If no ancestor has
# a martyrology either; Magyar-Kaldi -> Magyar, which has none, and
# Cesky-Schaller -> Cesky, which is not even a folder (Czech lives under
# Bohemice) then it lands on $langfb like any other language would.
# Work that out here rather than listing it, so the expectation follows
# whatever is on disk and whatever $langfb is set to.
my %parent;
for my $lang (@hyphenated) {
  my $p = $lang;
  $p =~ s/-[^-]+$// while $p =~ /-/ && !has_pool($p);
  $parent{$lang} = has_pool($p) ? $p : $langfb;
}

sub has_pool {
  my $l = shift;
  return -e "$datafolder/$l/Martyrologium/01-01.txt";
}

for my $lang (sort keys %parent) {
  for my $v (@versions) {
    $version = $v->[0];

    for my $opt (0, 1) {
      $martyrfallback = $opt;
      my ($lok, $n) = (0, 0);

      for my $day (@days) {
        $n++;
        $total++;
        my $got = join("\0", martyrologium_elogia($lang, $day));
        my $want = join("\0", martyrologium_elogia($parent{$lang}, $day));

        if ($got eq $want && length $want) {
          $ok++;
          $lok++;
        } else {
          push @fail, "$lang/$day under $v->[0] (opt=$opt) != $parent{$lang}";
        }
      }
      printf "%-14s under %-15s opt=%d %d/%d identical to %s\n",
        $lang, $v->[0], $opt, $lok, $n, $parent{$lang};
    }
  }
}
$martyrfallback = 0;

# gating
$version = 'Rubrics 1960';
my @gate;
push @gate, 'Latin-gabc did not gate'          if martyrologium_elogia('Latin-gabc', '05-01');

printf "TOTAL %d/%d\n", $ok, $total;

if (@fail) {
  print "FAILURES:\n";
  print "  $_\n" for @fail[0 .. ($#fail > 19 ? 19 : $#fail)];
}
print "GATING: ", (@gate ? "FAIL: @gate" : "all legacy-path gates hold"), "\n";
exit((@fail || @gate) ? 1 : 0);
