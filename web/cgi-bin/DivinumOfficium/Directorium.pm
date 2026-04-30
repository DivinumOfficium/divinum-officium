package DivinumOfficium::Directorium;

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/..";

use DivinumOfficium::FileIO qw(do_read);
use DivinumOfficium::Date qw(leapyear geteaster get_sday nextday);

BEGIN {
  require Exporter;
  our $VERSION = 1.00;
  our @ISA = qw(Exporter);
  our @EXPORT_OK = qw(get_from_directorium transfered check_coronatio dirge hymnmerge hymnshift hymnshiftmerge);
}

### private vars

my $datafolder = "$Bin/../../www/Tabulae";
my %_data;
my %_dCACHE;    # cache everything mainly for kalendar.pl

### private functions

sub load_data_data {
  my (@lines) = do_read("$datafolder/data.txt");
  if (@lines == 0) { die "Can't open $datafolder/data.txt"; }
  shift @lines;

  foreach (@lines) {
    my ($ver, $kal, $tra, $str, $base, $tbase) = split(/,/);
    $_data{$ver}{kalendar} = $kal;
    $_data{$ver}{transfer} = $tra;
    $_data{$ver}{stransfer} = $str;
    $_data{$ver}{base} = $base;
    $_data{$ver}{tbase} = $tbase;
  }
  $_dCACHE{loaded} = 1;
}

sub is_cached {
  load_data_data unless defined $_dCACHE{loaded};
  my $key = shift;

  defined $_dCACHE{$key};
}

sub load_transfer_file {

  my $name = shift;
  my $filter = shift;
  my $type = shift;
  my $dioecesis = shift;

  my @lines = do_read($dioecesis ? "$datafolder/$type/$dioecesis/$name.txt" : "$datafolder/$type/$name.txt");
  my $regexp = qr{^(?:Hy|seant)?(?:01|02-[01]|02-2[01239]|dirge1)};
  my $regexp2 = qr{^(?:Hy|seant)?(?:01|02-[01]|02-2[01239]|.*=(01|02-[01]|02-2[0123])|dirge1)};

  if ($filter == 1) {    # Feb 24 - Dec
    grep { !/$regexp2/ } @lines;
  } elsif ($filter == 2) {    # Jan + Feb 23
    grep {/$regexp/} @lines;
  } else {                    # whole year
    @lines;
  }
}

sub load_kalendar {
  my ($version) = @_;
  die "Can't load kalendar for empty version" unless $version;
  die "Can't load kalendar for unknown version $version" unless defined $_data{$version};
  my $cache_key = "kalendar:$version";

  my ($filename) = "$datafolder/Kalendaria/$_data{$version}{kalendar}.txt";
  my (@lines) = do_read($filename);
  if (@lines == 0) { die "Can't open kalendar $filename for version $version"; }

  foreach (grep(/=/, @lines)) {
    my ($day, $file) = split(/=/);
    $_dCACHE{$cache_key}{$day} = $file;
  }
}

sub load_tempora {
  my ($version, $year, $dioecesis) = @_;
  die "Can't load tempora for empty version" unless $version;
  die "Can't load tempora for unknown version $version" unless defined $_data{$version};

  # For Calendarium Generale, we use the cache_key:   tempora:$version
  # For other dioeceses, the cache_key gets expanded: tempora:$version:$dioecesis
  my $cache_key = "tempora:$version";
  $cache_key .= ":$dioecesis" if $dioecesis && $dioecesis ne 'Generale';
  $dioecesis ||= 'Generale';

  unless (is_cached($cache_key)) {

    my (@tempora) = ();
    my @lines = load_transfer_file($dioecesis, 0, 'Tempora');

    foreach (@lines) {
      my ($line, $ver) = split(/\s*;;\s*/);

      if (!$ver || ($ver =~ $_data{$version}{lc('transfer')})) {
        push(@tempora, split(/=/, $line, 2));
      }
    }

    %{$_dCACHE{$cache_key}} = @tempora;

  }
}

