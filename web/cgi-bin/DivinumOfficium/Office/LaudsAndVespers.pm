# Module for handling Lauds and Vespers, including commemorations.


package DivinumOfficium::Office::LaudsAndVespers;

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/..";

use DivinumOfficium::Common qw(MATINS_TO_NONE);
use DivinumOfficium::Data qw(get_office_part);

BEGIN
{
  require Exporter;

  our $VERSION = 1.00;
  our @ISA = qw(Exporter);
  our @EXPORT_OK = qw(generate_commemoration_script);
}


#*** build_commemoration($office_desc_ref, $segment, $dayofweek, $version,
#      $lang, \%used_texts{'antiphons', 'verses', 'collects'})
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
      $version, $lang)} ('Ant', 'Versum', 'Oratio');

  # TODO: Check for duplicated texts.

  ($collect, my $conclusion) = split /(?=\$)/, $collect;

  return ($antiphon, $verse, $collect, $conclusion);
}


#*** generate_commemoration_script(\@commemorations, $dayofweek, $version,
#      $lang, \%prayers, \%used_texts{'antiphons', 'verses', 'collects'})
# Generates the script for commemorations and (TODO) suffrages. @commemorations
# are the office descriptors for the commemorations to be made.
sub generate_commemoration_script
{
  my ($commemorations_ref, $dayofweek, $version, $lang, $prayers_ref,
    $used_texts_ref) = @_;
  my @script;
  my $conclusion;

  foreach my $desc_segment_pair_ref (@$commemorations_ref)
  {
    my ($office_desc_ref, $segment) =
      @$desc_segment_pair_ref{'office', 'segment'};

    # $conclusion is declared and used in the enclosing scope.
    (my $antiphon, my $verse, my $collect, $conclusion) =
      build_commemoration($office_desc_ref, $segment, $dayofweek, $version,
        $lang, $used_texts_ref);

    push @script,
      "_\n" .
      # TODO: Translate this line and fix its Latin grammar.
      "!Commemoratio $office_desc_ref->{title}\n" .
      "Ant. $antiphon\n" .
      "_\n" .
      $verse .
      "_\n" .
      "$prayers_ref->{$lang}->{Oremus}\n" .
      "v. $collect\n";

    # TODO: Update $used_texts_ref.
  }

  return (@script, "$conclusion\n");
}

1;

