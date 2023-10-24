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
  my($value, $tablename) = @_;
  my @values_array = horas::getdialog($tablename);

  my @r = grep { /$value/ } @values_array;
  if (@r == 1) { 
    return $r[0]
  } else { 
    @r = grep { $_ eq $value } @values_array;
    if (@r == 1) {
      return $r[0]
    } else {
      return
    }
  }
}

use constant LEGACY_VERSION_NAMES => { 
  'Tridentine 1570' => 'Tridentine - 1570',
  'Tridentine 1910' => 'Tridentine - 1888',
  'Rubrics 1960' => 'Rubrics 1960 - 1960',
  'Newcalendar' => 'Rubrics 1960 - 2020 USA'};

# exported

sub check_version {
  my $v = shift;

  LEGACY_VERSION_NAMES->{$v} || unequivocal($v, 'versions')
}

sub check_horas {
  my $h = shift;

  map { unequivocal($_, 'horas') } split(/(?=\p{Lu}\p{Ll}*)/, $h);
}

sub check_language {
  my $l = shift;

  unequivocal($l, 'languages') =~ s/.*\///r;
}

1;