#*** load_transfers($version, $year, $stransferf)
# load transfer table by type based on easterday
sub load_transfers {
  my ($version, $year, $type, $dioecesis) = @_;
  die "Can't load transfer for empty version" unless $version;
  die "Can't load transfer for unknown version $version" unless defined $_data{$version};
  $type ||= 'Transfer';
  $dioecesis ||= '';
  $dioecesis = '' if $dioecesis eq 'Generale';
  my $cache_key = $dioecesis ? lcfirst "$type:$version:$dioecesis:$year" : lcfirst "$type:$version:$year";

  unless (is_cached($cache_key)) {

    my $isleap = leapyear($year);
    my @easter = geteaster($year);
    my $easter = $easter[1] * 100 + $easter[0];

    my $letter = ($easter - 319 + ($easter[1] == 4 ? 1 : 0)) % 7;
    my @letters = ('a', 'b', 'c', 'd', 'e', 'f', 'g');

    my @lines = load_transfer_file($letters[$letter], $isleap, $type, $dioecesis);

    push(@lines, load_transfer_file($easter, $isleap, $type, $dioecesis));

    if ($isleap) {

      # get transfers across the leap day (Diœcesian calendars only)
      push(@lines, load_transfer_file($easter . 'bis', 0, $type, $dioecesis));

      # load Jan & Feb from next file
      $easter++;
      $easter = 401 if $easter == 332;
      push(@lines, load_transfer_file($letters[$letter - 6], 2, $type, $dioecesis));
      push(@lines, load_transfer_file($easter, 2, $type, $dioecesis));
    }

    my (@transfer) = ();

    foreach (@lines) {
      my ($line, $ver) = split(/\s*;;\s*/);
      next unless $line;

      if (!$ver || ($ver =~ $_data{$version}{lc($type)})) {
        push(@transfer, split(/=/, $line, 2));
      }
    }

    %{$_dCACHE{$cache_key}} = @transfer;

  }

  %{$_dCACHE{$cache_key}};
}

#*** load_transfer($version, $year)
# load transfer table (wrapper)
sub load_transfer {
  my ($version, $year, $dioecesis) = @_;
  load_transfers($version, $year, 'Transfer', $dioecesis);
}

#*** load_stransfer($version, $year)
# load scriptura transfer table (wrapper)
sub load_stransfer {
  my ($version, $year, $dioecesis) = @_;
  load_transfers($version, $year, 'Stransfer', $dioecesis);
}

### public functions

### get_from_directorium($subject, $version, $key, $year)
# returns value for $key (ev $year) in specified $version of
# 'kalendar|tempora|transfer|stransfer' from files located in
# Tabulae subdirectories
sub get_from_directorium {
  my ($subject, $version, $key, $year, $dioecesis) = @_;

  # For Calendarium Generale, we use the cache_key:   $subject:$version:$year
  # For other Diœcesis, the cache_key gets expanded:  $subject:$version:$dioecesis:$year
  my $cache_key = "$subject:$version";
  $cache_key .= ":$year" if $year;
  my $cache_key_dioecesis = ($dioecesis && $dioecesis ne 'Generale') ? "$subject:$version:$dioecesis" : '';
  $cache_key_dioecesis .= ":$year" if $year && $cache_key_dioecesis;
  my $base = $subject eq 'kalendar' ? 'base' : 'tbase';

  no strict;

  &{"load_$subject"}($version, $year) unless is_cached $cache_key;
  &{"load_$subject"}($version, $year, $dioecesis) unless !$cache_key_dioecesis || is_cached $cache_key_dioecesis;

  # First, we look for the $key in the Proper of the Diœcesis, then in the General Calendar
  # and only after that, we look for inherited entries from a base calendar
  $cache_key_dioecesis
    ? ($_dCACHE{$cache_key_dioecesis}{$key} && $_dCACHE{$cache_key_dioecesis}{$key} . ";;$dioecesis")
    || $_dCACHE{$cache_key}{$key}
    || ($_data{$version}{$base} && get_from_directorium($subject, $_data{$version}{$base}, $key, $year, $dioecesis))
    || ''
    : $_dCACHE{$cache_key}{$key}
    || ($_data{$version}{$base} && get_from_directorium($subject, $_data{$version}{$base}, $key, $year, $dioecesis))
    || '';
}

