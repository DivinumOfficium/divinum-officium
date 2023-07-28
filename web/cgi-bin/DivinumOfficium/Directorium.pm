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
  our @EXPORT_OK = qw(get_kalendar get_transfer get_stransfer get_tempora transfered check_coronatio dirge);
}

### private vars

my $datafolder = "$Bin/../../www/horas/Latin/Tabulae";
my %_data;
my %_dCACHE; # cache everything mainly for kalendar.pl

### private functions

sub load_data_data {
  my(@lines) = do_read("$datafolder/data.txt");
  if (@lines == 0) { die "Can't open $datafolder/data.txt"; }
  shift @lines;
  foreach (@lines) {
    my($ver,$kal,$tra,$str) = split(/,/);
    $_data{$ver}{kalendar} = $kal;
    $_data{$ver}{transfer} = $tra;
    $_data{$ver}{stransfer} = $str;
  }
  $_dCACHE{loaded} = 1;
}

sub is_cached {
  load_data_data unless defined $_dCACHE{loaded};
  my $key = shift;

  defined $_dCACHE{$key}
}

sub load_transfer_file {
  my $name = shift;
  my $filter = shift;
  my $type = shift;

  my @lines = do_read "$datafolder/$type/$name.txt";
	my $regexp = qr{^(?:Hy|seant)?(?:01|02-[01]|02-2[01239]|dirge1)};
	my $regexp2 = qr{^(?:Hy|seant)?(?:01|02-[01]|02-2[01239]|.*=(01|02-[01]|02-2[0123])|dirge1)};

  if ($filter == 1) { # Feb 24 - Dec
    grep { !/$regexp2/ } @lines ;
  } elsif ($filter == 2) { # Jan + Feb 23
    grep { /$regexp/ } @lines;
  } else { # whole year
    @lines;
  }
}

sub load_kalendar {
  my($version) = @_;
  die "Can't load kalendar for empty version" unless $version; 
  die "Can't load kalendar for unknown version $version" unless defined $_data{$version};
  my $cache_key = "kalendar:$version";

  my($filename) = "$datafolder/Kalendaria/$_data{$version}{kalendar}.txt";
  my(@lines) = do_read($filename);
  if (@lines == 0) { die "Can't open kalendar $filename for version $version"; }
  foreach (grep(/=/, @lines)) {
    my($day, $file) = split(/=/);
    $_dCACHE{$cache_key}{$day} = $file;
  }
}

sub load_tempora {
  my($version) = @_;
  die "Can't load tempora for empty version" unless $version; 
  die "Can't load tempora for unknown version $version" unless defined $_data{$version};
  my $cache_key = "Tempora:$version";

  $_dCACHE{$cache_key} = {};
  foreach (load_transfer_file($_data{$version}{transfer}, 0, 'Tempora')) {
    my($key, $val) = split(/=/);
    $_dCACHE{$cache_key}{$key} = substr($val, 0, index($val, ';'));
  }
}

#*** load_transfer($year, $version, $stransferf)
# load transfer table based on easterday
sub load_transfer {
  my $year = shift;
  my $version = shift;
  die "Can't load transfer for empty version" unless $version; 
  die "Can't load transfer for unknown version $version" unless defined $_data{$version};
  my $stransferf = shift;
  my $type = 'Transfer';
  $type = 'Stransfer' if $stransferf;
  my $cache_key = "$type:$version:$year";

  unless (is_cached($cache_key)) {
    my $isleap = leapyear($year);
    my @easter = geteaster($year);
    my $easter =  $easter[1] * 100 + $easter[0];

    my @lines = load_transfer_file($easter, $isleap, $type);
    if ($isleap) { # load Jan & Feb from next file
      $easter++;
      $easter = 401 if $easter == 332;
      push(@lines, load_transfer_file($easter, 2, $type)) 
    }

    my(@transfer) = ();
    foreach (@lines) {
      my ($line, $ver) = split(/\s*;;\s*/);
      if (!$ver || ($ver =~ $_data{$version}{transfer})) {
        push(@transfer, split(/=/, $line, 2))
      }
    }

    %{$_dCACHE{$cache_key}} = @transfer;

    # if St. Mathias was transfered to next day it is not case when year is leap
    if ($_dCACHE{$cache_key}{'02-25'} && $_dCACHE{$cache_key}{'02-25'} eq '02-24' && $isleap) { 
      $_dCACHE{$cache_key}{'02-29'} = $_dCACHE{$cache_key}{'02-25'};
      delete $_dCACHE{$cache_key}{'02-25'};
    }
  }

  %{$_dCACHE{$cache_key}}
}

### public functions

### get_kalendar($version, $day)
### get filename for sancti day
sub get_kalendar {
  my($version, $day) = @_;
  my $cache_key = "kalendar:$version";

  load_kalendar($version) unless is_cached $cache_key;

  $_dCACHE{$cache_key}{$day} || ''
}

#*** get_transfer($year, $version, $key)
# get transfer table value for key
sub get_transfer {
  my ($year, $version, $key) = @_;

  my $cache_key = "Transfer:$version:$year";

  load_transfer($year, $version) unless is_cached $cache_key;

  $_dCACHE{$cache_key}{$key} || ''
}

#*** get_stransfer($year, $version, $key)
# get stransfer table value for key
sub get_stransfer {
  my ($year, $version, $key) = @_;

  my $cache_key = "Stransfer:$version:$year";

  load_transfer($year, $version, 'Stransfer') unless is_cached $cache_key;

  $_dCACHE{$cache_key}{$key} || ''
}

#*** get_tempora($year, $version, $key)
# get tempora table value for key
sub get_tempora {
  my ($version, $key) = @_;

  my $cache_key = "Tempora:$version";

  load_tempora($version) unless is_cached $cache_key;

  $_dCACHE{$cache_key}{$key} || ''
}

#*** transfered($tname | $sday, $year, $version)
# returns destination if the day for season or saint is transfered
# otherwise false
sub transfered {
  my $str = shift;
  my $year = shift;
  my $version = shift;

  $str =~ s+Sancti/++;
  return '' unless $str;

  my %transfer = %{$_dCACHE{"Transfer:$version:$year"}};

  while (my ($key, $val) = each %transfer) {
    next unless $val;
    next if $key =~ /(dirge|Hy)/i;

    if ($val =~ /Tempora/i && $val !~ /Epi1\-0/i) { next; }

    if ($val !~ /$key/ && ($str =~ /$val/i || $val =~ /$str/i) && $transfer{$key} !~ /v\s*$/i) {
      return $key;
    }
  }

  while (my ($key, $val) = each %{$_dCACHE{"Tempora:$version"}}) {
    next if $key =~ /dirge/;

    if ($val =~ /$str/i && $transfer{$key} && $transfer{$key} !~ /v\s*$/i) { return $key; }
  }

  return '';
}

#*** check_coronatio($day, $month)
# date should be taken from data file
# and conformed with year transfer table
sub check_coronatio {
  my($day, $month) = @_;

  $day == 20 && $month == 3 ? 'Votive/Coronatio' : ''
}

#*** dirge($version, $hora, $day, $month, $year)
# check if defunctorum shoul be said after hora
sub dirge {
  my($version, $hora, $day, $month, $year) = @_;

  return 0 unless $hora =~ /Vespera|Laudes/i;

  my $sday = $hora =~ /Laudes/i ? get_sday($month, $day, $year) 
                                 : nextday($month, $day, $year);
  my $dirgeline = get_transfer($year, $version, 'dirge1') . ' '
                . get_transfer($year, $version, 'dirge2');
  $dirgeline =~ /$sday/
}

1;
