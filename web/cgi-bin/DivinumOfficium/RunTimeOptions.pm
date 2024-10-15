package DivinumOfficium::RunTimeOptions;
use utf8;
use strict;
use warnings;

BEGIN {
  require Exporter;
  our $VERSION = 1.00;
  our @ISA = qw(Exporter);
  our @EXPORT_OK = qw(check_version check_horas check_language);
}

# private

sub unequivocal {
  my ($value, $tablename) = @_;
  my @values_array = main::getdialog($tablename);

  my @r = grep {/$value/} @values_array;

  if (@r == 1) {
    return $r[0] =~ s/.*\///r;
  } else {
    @r = grep { $_ eq $value } @values_array;

    if (@r == 1) {
      return $r[0] =~ s/.*\///r;
    } else {
      return;
    }
  }
}

use constant LEGACY_VERSION_NAMES => {
  'Tridentine 1570' => 'Tridentine - 1570',
  'Tridentine 1910' => 'Tridentine - 1906',
  'Rubrics 1960' => 'Rubrics 1960 - 1960',
  'Reduced 1955' => 'Reduced - 1955',
  'Monastic' => 'Monastic - 1963',
  '1960 Newcalendar' => 'Rubrics 1960 - 2020 USA',
  'Dominican' => 'Ordo Praedicatorum - 1962',

  # safeguard switch from missa to horas
  'Tridentine - 1910' => 'Tridentine - 1906',
  'Ordo Praedicatorum Dominican 1962' => 'Ordo Praedicatorum - 1962',
  'Rubrics 1960 Newcalendar' => 'Rubrics 1960 - 2020 USA',
};

use constant LEGACY_MISSA_VERSION_NAMES => {
  'Tridentine 1570' => 'Tridentine - 1570',
  'Tridentine 1910' => 'Tridentine - 1910',
  'Rubrics 1960' => 'Rubrics 1960 - 1960',
  'Reduced 1955' => 'Reduced - 1955',
  '1960 Newcalendar' => 'Rubrics 1960 - 2020 USA',
  'Dominican' => 'Ordo Praedicatorum Dominican 1962',

  # safeguard switch from horas to missa
  'Monastic Tridentinum 1617' => 'Tridentine - 1570',
  'Monastic Divino 1930' => 'Divino Afflatu - 1954',
  'Monastic - 1963' => 'Rubrics 1960 - 1960',
  'Tridentine - 1888' => 'Tridentine - 1910',
  'Tridentine - 1906' => 'Tridentine - 1910',
  'Ordo Praedicatorum - 1962' => 'Ordo Praedicatorum Dominican 1962',
};

# exported

sub check_version {
  my $v = shift;
  my $missa = shift;

  if (!$missa) {
    return LEGACY_VERSION_NAMES->{$v} || unequivocal($v, 'versions');
  } else {
    return LEGACY_MISSA_VERSION_NAMES->{$v} || unequivocal($v, 'versions');
  }
}

sub check_horas {
  my $h = shift;

  map { unequivocal($_, 'horas') } split(/(?=\p{Lu}\p{Ll}*)/, $h);
}

sub check_language {
  my $l = shift;

  unequivocal($l, 'languages');
}

1;
