# Module for handling Mass-specific things.


package DivinumOfficium::Mass;

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/..";

use DivinumOfficium::Common qw(MATINS_TO_NONE);
use DivinumOfficium::Propers qw(get_office_part);
use Carp;

BEGIN
{
  require Exporter;

  our $VERSION = 1.00;
  our @ISA = qw(Exporter);
  our @EXPORT_OK = qw(generate_commemoration_script);
}


#*** build_commemoration($office_desc_ref, $part, $dayofweek, $version, $lang)
# Returns (prayer, conclusion) for $part, where $part is 'Oratio', 'Secreta' or
# 'Postcommunio'.
sub build_commemoration
{
  my ($office_desc_ref, $part, $dayofweek, $version, $lang) = @_;

  my $prayer = get_office_part($office_desc_ref, $part, 'SanctaMissa',
    MATINS_TO_NONE, $dayofweek, $version, $lang);

  # Return (prayer, conclusion).
  return split /(?=\$)/, $prayer;
}


#*** generate_commemoration_script(\@commemorations, $part, $dayofweek,
#   $version, $lang, \%prayers)
# Generates the script for commemorations. @commemorations are the office
# descriptors for the commemorations to be made.
sub generate_commemoration_script
{
  my ($commemorations_ref, $part, $dayofweek, $version, $lang, $prayers_ref) =
    @_;
  my @script;
  my $conclusion;

  grep { $part eq $_ } ('Oratio', 'Secreta', 'Postcommunio') or
    confess "Invalid part $part";

  # If there are no commemorations, bail out now.
  return () unless @$commemorations_ref;

  push @script, "$prayers_ref->{$lang}->{Oremus}\n" unless($part eq 'Secreta');

  # TODO: Sub unica conclusione.  Ss. Peter and Paul are already OK because
  # they're handled directly in the prayers by @-inclusions.

  foreach my $desc_segment_pair_ref (@$commemorations_ref)
  {
    my ($office_desc_ref, $segment) =
      @$desc_segment_pair_ref{'office', 'segment'};

    confess "Saw segment $segment at Mass" unless($segment == MATINS_TO_NONE);

    # $conclusion is declared and used in the enclosing scope.
    (my $prayer, $conclusion) =
      build_commemoration($office_desc_ref, $part, $dayofweek, $version, $lang);

    push @script, "!Commemoratio $office_desc_ref->{genitive_title}\n";
    push @script, $prayer;
  }

  return (@script, "$conclusion\n");
}

1;

