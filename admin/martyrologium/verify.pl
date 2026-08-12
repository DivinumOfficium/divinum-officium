#!/usr/bin/perl
# Checks the martyrology against the flat files it was built from.
#
# Those files are the martyrology as it read before it was broken into
# elogia; they are kept in obsolete/martyrologium-source.  Run this after
# importing a language or editing a day file.
#
#   Latin     must come out line for line the same under every version.
#   Vernacular entries may now move, because the Latin index decides the
#             order, and may be suppressed, because the Latin index decides
#             what each version has.  What must not happen is an entry
#             going missing under Divino Afflatu, where nothing is dropped.
use utf8;
use FindBin;
use lib "$FindBin::Bin/../../web/cgi-bin";
use DivinumOfficium::FileIO qw(do_read);

binmode STDOUT, ':encoding(utf-8)';

our ($datafolder, $version, $langfb);
$datafolder = "$FindBin::Bin/../../web/www/horas";
my $legacy = "$FindBin::Bin/../../obsolete/martyrologium-source";
$langfb = 'English';

do "$FindBin::Bin/../../web/cgi-bin/DivinumOfficium/SetupString.pl"
  or die "failed to load SetupString.pl: " . ($@ || $!);
do "$FindBin::Bin/../../web/cgi-bin/horas/specials/specprima.pl"
  or die "failed to load specprima.pl: " . ($@ || $!);
*main::checklatinfile = sub { } unless defined &main::checklatinfile;

