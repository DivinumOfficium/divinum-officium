#!/usr/bin/perl
#
# Import a translated martyrology.
#
# The translator writes plain files, one per day, as the martyrology has
# always been stored: heading line, '_', then one elogium per line.  Name
# them MM-DD.txt and point --src at the folder.  Or hand in the book as
# it is printed, a day to a page: one document for a month or the year,
# in plain text (pages broken by form feed) or Word.
#
#     perl import_translation.pl --lang Deutsch --src ~/deutsch
#     perl import_translation.pl --lang Francais --src Janvier.docx --month 1
#
#     --lang      folder under web/www/horas/
#     --src       folder of MM-DD.txt / MM-DD.docx files, any subset of
#                 the year; or one .txt or .docx, a day to a page
#     --month     which month a one-month file is, when its name does not
#                 start with it (01.docx); a file of 366 pages is the year
#     --replace   re-import days already there
#
# It keeps a copy of the files under obsolete/martyrologium-source, matches
# each line against the Latin, learns the language's name list into
# namelex/, then matches again now that it knows the names.
#
# Lines that name the same saints as a Latin elogium get that Latin key, so
# they line up with the other languages; the rest keep a key of their own.
# The percentage is reported and never enforced.
#
# The order and the version rules come from the Latin's [Martyrologium]
# index, which every language inherits, so there is nothing to say here
# about which version the translation follows.
#
# To redo a language already in the tree, point --src at its files under
# obsolete/martyrologium-source and pass --replace.

use strict;
use warnings;
use utf8;
use FindBin;
use lib "$FindBin::Bin/internal";
use File::Basename qw(dirname);
use File::Path qw(make_path);
use Getopt::Long;

use MartyrLib qw(all_days elogia_path flat_path pool_get pool_new pool_read pool_set pool_write);
use Cognates qw(set_lexicon add_case_corpus);
use ConvertLib qw(convert_day);
use LearnNames qw(learn installed_days);
use SourceLib qw(read_source);

binmode STDOUT, ':encoding(utf-8)';

my ($lang, $src, $month, $replace, $help);
GetOptions(
  'lang=s' => \$lang,
  'src=s' => \$src,
  'month=i' => \$month,
  'replace' => \$replace,
  'help' => \$help,
) or die "bad options\n";

if ($help || !$lang || !$src) {
  die "usage: import_translation.pl --lang <Language> --src <folder|file> [--month N] [--replace]\n";
}

#*** convert_all(\%days, \%skipped)
# Converts every day, returning the pools and the match totals.
sub convert_all {
  my ($days, $skipped) = @_;
  my (%pools, %agg);
  $agg{$_} = 0 foreach qw(aligned extras structural);

  foreach my $day (sort keys %$days) {
    my ($pool, $stats, $err) = convert_day($day, $days->{$day});

    if ($err) { $skipped->{$day} = $err; next }
    $pools{$day} = $pool;
    $agg{$_} += $stats->{$_} foreach qw(aligned extras structural);
  }
  return (\%pools, \%agg);
}

sub rate {
  my $agg = shift;
  my $total = $agg->{aligned} + $agg->{extras};
  my $pct = $total ? sprintf('%.1f%%', 100 * $agg->{aligned} / $total) : 'n/a';
  return "$agg->{aligned}/$total lines to Latin keys ($pct)";
}

my ($days, $skipped) = read_source($src, $month);
die "no days found in $src\n" unless %$days;

unless ($replace) {
  my @already = grep { -e elogia_path($lang, $_) } sort keys %$days;

  foreach my $d (@already) {
    $skipped->{$d} = 'already imported (use --replace)';
    delete $days->{$d};
  }
  die scalar(@already) . " days already imported; pass --replace to redo them\n"
    unless %$days;
}

# The names are learned from the whole language, the days being imported
# in place of the ones they replace.  Learned from a month alone, the list
# would lose every pair the rest of the year had taught it, and the next
# import of any other day would match worse for it.
my %corpus = (installed_days($lang), %$days);

# which words this language capitalises, so that ones that only look like
# names because a sentence started there are not taken for names
add_case_corpus($lang, $corpus{$_}) foreach keys %corpus;

printf "%s: %d days\n", $lang, scalar(keys %$days);

set_lexicon($lang);
my (undef, $first) = convert_all($days, {%$skipped});
printf "  matched %s on spelling rules\n", rate($first);

my $pairs = learn($lang, \%corpus);
printf "  learned %d name pairs -> namelex/%s.txt\n", $pairs, $lang;

set_lexicon(undef);
set_lexicon($lang);
my ($pools, $agg) = convert_all($days, $skipped);
printf "  matched %s using them\n", rate($agg);

# An entry the Latin index borrows from another day is read from that
# day's file: under 1960 the 22nd of February says the Chair at Rome as
# '@Martyrologium/01-18:Petri', and the reader looks for Petri in the
# language's 01-18.  A book printing it on the 22nd has it matched there,
# under '01-18:Petri', which nothing reads; its words go to the 18th.
#
# And so a day being replaced keeps what another day has lent it, unless
# the new text says it itself: the book for January has no Chair at Rome,
# and importing it after February must not take back what February put
# there.  Either order leaves the same files.
my %lent;

foreach my $day (all_days()) {
  my $path = elogia_path('Latin', $day);
  next unless -e $path;

  foreach my $line (split(/\n/, pool_get(pool_read($path, $day), 'Martyrologium', ''))) {
    $lent{$1}{$2} = 1 if $line =~ m{^\@(?:Martyrologium/)?(\d\d-\d\d):(.+?)\s*$} && $1 ne $day;
  }
}
my %others;

foreach my $day (sort keys %$pools) {
  my $pool = $pools->{$day};
  my $path = elogia_path($lang, $day);
  my $old = -e $path ? pool_read($path, $day) : undef;

  foreach my $key (sort keys %{$lent{$day} || {}}) {
    next if !$old || defined pool_get($pool, $key) || !defined pool_get($old, $key);
    pool_set($pool, $key, pool_get($old, $key));
  }
}

foreach my $day (sort keys %$pools) {
  my $pool = $pools->{$day};

  foreach my $name (grep { /^\d\d-\d\d:/ } @{$pool->{order}}) {
    my ($d2, $k2) = $name =~ /^(\d\d-\d\d):(.+)$/;
    my $text = delete $pool->{sections}{$name};
    @{$pool->{order}} = grep { $_ ne $name } @{$pool->{order}};

    my $to = $pools->{$d2} || ($others{$d2} ||=
        -e elogia_path($lang, $d2) ? pool_read(elogia_path($lang, $d2), $d2) : pool_new($d2));
    pool_set($to, $k2, $text);
    printf "  %s: %s is said from %s, and goes there\n", $day, $k2, $d2;
  }
}
pool_write($others{$_}, elogia_path($lang, $_)) foreach sort keys %others;

foreach my $day (sort keys %$pools) {
  pool_write($pools->{$day}, elogia_path($lang, $day));
  my $keep = flat_path($lang, $day);
  make_path(dirname($keep));
  open(my $fh, '>:raw', $keep) or die "$keep: $!";
  my $text = join("\n", @{$days->{$day}}) . "\n";
  utf8::encode($text);
  print $fh $text;
  close $fh;
}

printf "  wrote %d days\n", scalar(keys %$pools);

if (%$skipped) {
  printf "  skipped %d:\n", scalar(keys %$skipped);
  my @s = sort keys %$skipped;
  printf "    %s  %s\n", $_, $skipped->{$_} foreach @s[0 .. ($#s > 9 ? 9 : $#s)];
  printf "    ... and %d more\n", @s - 10 if @s > 10;
}