#*** transfered($tname | $sday, $year, $version)
# returns destination if the day for season or saint is transfered
# otherwise false
sub transfered {
  my $str = shift;
  my $year = shift;
  my $version = shift;
  my $dioecesis = shift;

  $str =~ s+Sancti(M|Cist|OP)?/++;
  return '' unless $str;

  my @cache_key =
    $dioecesis && $dioecesis ne 'Generale'
    ? ("transfer:$version:$dioecesis:$year", "transfer:$version:$year")
    : ("transfer:$version:$year");

  # To avoid unnecessary duplications of Transfers, only match files with same 'mm-dd' from the same folder
  $str =~ m+(^.*?/)+;
  my $strFolder = $1 || '';

  no strict;

  foreach my $cache_key (@cache_key) {
    load_transfer($version, $year, $dioecesis) unless is_cached $cache_key;

    my %transfer = %{$_dCACHE{$cache_key}};

    while (my ($key, $val) = each %transfer) {
      next unless $val;
      next if $key =~ /(dirge|Hy)/i;

      if ($val =~ /Tempora/i && $val !~ /Epi1\-0/i) { next; }

      if ( $val !~ /^$key/
        && (($str =~ /$val/i && $val =~ /^$strFolder/) || $val =~ /$str/i)
        && $transfer{$key} !~ /v\s*$/i)
      {
        return $key;
      }
    }
    $dioecesis = '';
  }

  while (my ($key, $val) = each %{$_dCACHE{"tempora:$version"}}) {
    next if $key =~ /dirge/;

    if ($val =~ /$str/i && $transfer{$key} && $transfer{$key} !~ /v\s*$/i) { return $key; }
  }

  return $_data{$version}{'tbase'} ? transfered($str, $year, $_data{$version}{'tbase'}, $dioecesis) : '';
}

#*** check_coronatio($day, $month)
# date should be taken from data file
# and conformed with year transfer table
sub check_coronatio {
  my ($day, $month) = @_;

  $day == 18 && $month == 5 ? 'Commune/Coronatio' : '';
}

#*** dirge($version, $hora, $day, $month, $year)
# check if defunctorum shoul be said after hora
sub dirge {
  my ($version, $hora, $day, $month, $year, $dioecesis) = @_;

  return 0 unless $hora =~ /Vespera|Laudes/i;

  my $sday =
    $hora =~ /Laudes/i
    ? get_sday($month, $day, $year)
    : nextday($month, $day, $year);
  my $dirgeline;

  if ($dioecesis) {
    $dirgeline =
        get_from_directorium('transfer', $version, 'dirge1', $year, $dioecesis) . ' '
      . get_from_directorium('transfer', $version, 'dirge2', $year, $dioecesis) . ' '
      . get_from_directorium('transfer', $version, 'dirge3', $year, $dioecesis);
  } else {
    $dirgeline =
        get_from_directorium('transfer', $version, 'dirge1', $year) . ' '
      . get_from_directorium('transfer', $version, 'dirge2', $year) . ' '
      . get_from_directorium('transfer', $version, 'dirge3', $year);
  }
  $dirgeline =~ /$sday/;
}

#*** hymnmerge($version, $day, $month, $year)
# true if Matutinum Hymn should merged with Vesperas
# Rule XX.3
sub hymnmerge {
  my ($version, $day, $month, $year, $dioecesis) = @_;

  get_from_directorium("transfer", $version, sprintf("Hy%s", get_sday($month, $day, $year)), $year, $dioecesis) =~
    /1(\;\;$dioecesis)?/;
}

#*** hymnshift($version, $day, $month, $year)
# true if Hymns should shifted Vespera > Matutinum > Laudes > Vespera
# Rule XX.3
sub hymnshift {
  my ($version, $day, $month, $year, $dioecesis) = @_;

  get_from_directorium("transfer", $version, sprintf("Hy%s", get_sday($month, $day, $year)), $year, $dioecesis) =~
    /2(\;\;$dioecesis)?/;
}

#*** hymnshiftmerge($version, $day, $month, $year)
# true if Hymns should be shifted and merged Vespera > Matutinum > Matutinum & Laudes
# Rule XX.3
sub hymnshiftmerge {
  my ($version, $day, $month, $year, $dioecesis) = @_;

  get_from_directorium("transfer", $version, sprintf("Hy%s", get_sday($month, $day, $year)), $year, $dioecesis) =~
    /3(\;\;$dioecesis)?/;
}

1;
