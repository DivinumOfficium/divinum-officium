package DivinumOfficium::Directorium;

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/..";

use DivinumOfficium::FileIO qw(do_read);
use DivinumOfficium::Date qw(leapyear geteaster);

BEGIN {
  require Exporter;
  our $VERSION = 1.00;
  our @ISA = qw(Exporter);
  our @EXPORT_OK = qw(get_kalendar get_transfer_table get_stransfer get_tempora_table check_coronatio);
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
  my $regexp = qr{^(?:Hy|dirge=|seant)?0[12]};

  if ($filter == 1) { # Mar - Dec
    grep { !/$regexp/ } @lines ;
  } elsif ($filter == 2) { # Jan + Feb
    grep { /$regexp/ } @lines;
  } else { # whole year
    @lines;
  }
}

sub load_kalendar {
  my($version) = @_;
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

    %{$_dCACHE{$cache_key}} = @transfer 
  }
}

### public functions

### get_kalendar($version, $day)
### get filename for sancti day
sub get_kalendar {
  my($version, $day) = @_;
  my $cache_key = "kalendar:$version";

  load_kalendar($version) unless is_cached $cache_key;

  $_dCACHE{$cache_key}{$day}
}

#*** load_transfer($year, $version, $stransferf)
# load transfer table based on easterday
# full transfer hash is needed till transfered function is rewritten
sub get_transfer_table {
  my $year = shift;
  my $version = shift;

  my $cache_key = "Transfer:$version:$year";

  load_transfer($year, $version) unless is_cached $cache_key;

  %{$_dCACHE{$cache_key}}
}

#*** get_stransfer($year, $version, $key)
# get stransfer table value for key
sub get_stransfer {
  my ($year, $version, $key) = @_;

  my $cache_key = "Stransfer:$version:$year";

  load_transfer($year, $version, 'Stransfer') unless is_cached $cache_key;

  $_dCACHE{$cache_key}{$key}
}

#*** get_tempora($year, $version, $key)
# get tempora table value for key
# # not exported now
sub get_tempora {
  my ($version, $key) = @_;

  my $cache_key = "Tempora:$version";

  load_tempora($version) unless is_cached $cache_key;

  $_dCACHE{$cache_key}{$key}
}

#*** get_tempora_table($version)
# get tempora permanent transfer table
# full hash is needed till transfered function is rewritten
sub get_tempora_table {
  my($version) = shift;
  my $cache_key = "Tempora:$version";

  load_tempora($version) unless is_cached $cache_key;

  %{$_dCACHE{$cache_key}}
}

#*** check_coronatio($day, $month)
# date should be taken from data file
# and conformed with year transfer table
sub check_coronatio {
  my($day, $month) = @_;

  $day == 20 && $month == 3 ? 'Votive/Coronatio' : ''
}

1;
