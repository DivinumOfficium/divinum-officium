#!/usr/bin/perl
#
# Import a translated martyrology.
#
# The translator writes plain files, one per day, as the martyrology has
# always been stored: heading line, '_', then one elogium per line.  Name
# them MM-DD.txt and point --src at the folder.
#
#     perl import_translation.pl --lang Deutsch --src ~/deutsch
#
#     --lang      folder under web/www/horas/
#     --src       folder of MM-DD.txt files, any subset of the year
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

use MartyrLib qw(all_days do_read_lines elogia_path flat_path pool_write);
use Cognates qw(set_lexicon add_case_corpus);
use ConvertLib qw(convert_day);
use LearnNames qw(learn);

binmode STDOUT, ':encoding(utf-8)';

my ($lang, $src, $replace, $help);
GetOptions(
  'lang=s' => \$lang,
  'src=s' => \$src,
  'replace' => \$replace,
  'help' => \$help,
) or die "bad options\n";

if ($help || !$lang || !$src) {
  die "usage: import_translation.pl --lang <Language> --src <folder> [--replace]\n";
}

#*** read_days($src)
# Every MM-DD.txt in the folder, as { day => [lines] }.
sub read_days {
  my $dir = shift;
  my (%days, %bad);
  my %known = map { $_ => 1 } all_days();
  opendir(my $dh, $dir) or die "cannot read $dir: $!\n";
  my @files = sort grep { /\.txt$/ } readdir $dh;
  closedir $dh;

  foreach my $f (@files) {
    (my $day = $f) =~ s/\.txt$//;
    next unless $known{$day};
    my @lines = eval { do_read_lines("$dir/$f") };

    if ($@) { $bad{$day} = 'not valid UTF-8'; next }
    $days{$day} = \@lines;
  }
  return (\%days, \%bad);
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

my ($days, $skipped) = read_days($src);
die "no MM-DD.txt files found in $src\n" unless %$days;

unless ($replace) {
  my @already = grep { -e elogia_path($lang, $_) } sort keys %$days;

  foreach my $d (@already) {
    $skipped->{$d} = 'already imported (use --replace)';
    delete $days->{$d};
  }
  die scalar(@already) . " days already imported; pass --replace to redo them\n"
    unless %$days;
}

# which words this language capitalises, so that ones that only look like
# names because a sentence started there are not taken for names
add_case_corpus($lang, $days->{$_}) foreach keys %$days;

printf "%s: %d days\n", $lang, scalar(keys %$days);

set_lexicon($lang);
my (undef, $first) = convert_all($days, {%$skipped});
printf "  matched %s on spelling rules\n", rate($first);

my $pairs = learn($lang, $days);
printf "  learned %d name pairs -> namelex/%s.txt\n", $pairs, $lang;

set_lexicon(undef);
set_lexicon($lang);
my ($pools, $agg) = convert_all($days, $skipped);
printf "  matched %s using them\n", rate($agg);

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