my @dmax = (31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
my @days;
for my $m (1 .. 12) { push @days, sprintf('%02d-%02d', $m, $_) for 1 .. $dmax[$m - 1] }

my @versions = (
  ['Divino Afflatu', ''],
  ['Reduced 1955', '1955R'],
  ['Rubrics 1960', '1960'],
  ['Tridentine - 1570', '1570'],
);

#*** respelt(\@a, \@b)
# True when two renderings differ only in where the accents fell or which
# quotation marks were set.
#
# Those differences are deliberate.  The 1570 files were left with a stray
# accent here and there in a version that prints none, and some version
# sections carried a misprint of the base rather than a wording of their
# own.  Both were reconciled, so the martyrology no longer reads the way
# the flat files it was built from do.  Anything beyond spelling is a real
# break and still fails.
sub respelt {
  my ($a, $b) = @_;
  return 0 unless @$a == @$b;

  for my $i (0 .. $#$a) {
    next if $a->[$i] eq $b->[$i];
    my @s = map {
      my $t = deaccent($_);
      $t =~ s/[\x{ab}\x{bb}\x{201c}\x{201d}\x{2018}\x{2019}"',;:.!?()\-]//g;
      $t =~ s/\s+/ /g;
      $t =~ s/^ | $//g;
      lc $t;
    } ($a->[$i], $b->[$i]);
    return 0 unless $s[0] eq $s[1];
  }
  return 1;
}

sub deaccent {
  my $s = shift;
  require Unicode::Normalize;
  $s = Unicode::Normalize::NFKD($s);
  $s =~ s/\p{Mn}//g;
  $s =~ s/\x{e6}/ae/g;
  $s =~ s/\x{c6}/Ae/g;
  $s =~ s/\x{153}/oe/g;
  $s =~ s/\x{152}/Oe/g;
  return $s;
}

sub norm {
  my $l = shift;
  $l =~ s/\s+/ /g;
  $l =~ s/^ | $//g;
  return $l;
}

#*** covered($line, $rendered)
# Some books print two elogia as one line.  The entry is then held as the
# two the Latin names, and the day renders them where the Latin puts them,
# which need not be next to each other.  The wording is not lost for that:
# the line is still there, in pieces, so it counts as reached when it can
# be cut into pieces the day renders.
sub covered {
  my ($line, $rendered) = @_;
  my @piece = sort { length($b) <=> length($a) } grep { /\S/ } keys %$rendered;
  return 0 unless @piece;

  # or the other way about: the book wrapped one elogium onto two lines and
  # the entry holds it whole, so the printed line is part of what renders
  foreach my $p (@piece) {
    return 1 if length($p) > length($line) && index($p, $line) >= 0;
  }
  my %seen;

  my $walk;
  $walk = sub {
    my $rest = shift;
    return 1 if $rest eq '';
    return 0 if $seen{$rest}++;

    foreach my $p (@piece) {
      next unless $p ne $line && index($rest, $p) == 0;
      my $tail = substr($rest, length $p);
      $tail =~ s/^\s+//;
      return 1 if $walk->($tail);
    }
    return 0;
  };
  return $walk->($line);
}

my ($fail, $checked) = (0, 0);

for my $v (@versions) {
  my ($name, $sfx) = @$v;
  $version = $name;
  my ($same, $spelt) = (0, 0);

  for my $day (@days) {
    my @flat = do_read("$legacy/Latin/Martyrologium$sfx/$day.txt");
    my @pool = martyrologium_elogia('Latin', $day);
    $checked++;

    if (join("\0", @pool) eq join("\0", @flat)) { $same++ }
    elsif (respelt(\@pool, \@flat)) { $spelt++ }
    else { $fail++; print "  Latin $day under $name differs\n" }
  }
  printf "Latin    %-18s %3d/%d identical%s\n", $name, $same, scalar(@days),
    $spelt ? " (+$spelt respelt)" : '';
}

# A translated entry has to be reachable under at least one version.  Not
# under every version: the flat files predate the martyrology obeying the
# version rules at all, so they carry entries that only later editions
# have - Joseph the Worker is in the 1955 books and nowhere earlier, and
# it is right that Divino Afflatu no longer shows it.  What must not
# happen is an entry that no version can reach, which means its key does
# not exist in the Latin index at all.
#*** dropped()
# The text of every entry latin-todo.txt says the schema does not carry.
#
# Those keep their text in the language that prints them and no longer
# render, because the Latin index decides what renders and they have no
# key in it.  They are the printed books' own furniture: a calendar
# line, a date heading, a leader-dot; so the flat file they came from
# still has them and this check has to know they are gone on purpose.
sub dropped {
  my @langs = @_;
  my %out;
  my $todo = "$FindBin::Bin/latin-todo.txt";
  return %out unless -e $todo;

  foreach my $line (do_read("$todo")) {
    next unless $line =~ /^-\s*(\d\d-\d\d)\s+(\S+)/;
    my ($day, $key) = ($1, $2);

    foreach my $lang (@langs) {
      my $f = "$datafolder/$lang/Martyrologium/$day.txt";
      next unless -e $f;
      my ($in_section, @body);

      foreach my $l (do_read($f)) {
        if ($l =~ /^\[([^\]]+)\]/) { $in_section = ($1 eq $key); next }
        push @body, $l if $in_section;
      }
      $out{$lang}{norm($_)} = 1 foreach grep { /\S/ } @body;
    }
  }
  return %out;
}

my @langs;
opendir(my $root, $datafolder) or die "cannot read $datafolder";
for my $name (sort readdir $root) {
  next if $name =~ /^\.|gabc|^Latin$/;
  push @langs, $name if -d "$legacy/$name/Martyrologium";
}
closedir $root;
my %dropped = dropped(@langs);

for my $lang (@langs) {
  my $lost = 0;

  for my $day (@days) {
    my $f = "$legacy/$lang/Martyrologium/$day.txt";
    next unless -e $f;
    $checked++;
    my %new;

    for my $v (@versions) {
      $version = $v->[0];
      $new{norm($_)} = 1 foreach martyrologium_elogia($lang, $day);
    }

    for my $line (map { norm($_) } do_read($f)) {
      next if $line !~ /\S/ || $line eq '_' || $new{$line};
      next if $dropped{$lang}{$line};
      next if covered($line, \%new);
      $lost++;
      print "  $lang $day: $line\n" if $lost <= 3;
    }
  }
  printf "%-8s %-18s %3d entries no version can reach\n", $lang, '', $lost;
  $fail += $lost;
}

printf "\n%d checks, %s\n", $checked, $fail ? "$fail PROBLEMS" : 'all clear';
exit($fail ? 1 : 0);
