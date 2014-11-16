# Module for handling Lauds and Vespers, including commemorations.


package horas::LaudsAndVespers;

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/..";

use horas::common qw(MATINS_TO_NONE);
use horas::Data;

BEGIN
{
  require Exporter;

  our $VERSION = 1.00;
  our @ISA = qw(Exporter);
  our @EXPORT_OK = qw(build_commemoration);
}


#*** build_commemoration($office_desc_ref, $segment, $dayofweek, $version,
#                        $lang,
#                        \%used_texts{'antiphons', 'verses', 'collects'})
# Constructs the antiphon, verse and collect for a commemoration at Lauds or
# Vespers. $office_ref is the office descriptor, and $segment is one of
# FIRST_VESPERS_AND_COMPLINE, MATINS_TO_NONE or SECOND_VESPERS_AND_COMPLINE.
# Returns (antiphon, verse, collect, conclusion).
sub build_commemoration
{
  my ($office_desc_ref, $segment, $dayofweek, $version, $lang,
    $used_texts_ref) = @_;
  my $hour = ($segment == MATINS_TO_NONE) ? 'Laudes' : 'Vespera';

  my ($antiphon, $verse, $collect) =
    map {get_office_part($office_desc_ref, $_, $hour, $segment, $dayofweek,
      $lang)} ('Ant', 'Versum', 'Oratio');

  # TODO: Check for duplicated texts.

  ($collect, my $conclusion) = split /(?=\$)/, $collect;

  return ($antiphon, $verse, $collect, $conclusion);
}

1;

